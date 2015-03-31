require 'test/unit'

class CoinsTest < Test::Unit::TestCase
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
    def price
      @fives * 5 + @threes * 3
    end
    def number_coins
      @fives + @threes
    end
  end

  def coinsFinderRecursive(input, possible_solution = Solution.new, solutions = [])
    total = possible_solution.price

    if input > total
      coinsFinderRecursive(input, Solution.new(possible_solution.fives, possible_solution.threes+1),
           coinsFinderRecursive(input, Solution.new(possible_solution.fives+1, possible_solution.threes), solutions))
    elsif input == total && !solutions.include?(possible_solution)
      solutions << possible_solution
    else
      solutions
    end
  end

  def coinsFinderLoop(input)
    solutions = []
    (input/5).downto 0 do |fives| #starting from the most fives as this is most likely the best solution
      for threes in 0..((input - fives*5) / 3) do
        solution = Solution.new(fives, threes)
        if solution.price == input && !solutions.include?(solution)
          solutions << solution
        end
        if solutions.length > 5 #to optimize am hoping that the best solution will be among the first few found
          break
        end
      end
    end

    solutions
  end

  def bestSolution(solutions)
    solutions.sort {|a,b| a.number_coins <=> b.number_coins}[0]
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