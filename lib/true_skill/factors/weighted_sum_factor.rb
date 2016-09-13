module TrueSkill
  module Factors
    class WeightedSumFactor < Factor
      attr_accessor :factors_up

      def initialize(factors_up, factor_down, weights)
        @factors_up  = factors_up
        @factor_down = factor_down
        @weights     = weights
        super()
      end

      def down
        pi_inverse = 0
        new_mu = 0

        @factors_up.zip(@weights).each do |factor, weight|
          msg = get_message(factor)
          new_mu += weight * msg.mu
          next if pi_inverse == Float::INFINITY
          pi_inverse += weight**2 / msg.pi.to_f
        end

        pi = 1.0 / pi_inverse
        tau = pi * new_mu

        message = Gaussian.new(pi: pi, tau: tau)

        @factor_down.update_by_message(self, message)
      end
    end
  end
end
