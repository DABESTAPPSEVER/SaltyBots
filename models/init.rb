DB = Sequel.sqlite('Bets.db')

DB.create_table :Bets do 
	primary_key :Row
	varchar :Account
	Integer :CurrentAmount
	varchar :Player1
	varchar :Player2
	varchar :BetChoice
	Integer :BetAmount
	DateTime :BetTime
	Integer :Player1Total
	Integer :Player2Total
	varchar :Winner
end

require_relative 'classes.rb'