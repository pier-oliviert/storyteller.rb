class StoryTeller::Middleware
  def initialize(app)
    @app = app
  end

  def call(env)
    req = ::ActionDispatch::Request.new(env)
    StoryTeller.chapter(title: req.params[:controller], subject: req.params[:action]) do
      @app.call(env)
    end
  end
end

