module TrueSkill
  module Factors
    class Factor
      def initialize(rating = Gaussian.new)
        @rating = rating
        @messages = {}
      end

      def down
        raise "Abstract method FactorGraph::Factor#down called"
      end

      def up
        raise "Abstract method FactorGraph::Factor#up called"
      end

      def update(belief)
        pi_delta = (@rating.pi - belief.pi).abs
        tau_delta = (@rating.tau - belief.tau).abs
        @rating = belief
        return 0 if pi_delta == Float::INFINITY
        [tau_delta, Math.sqrt(pi_delta)].max
      end

      def update_by_message(from_factor, message)
        old_message = get_message(from_factor)
        other_messages = @rating / old_message
        @messages[from_factor] = message
        update(other_messages * message)
      end

      def update_by_belief(from_factor, belief)
        old_message = get_message(from_factor)
        other_messages = @rating / old_message
        @messages[from_factor] = belief / other_messages
        update(belief)
      end

      def get_message(from_factor)
        return Gaussian.new unless @messages.key?(from_factor)
        @messages[from_factor]
      end

      def to_s
        "<#{self.class} #{@rating} with #{@messages.length} connections>"
      end
    end
  end
end
