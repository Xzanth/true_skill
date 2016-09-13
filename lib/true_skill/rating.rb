module TrueSkill
  MU = 25
  SIGMA = 25 / 3.0

  # <script type="text/javascript" async src=
  # "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
  # </script>
  # A class for gaussian distributions, used for ratings in TrueSkill.
  #
  # The class is defined by pi the precision and tau the precision adjusted
  # mean. Where for a gaussian distribution:
  #
  # $$\mathcal\{N} (\mu, \sigma)$$
  #
  # $$\pi = \frac\{1}\{\sigma^2}$$
  #
  # $$\tau = \mu\pi$$
  #
  class Gaussian
    # @return [Float]
    attr_reader :pi

    # @return [Float]
    attr_reader :tau

    # @param [Hash] arg A hash containing either both pi and tau or mu and sigma
    # @option arg [Float] :pi precision
    # @option arg [Float] :tau precision adjusted mean
    # @option arg [Float] :mu mean
    # @option arg [Float] :sigma standard deviation
    def initialize(**arg)
      if arg.key?(:pi) && arg.key?(:tau)
        @pi  = arg[:pi]
        @tau = arg[:tau]
      elsif arg.key?(:mu) && arg.key?(:sigma)
        @pi  = arg[:sigma]**-2
        @tau = pi * arg[:mu]
      else
        @pi  = 0
        @tau = 0
      end
    end

    # The mean of the gaussian, calculated using pi and tau.
    #
    # $$\mu = \frac\{\tau}\{\pi}$$
    #
    # @return [Float] The mean
    def mu
      return 0.0 if @pi.zero?
      @tau / @pi
    end

    # The standard deviation of the gaussian, calculated using pi.
    #
    # $$\sigma = \sqrt\{\frac{1}{\pi}}$$
    #
    # @return [Float] The standard deviation
    def sigma
      return Float::INFINITY if @pi.zero?
      Math.sqrt(1.0 / @pi)
    end

    # Multiply two gaussian distributions by adding pi and tau.
    # @return [Gaussian]
    def *(other)
      return ArgumentError unless other.is_a?(Gaussian)
      pi  = @pi  + other.pi
      tau = @tau + other.tau
      Gaussian.new(pi: pi, tau: tau)
    end

    # Divide two gaussian distributions by subtracting pi and tau.
    # @return [Gaussian]
    def /(other)
      return ArgumentError unless other.is_a?(Gaussian)
      pi  = @pi  - other.pi
      tau = @tau - other.tau
      Gaussian.new(pi: pi, tau: tau)
    end

    # Two gaussian distributions are equal if pi and tau are equal.
    # @return [Boolean]
    def ==(other)
      return ArgumentError unless other.is_a?(Gaussian)
      @pi == other.pi and @tau == other.tau
    end

    # Gaussian distributions are compared using mu.
    # @return [Boolean]
    def <(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu < other.mu
    end

    # Gaussian distributions are compared using mu.
    # @return [Boolean]
    def <=(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu <= other.mu
    end

    # Gaussian distributions are compared using mu.
    # @return [Boolean]
    def >(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu > other.mu
    end

    # Gaussian distributions are compared using mu.
    # @return [Boolean]
    def >=(other)
      return ArgumentError unless other.is_a?(Gaussian)
      mu >= other.mu
    end

    # Print the gaussian distribution using its mu and sigma rounded to
    # 2 decimal places.
    # @return [String]
    def to_s
      "N(mu=#{mu.round(2)}, sigma=#{sigma.round(2)})"
    end
  end

  # <script type="text/javascript" async src=
  # "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
  # </script>
  # Ratings are a subclass of Gaussian, with the extra variable of an owner,
  # representing the player who owns the rating.
  class Rating < Gaussian
    attr_reader :owner

    def initialize(owner, **arg)
      if arg.empty?
        super(mu: MU, sigma: SIGMA)
      else
        super(arg)
      end
      @owner = owner
    end

    # Ratings of the same Gaussian but with different owners are not the same
    # @return [Boolean]
    def ==(other)
      return ArgumentError unless other.is_a?(Rating)
      @pi == other.pi and @tau == other.tau and @owner == other.owner
    end

    def conservative
      mu - (3 * sigma)
    end
  end
end
