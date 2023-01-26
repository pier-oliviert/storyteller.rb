module StoryTeller
  module Version
    module_function

    MAJOR = 0
    MINOR = 1

    def to_s
      [MAJOR, MINOR].join(".")
    end
  end
end
