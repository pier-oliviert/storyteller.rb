module StoryTeller
  module Version
    module_function

    MAJOR = 0
    MINOR = 0
    PATCH = 1

    def to_s
      [MAJOR, MINOR, PATCH].join(".")
    end
  end
end
