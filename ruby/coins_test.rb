require 'test/unit'

class CoinsTest < Test::Unit::TestCase
  class Solution
    attr_accessor :fives, :threes
    def initialize(fives = 0, threes = 0)
      @fives = fives
      @threes = threes
    end

    def ==(other)
      other.threes == @threes && other.fives == @fives
    end

    def to_s
      "#{fives} five cents, #{threes} three cents"
    end
    def total
      @fives * 5 + @threes * 3
    end
    def coinSum
      @fives + @threes
    end
  end

  def coinsFinderRecursive(input, possibleSolution = Solution.new, solutions = [])
    total = possibleSolution.total

    if input > total
      coinsFinderRecursive(input, Solution.new(possibleSolution.fives, possibleSolution.threes+1),
           coinsFinderRecursive(input, Solution.new(possibleSolution.fives+1, possibleSolution.threes), solutions))
    elsif input == total && !solutions.include?(possibleSolution)
      solutions << possibleSolution
    else
      solutions
    end
  end

  def coinsFinderLoop(input)
    solutions = []
    (input/5).downto 0 do |fives|
      for threes in 0..((input - fives*5) / 3) do
        solution = Solution.new(fives, threes)
        if solution.total == input && !solutions.include?(solution)
          solutions << solution
        end
        if solutions.length > 5
          break
        end
      end
    end

    solutions
  end

  def bestSolution(solutions)
    solutions.sort {|a,b| a.coinSum <=> b.coinSum}[0]
  end

  test "test recursion" do
    assert_equal Solution.new(1, 1), bestSolution(coinsFinderRecursive(8))
    assert_equal Solution.new(1, 2), bestSolution(coinsFinderRecursive(11))
    assert_equal Solution.new(5, 2), bestSolution(coinsFinderRecursive(31))

    #as expected the stack explodes if the number is too big
    # assert_equal Solution.new(20, 0), bestSolution(coinsFinderRecursive(100))
    # assert_equal Solution.new(1999998, 4), bestSolution(coinsFinderRecursive(10000002))
  end

  test "test using loops" do
    assert_equal Solution.new(1, 1), bestSolution(coinsFinderLoop(8))
    assert_equal Solution.new(1, 2), bestSolution(coinsFinderLoop(11))
    assert_equal Solution.new(5, 2), bestSolution(coinsFinderLoop(31))
    assert_equal Solution.new(20, 0), bestSolution(coinsFinderLoop(100))
    assert_equal Solution.new(1999998, 4), bestSolution(coinsFinderLoop(10000002))
  end
end