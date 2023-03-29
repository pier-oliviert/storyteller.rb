module StoryTeller
  # Logger is a helper class to allow
  # libraries and application to use StoryTeller
  # through.

  # This also includes a bunch of hacks that makes
  # sure the logger behaves with rails.
  class Logger < ::Logger
    def initialize(formatter:, log_level: ::Logger::DEBUG)
      @formatter = formatter
      @logdev = self
      self.level = log_level
    end

    def add(severity, message = nil, progname = nil)
      return if severity < self.level

      data = {severity: format_severity(severity)}

      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
        end
      end

      @formatter.write(StoryTeller::Story.new(message: message.to_s, **data))

      nil
    end

    def silence(*args)
      if block_given?
        yield
      end
    end

    # This is not used and is only needed
    # so ActiveSupport doesn't extend this Logger
    # with other method like it does here:
    # https://github.com/rails/rails/blob/fad0c6b899ba786994c506f11f587e29d7bf9c2d/activesupport/lib/active_support/logger.rb#L16-L20
    # https://github.com/rails/rails/blob/25d52ab782623e59c0bc920076393d1691999e4e/activerecord/lib/active_record/railtie.rb#L66
    # https://github.com/rails/rails/blob/1bb9f0e616fb60a9cc1ea67c9bbdb49b2e18835a/railties/lib/rails/commands/server/server_command.rb#L84
    def dev
      STDOUT
    end

    def <<(msg)
      self.add(Logger::DEBUG, msg)
    end

    # Following methods have an effect on the Logger but don't within StoryTeller.
    def reopen(logdev = nil);
      self
    end

    def close
      nil
    end
  end
end