[
	'rubygems',
	'open-uri',
	'mechanize',
	'json',
	'sequel'
].each{|g| 
	require g
}

[
	'helpers/methods',
	'models/init'
].each{|rb|
	require_relative rb+'.rb'
}

url = 'http://www.saltybet.com'
prev_salt = nil
wager = nil
newBet = nil
selectedplayer = nil
p1 = nil
p2 = nil

iAmCool = true
while iAmCool===true
	agent = Mechanize.new
	email = ARGV[0]
	password = ARGV[1]
	# SIGN IN
	begin
		main_page = signin(url,agent,email,password).submit
	rescue Exception => e
		errorLogging(e)
		next
	end


	# GET BET STATUS
	begin
		stateJSON = agent.get(url+'/state.json').body #=> {p1nam:'...', p2name:'...', ... status:'...', ...}
	rescue Exception => e
		errorLogging(e)
		next
	end # DONE: begin...


	status_hsh = JSON.parse(stateJSON)
	bet_status = status_hsh['status'] # Are bets 'open' or 'locked'?

	if(bet_status == 'open')
		# CURRENT SALT 
		curr_salt = main_page.search('#balance')[0].text.gsub(',','').to_i # How much Salt I currently have
		
		# IF true, I won last turn
		if(prev_salt+wager === curr_salt)
			newBet.Winner = selectedplayer==='player1' ? p1 : p2
		end

		# If true, I lost last turn.
		if(prev_salt-wager === curr_salt)
			newBet.Winner = selectedplayer==='player1' ? p2 : p1
		end

		if(newBet!=nil)
			newBet.save_changes
		end

		prev_salt = curr_salt

		# GET FIGHTER NAMES
		p1 = status_hsh['p1name'] # Name of red team
		p2 = status_hsh['p2name'] # Name of blue team

		# statsJSON = agent.get(url+'/ajax_get_stats.php').body # Get winrates for both fighters (or teams if it's an exhibition match)
		# stats_hsh = JSON.parse(statsJSON)

		# p1_winrate = winrate_getter(stats_hsh['p1winrate'])
		# p2_winrate = winrate_getter(stats_hsh['p2winrate'])

		# DECIDING WHO TO BET ON 
		p1_winrate = Bet.getPlayerStats(p1)
		p2_winrate = Bet.getPlayerStats(p2)

		if(p1_winrate===nil && p2_winrate!=nil)
			selectedplayer = 'player2'
		elsif(p1_winrate!=nil && p2_winrate==nil)
			selectedplayer = 'player1'
		elsif(p1_winrate==nil && p2_winrate==nil)
			selectedplayer = Random.rand(1..2)===1 ? 'player1' : 'player2'
		else
			if(p1_winrate>p2_winrate)
				selectedplayer = 'player1'
			elsif(p1_winrate<p2_winrate)
				selectedplayer = 'player2'
			else
				selectedplayer = Random.rand(1..2)===1 ? 'player1' : 'player2'
			end
		end

		# CHOOSING HOW MUCH TO BET
		all_in_threshold = 20000
		wager = (curr_salt<all_in_threshold) ? curr_salt : 
		 	(curr_salt<50000) ? 2500  : 
		 	(curr_salt<100000) ? 3500 : 
		 	(curr_salt<1000000) ? 5000 :
		 	(curr_salt<5000000) ? 7500 :
		 	(curr_salt<10000000) ? 10000 :
		 	(curr_salt<20000000) ? 15000 :
		 	20000
		wager = wager.round

		# PREAMBLE TO THE BET
		p "Signed in as #{email}",
		# "Bets are '#{bet_status}'",
		"Current balance: $#{curr_salt}",
		"Player 1: '#{p1}' with win ratio of #{p1_winrate}",
		"Player 2: '#{p2}' with win ratio of #{p2_winrate}",
		"BOT WILL BET $#{wager} ON #{selectedplayer}...",
		'==='

		# PLACE THE BET AND PRINT CONFIRMATION
		begin
			agent.post(
				url+'/ajax_place_bet.php',
				{
					'radio'=>'on',
					'selectedplayer'=>selectedplayer,
					'wager'=>wager.to_s
				}
			)

			newBet = Bet.new
			Bet.Account = email
			Bet.CurrentAmount = curr_salt
			Bet.Player1 = p1
			Bet.Player2 = p2
			Bet.BetChoice = selectedplayer
			Bet.BetAmount = wager
			Bet.BetTime = Time.now
		rescue Exception => e
			errorLogging(e)
			next
		end # DONE: begin...

		p "BET COMPLETED AT #{Time.now}!"
		sleep 60


		# GET BET STATUS
		begin
			stateJSON = agent.get(url+'/state.json').body #=> {p1nam:'...', p2name:'...', ... status:'...', ...}
		rescue Exception => e
			errorLogging(e)
			next
		end # DONE: begin...

		
		main_page = agent.get(url)
		p "=================================================="
	else
		p "BETS ARE LOCKED! THE TIME IS #{Time.now}. RE-CHECKING BET STATUS IN 30 SECONDS..."
		sleep 30


		# # GET BET STATUS
		# begin
		# 	stateJSON = agent.get(url+'/state.json').body #=> {p1nam:'...', p2name:'...', ... status:'...', ...}
		# rescue Exception => e
		# 	errorLogging(e)
		# 	next
		# end # DONE: begin...

		
		main_page = agent.get(url)
		p "=========================="
	end	# DONE: if(bet_status == 'open')	
end