class StoryTeller::Formatters
  # These are autoloaded because it's wasteful to 
  # load all the code for each output if the application
  # is not going to use them.
  autoload :Development, "story_teller/formatters/development"
  autoload :Structured, "story_teller/formatters/structured"
  autoload :Null, "story_teller/formatters/null"

  class Base
    attr_reader :output, :name

    def initialize(name:, output:)
      @name = name
      @output = output
    end

    def replace_output!(new_output)
      @output = new_output
    end

    def write(story)
      raise NotImplementedError
    end
  end
end
