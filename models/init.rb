DB = Sequel.sqlite('Bets.db')

DB.create_table :Bets do 
	primary_key :Row
	varchar :Account
	varchar :Player1
	varchar :Player2
	Integer :CurrentAmount
	Integer :Bet
	DateTime :BetTime
end

require_relative 'classes.rb'