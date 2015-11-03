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

		return p1
	end
end