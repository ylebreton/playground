require 'minitest/autorun'

class BuilderTest < Minitest::Test
  class BuilderTestHolder
    attr_accessor :first, :last, :age
    def initialize(&block) # this isn't really a builder since you can't evolve the object, but could be useful
      self.first = ''
      self.last = ''
      self.age = 0

      instance_eval &block if block_given?
    end
  end
  class Builder2TestHolder # this is a builder
    def initialize
      @object = BuilderTestHolder.new
    end
    def withFirst(value)
      @object.first = value
      self
    end
    def withLast(value)
      @object.last = value
      self
    end
    def withAge(value)
      @object.age = value
      self
    end
    def build
      @object
    end
  end

  def test_defaults1
    holder = BuilderTestHolder.new

    assert_equal '', holder.first
    assert_equal '', holder.last
    assert_equal 0, holder.age
  end

  def test_override1
    holder = BuilderTestHolder.new do
      self.age = 10
      self.first = 'foo'
      self.last = 'bar'
    end

    assert_equal 'foo', holder.first
    assert_equal 'bar', holder.last
    assert_equal 10, holder.age
  end

  def test_defaults2
    holder = Builder2TestHolder.new.build

    assert_equal '', holder.first
    assert_equal '', holder.last
    assert_equal 0, holder.age
  end

  def test_override2
    holder = Builder2TestHolder.new.withFirst('foo').withLast('bar').withAge(10).build

    assert_equal 'foo', holder.first
    assert_equal 'bar', holder.last
    assert_equal 10, holder.age
  end
end

