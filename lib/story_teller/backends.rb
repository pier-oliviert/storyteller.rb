class StoryTeller::Backends
  autoload :Stdout, "story_teller/backends/stdout"
  autoload :Rollbar, "story_teller/backends/rollbar"
  autoload :Segment, "story_teller/backends/segment"
end