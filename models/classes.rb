class Bet < Sequel::Model
	set_dataset :Bets

	def self.getPlayerStats(player)
		p1 = self.select(
			:Player1,
			:Winner
		)
		.where(
			:Player1=>player
		).all

		p2 = self.select(
			:Player2,
			:Winner
		)
		.where(
			:Player2=>player
		).all

		
	end
end