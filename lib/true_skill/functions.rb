# <script type="text/javascript" async src=
# "https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-MML-AM_CHTML">
# </script>
module TrueSkill
  BETA = 4.166666666666667

  # Return a value that represents the perceived quality of the matchup between
  # the two teams, which is the calculated probability of a draw occuring
  # according to their ratings.
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
  # where, given an array of the players in the game from both teams:
  #
  # $$\mu$$ is a vector where each row corresponds to each player and the value
  # in each row is that player's mean.
  #
  # $$\Sigma$$ is a matrix whereby the diagonal values are the variances of each
  # of the players. Each value in the column and row of the corresponding
  # player.
  #
  # e.g. When player 1 has variance *280*, player 2: *300* and player 3: *150*
  #
  # \$$\Sigma = \left| \begin\{array}\{ccc}
  # 280 & 0 & 0 \\
  # 0 & 300 & 0 \\
  # 0 & 0 & 150 \end\{array}\right|$$
  #
  # $$\mathbf\{A}$$ is a vector where each row corresponds to each player and
  # the value *1* indicates they are on team 1 and *-1* indicates they're on
  # team 2.
  #
  # ##Initial variable creation:
  #
  # $$\mu$$ = mean_vector
  #
  # $$\Sigma$$ = variance_matrix
  #
  # $$\mathbf\{A}$$ = a_matrix
  #
  # $$\beta$$ = TrueSkill::BETA
  #
  # ##Intermediate variables:
  #
  # b2ata = $$\beta^{2}\mathbf\{A}^{\intercal}\mathbf\{A}$$
  #
  # atsa = $$\mathbf\{A}^{\intercal}\Sigma\mathbf\{A}$$
  #
  # mta = $$\mu^{\intercal}\mathbf\{A}$$
  #
  # atm = $$\mathbf\{A}^{\intercal}\mu$$
  #
  # middle = $$\beta^{2}\mathbf\{A}^{\intercal}\mathbf\{A} +
  # \mathbf\{A}^{\intercal}\Sigma\mathbf\{A}$$
  #
  # ##Final variables:
  #
  # e_arg = $$-\frac\{1}\{2}\mu^{\intercal}\mathbf\{A}(\beta^{2}
  # \mathbf\{A}^{\intercal}\mathbf\{A}+\mathbf\{A}^{\intercal}\Sigma
  # \mathbf\{A})^\{-1}\mathbf\{A}^{\intercal}\mu$$
  #
  # s_arg = $$\frac\{\mid\beta^{2}\mathbf\{A}^{\intercal}\mathbf\{A}\mid}{
  # \mid\beta^{2}\mathbf\{A}^{\intercal}\mathbf\{A}+\mathbf\{A}^\{\intercal}
  # \Sigma\mathbf\{A}\mid}$$
  #
  # @param [Array<Gaussian>] team1 The first team in the comparison
  # @param [Array<Gaussian>] team2 The second team in the comparison
  # @return [Float] The probability of a draw between these two teams
  def quality(team1, team2)
    all_players = team1 + team2
    num_players = all_players.length

    mean_array = all_players.map(&:mu)
    mean_vector = Matrix.column_vector(mean_array)

    sigma_array = all_players.map(&:sigma)

    variance_matrix = Matrix.build(num_players, num_players) do |row, col|
      if row == col
        sigma_array[row]**2
      else
        0
      end
    end

    comparison_array = []
    team1.each { comparison_array.push(1)  }
    team2.each { comparison_array.push(-1) }
    a_matrix = Matrix.column_vector(comparison_array)

    rotated_a_matrix = a_matrix.t

    b2ata = (BETA**2) * a_matrix.t * a_matrix
    atsa  = rotated_a_matrix * variance_matrix * a_matrix
    mta = mean_vector.t * a_matrix
    atm = a_matrix.t * mean_vector
    middle = b2ata + atsa
    e_arg = (-0.5 * mta * middle.inverse * atm).det
    s_arg = b2ata.det / middle.det
    Math.exp(e_arg) * Math.sqrt(s_arg)
  end
end
