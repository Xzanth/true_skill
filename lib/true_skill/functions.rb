# <script type="text/javascript" async src=
# "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
# </script>
module TrueSkill
  BETA = 50 / 6.0

  # Return a value that represents the perceived quality of the matchup between
  # the two teams, which is the calculated probability of a draw occuring
  # according to their ratings.
  # @param [Array<Array<Rating>>] teams An array of the teams in the match
  # @return [Float] A value between *0* and *1* representing the quality
  # @see prob_draw
  def quality(teams)
    mu = mu_vector(teams)
    sigma = sigma_matrix(teams)
    a_matrix = a_matrix(teams)

    prob_draw(mu, sigma, BETA, a_matrix)
  end

  # Calculates the probability of a draw occuring.
  #
  # The formula for this function is as follows:
  #
  # $$q_\{\text{draw}} (\mu, \Sigma, \beta, \mathbf\{A}) = \exp(-\frac\{1}\{2}
  # \mu^\{\intercal}\mathbf\{A}(\beta^\{2}\mathbf\{A}^\{\intercal}\mathbf\{A}+
  # \mathbf\{A}^\{\intercal}\Sigma\mathbf\{A})^\{-1}\mathbf\{A}^\{\intercal}\mu)
  # \cdot\sqrt\{\frac{\mid\beta^{2}\mathbf\{A}^{\intercal}\mathbf\{A}\mid}{
  # \mid\beta^{2}\mathbf\{A}^{\intercal}\mathbf\{A}+\mathbf\{A}^\{\intercal}
  # \Sigma\mathbf\{A}\mid}}$$
  #
  # @param [Matrix] mu {#mu_vector}
  # @param [Matrix] sigma {#sigma_matrix}
  # @param [Float] beta
  # @param [Matrix] a_matrix {#a_matrix}
  # @return [Float] The probability of a draw
  def prob_draw(mu, sigma, beta, a_matrix)
    b2ata = (beta**2) * a_matrix.t * a_matrix
    atsa  = a_matrix.t * sigma * a_matrix
    mta = mu.t * a_matrix
    atm = a_matrix.t * mu
    middle = b2ata + atsa
    e_arg = (-0.5 * mta * middle.inverse * atm).det
    s_arg = b2ata.det / middle.det
    Math.exp(e_arg) * Math.sqrt(s_arg)
  end

  # Creates the mu vector, a vector of all the mean values for the players.
  #
  # @param [Array<Array<Rating>>] teams An array of the teams in the match
  # @return [Matrix] The mu vector as a 1 column matrix
  # @see quality
  def mu_vector(teams)
    mean_array = teams.flatten.map(&:mu)
    Matrix.column_vector(mean_array)
  end

  # Creates the sigma matrix, a matrix where the diagonal values are the
  # variances of each of the players.
  #
  # e.g. When player 1 has variance *280*, player 2: *300* and player 3: *150*
  #
  # $$\Sigma = \left\vert \begin\{array}\{ccc}
  # 280 & 0 & 0 \\
  # 0 & 300 & 0 \\
  # 0 & 0 & 150 \end\{array}\right\vert$$
  #
  # @param [Array<Array<Rating>>] teams An array of the teams in the match
  # @return [Matrix] The sigma matrix
  # @see quality
  def sigma_matrix(teams)
    all_players = teams.flatten
    variance_array = all_players.map { |r| r.sigma**2 }
    Matrix.build(all_players.length) do |row, col|
      if row == col
        variance_array[row]
      else
        0
      end
    end
  end

  # Creates a matrix from teams that indicates which teams specific players
  # belong to.
  #
  # The matrix has one less column than the number of teams and the same number
  # of rows as players. Each column corresponds to a comparison between two
  # teams so the first column compares the first two teams, the second column
  # the second team and the third team and so on. Each row either contains the
  # value *1* if the player belongs to the first team it is comparing, a *-1* if
  # it belongs to the second, or a *0* if it belongs to neither.
  #
  # e.g. If team 1 contained players 1, 2 and 3, team 2: player 4 and team 3:
  # players 5 and 6. Then a_matrix would produce the following matrix:
  #
  # $$\mathbf\{A} = \left\vert \begin\{array}\{cc}
  # 1 & 0 \\
  # 1 & 0 \\
  # 1 & 0 \\
  # -1 & 1 \\
  # 0 & -1 \\
  # 0 & -1 \end\{array}\right\vert$$
  #
  # @param [Array<Array<Rating>>] teams An array of the teams in the match
  # @return [Matrix] The a_matrix
  # @see quality
  def a_matrix(teams)
    compare = (1..teams.length - 1).map { |i| [teams[i - 1], teams[i]] }
    all_players = teams.flatten
    a_arrays = []
    compare.each do |c|
      column = all_players.map do |p|
        if c[0].include?(p)
          1
        elsif c[1].include?(p)
          -1
        else
          0
        end
      end
      a_arrays.push(column)
    end
    Matrix.columns(a_arrays)
  end
end
