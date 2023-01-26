class StoryTeller::Backends::Segment
  include StoryTeller::Backend

  def initialize(write_key:)
    on_error = Proc.new do |status, msg|
      StoryTeller.info("An error occurred trying to reach Segment",
                       status: status,
                       message: msg
      )
    end

    @segment = Segment::Analytics.new(write_key: write_key, on_error: on_error)
  end

  def write(message, data: {})
    case data[:type].to_s
    when "track"
      @segment.track(data)
    when "identify"
      @segment.identify(data)
    when "page"
      @segment.page(data)
    when "group"
      @segment.group(data)
    else
      @segment.track(data)
    end
  end
end
