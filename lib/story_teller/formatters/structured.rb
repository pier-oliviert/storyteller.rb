class StoryTeller::Outputs::Structured < StoryTeller::Outputs::Base
  def write(story)
    output << story.to_json << "\n"
    if output.respond_to?(:flush)
      output.flush
    end
  end
end