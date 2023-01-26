class StoryTeller::Backends::Rollbar
  include StoryTeller::Backend

  def write(error, **data)
    Rollbar.error(error, data)
  end
end
