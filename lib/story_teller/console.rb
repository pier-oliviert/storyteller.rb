module StoryTeller::Console
  def start
    StoryTeller.chapter(title: "console_user", subject: ENV["LOGNAME"]) do
      super
    end
  end
end
