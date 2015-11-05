DB = Sequel.sqlite('Bets.db')

DB.create_table :Bets do 
	primary_key :Row
	DateTime :BetTime, :nil=>false
	varchar :Account, :nil=>false
	Integer :CurrentAmount, :nil=>false
	varchar :Player1, :nil=>false
	varchar :Player2, :nil=>false
	varchar :BetChoice, :nil=>false
	Integer :BetAmount, :nil=>false
	Integer :Player1Total
	Integer :Player2Total
	varchar :Winner
end

require_relative 'classes.rb'