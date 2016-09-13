module TrueSkill
  module Factors
    class LikelihoodFactor < Factor
      attr_accessor :factor_up

      def initialize(factor_up, factor_down, uncertainty)
        @factor_up   = factor_up
        @factor_down = factor_down
        @uncert      = uncertainty
        super()
      end

      def down
        msg = get_message(@factor_up)
        a = 1.0 / (1.0 + @uncert * msg.pi)

        message = Gaussian.new(pi: a * msg.pi, tau: a * msg.tau)

        @factor_down.update_by_message(self, message)
      end
    end
  end
end
