require 'minitest/autorun'

class CoinsTest < Minitest::Test
  class Solution
    attr_accessor :fives, :threes
    def initialize(fives = 0, threes = 0)
      @fives = fives
      @threes = threes
    end

    def ==(other) #to be compatible with array.include?
      other.threes == @threes && other.fives == @fives
    end

    def to_s #for display
      "#{fives} five cents, #{threes} three cents"
    end
    def value
      @fives * 5 + @threes * 3
    end

    def number_coins
      @fives + @threes
    end
  end

  def coinsFinderRecursive(input)
    def coinsFinderRecursiveHelper(input, possible_solution, solutions) #hiding helper function since it has no value outside of coinsFinderRecursive it could also be made private
      possible_solution.threes = (input - possible_solution.fives*5) / 3

      if possible_solution.fives < 0
        solutions
      elsif possible_solution.value == input
        solutions << possible_solution
      else
        coinsFinderRecursiveHelper(input, Solution.new(possible_solution.fives - 1), solutions) #now this is a tail recursion
      end
    end

    coinsFinderRecursiveHelper(input, Solution.new(input/5), [])
  end

  def coinsFinderLoop(input)
    solutions = []
    (input/5).downto 0 do |fives| #starting from the most fives as this is most likely the best solution
      solution = Solution.new(fives, (input - fives*5) / 3)

      if solution.value == input
        solutions << solution
      end
    end

    solutions
  end

  def bestSolution(solutions)
    solutions.sort {|a,b| a.number_coins <=> b.number_coins}[0]
  end

  def test_using_recursion
    assert_equal Solution.new(1, 1), bestSolution(coinsFinderRecursive(8))
    assert_equal Solution.new(1, 2), bestSolution(coinsFinderRecursive(11))
    assert_equal Solution.new(5, 2), bestSolution(coinsFinderRecursive(31))
    assert_equal Solution.new(20, 0), bestSolution(coinsFinderRecursive(100))
    assert_equal Solution.new(1999998, 4), bestSolution(coinsFinderRecursive(10000002))
  end

  def test_using_loops
    assert_equal Solution.new(1, 1), bestSolution(coinsFinderLoop(8))
    assert_equal Solution.new(1, 2), bestSolution(coinsFinderLoop(11))
    assert_equal Solution.new(5, 2), bestSolution(coinsFinderLoop(31))
    assert_equal Solution.new(20, 0), bestSolution(coinsFinderLoop(100))
    assert_equal Solution.new(1999998, 4), bestSolution(coinsFinderLoop(10000002))
  end
end