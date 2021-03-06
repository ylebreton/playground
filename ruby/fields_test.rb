require 'minitest/autorun'

class FieldsTest < Minitest::Test
  class FieldTestHolder
    class << self; attr_accessor :created; end
    attr_accessor :foo
		def initialize(foo = 0)
			@foo = foo
      self.class.created ||= 0
      self.class.created += 1
		end
  end

  def test_testy
  	one = FieldTestHolder.new
  	two = FieldTestHolder.new(10)

		assert_equal 0, one.foo
		assert_equal 10, two.foo
		assert_equal 2, FieldTestHolder.created
  end
end

