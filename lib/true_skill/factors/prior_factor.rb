module TrueSkill
  module Factors
    class PriorFactor < Factor
      def initialize(rating, factor_down, tau)
        @factor_down = factor_down
        @tau         = tau
        super(rating)
      end

      def down
        sigma = Math.sqrt(@rating.sigma**2 + @tau**2)

        belief = Gaussian.new(mu: @rating.mu, sigma: sigma)

        @factor_down.update_by_belief(self, belief)
      end
    end
  end
end
