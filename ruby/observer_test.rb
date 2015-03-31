require 'test/unit'
require 'observer'

class ObserverTest < Test::Unit::TestCase
  class Notifier
    attr_reader :notifications

    def initialize
      @notifications = []
    end
    def update(car, miles)
      @notifications << "The car has logged #{miles} miles, totaling #{car.mileage} miles traveled."
      @notifications << "The car needs to be taken in for a service!" if car.service <= car.mileage
    end
  end

  class Car
    include Observable
    attr_reader :mileage, :service, :notifier

    def initialize(mileage = 0, service = 3000)
      @mileage, @service = mileage, service
      @notifier = Notifier.new
      add_observer(@notifier)
    end

    def log(miles)
      @mileage += miles
      changed
      notify_observers(self, miles)
    end
  end

  test "test" do
    car = Car.new(2300, 3000)
    car.log(100)
    assert_equal ["The car has logged 100 miles, totaling 2400 miles traveled."], car.notifier.notifications
    car.log(354)
    assert_equal [
                     "The car has logged 100 miles, totaling 2400 miles traveled.",
                     "The car has logged 354 miles, totaling 2754 miles traveled."
                 ],
                 car.notifier.notifications
    car.log(300)
    assert_equal [
                     "The car has logged 100 miles, totaling 2400 miles traveled.",
                     "The car has logged 354 miles, totaling 2754 miles traveled.",
                     "The car has logged 300 miles, totaling 3054 miles traveled.",
                    "The car needs to be taken in for a service!"
                 ],
                 car.notifier.notifications
  end
end