require "ostruct"

class StoryTeller::Configuration
  attr_reader :middlewares, :levels

  def initialize
    @extensions = []
    @middlewares = OpenStruct.new
    @levels = {
      StoryTeller::Levels::ERROR => StoryTeller::Backends::Stdout,
      StoryTeller::Levels::INFO => StoryTeller::Backends::Stdout,
      StoryTeller::Levels::ANALYTIC => StoryTeller::Backends::Stdout
    }

    if defined?(Rails)
      @extensions << "action_controller"
    end
  end

  def define_levels!
    levels.each_pair do |name, backend|
      if StoryTeller.method_defined?(name.to_sym)
        raise ProtectedNameError, "#{name} cannot be used as a StoryTeller level as a method name already exists"
      end

      StoryTeller.define_method(name.to_sym, backend.new(Rails.env.to_s).instance_method(:write))
    end
  end

  def freeze!
    @backends.freeze!
  end
end
