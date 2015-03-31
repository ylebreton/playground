require 'test/unit'

class SingletonTest < Test::Unit::TestCase
  class SimpleLogger1
    class << self
      undef_method :new

      def output
        @output ||= []
      end

      def error(message)
        output << formatted_message(message, "ERROR")
      end

      def info(message)
        output << formatted_message(message, "INFO")
      end

      private

      def formatted_message(message, message_type)
        "#{message_type}: #{message}"
      end
    end
  end

  class SimpleLogger2
    @@instance = SimpleLogger2.new

    def self.instance
      @@instance
    end

    def output
      @output ||= []
    end

    def error(message)
      output << formatted_message(message, "ERROR")
    end

    def info(message)
      output << formatted_message(message, "INFO")
    end

    private_class_method :new

    private

    def formatted_message(message, message_type)
      "#{message_type}: #{message}"
    end
  end

  test "version1" do
    SimpleLogger1.error("foo")
    SimpleLogger1.info("bar")

    assert_equal ["ERROR: foo", "INFO: bar"], SimpleLogger1.output
  end

  test "version2" do
    logger = SimpleLogger2.instance
    logger.error("foo")
    SimpleLogger2.instance.info("bar")

    assert_equal ["ERROR: foo", "INFO: bar"], logger.output
  end

end