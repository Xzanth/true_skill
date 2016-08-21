module TrueSkill
  # <script type="text/javascript" async src=
  # "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
  # </script>
  # A class for gaussian distributions, used as ratings in TrueSkill.
  class Gaussian
    attr_reader :pi
    attr_reader :tau

    # @param [Hash] arg A hash containing either both pi and tau or mu and sigma
    # @option arg [Float] :pi \$$\pi$$
    # @option arg [Float] :tau \$$\tau$$
    # @option arg [Float] :mu \$$\mu$$
    # @option arg [Float] :sigma \$$\sigma$$
    def initialize(**arg)
      if arg.key?(:pi) && arg.key?(:tau)
        @pi  = arg[:pi]
        @tau = arg[:tau]
      elsif arg.key?(:mu) && arg.key?(:sigma)
        @pi  = arg[:sigma]**-2
        @tau = pi * arg[:mu]
      else
        raise ArgumentError, "Gaussian hash should either include both pi and"\
        " tau or both mu and sigma."
      end
    end

    def mu
      return 0.0 if @pi.zero?
      @tau / @pi
    end

    def sigma
      return Float::INFINITY if @pi.zero?
      Math.sqrt(1.0 / @pi)
    end

    def *(other)
      return ArgumentError unless other.is_a?(Gaussian)
      pi  = @pi  + other.pi
      tau = @tau + other.tau
      Gaussian.new(pi: pi, tau: tau)
    end

    def /(other)
      return ArgumentError unless other.is_a?(Gaussian)
      pi  = @pi  - other.pi
      tau = @tau - other.tau
      Gaussian.new(pi: pi, tau: tau)
    end

    def ==(other)
      return ArgumentError unless other.is_a?(Gaussian)
      @pi == other.pi and @tau == other.tau
    end

    def <(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu < other.mu
    end

    def <=(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu <= other.mu
    end

    def >(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu > other.mu
    end

    def >=(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu >= other.mu
    end

    def to_s
      "N(mu=#{mu.round(2)}, sigma=#{sigma.round(2)})"
    end
  end
end
