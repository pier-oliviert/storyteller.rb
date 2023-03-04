class StoryTeller::Rack < ::ActionDispatch::DebugExceptions
  def call(env)
    request_id = request_id(env)
    request = ActionDispatch::Request.new(env)
    StoryTeller.chapter(title: "path", subject: request.path) do |chapter|
      if request_id.present?
        chapter.attributes["request_id"] = request_id
      end

      _, headers, body = response = @app.call(env)
      if headers["X-Cascade"] == "pass"
        body.close if body.respond_to?(:close)
        raise ActionController::RoutingError, "No route matches [#{env['REQUEST_METHOD']}] #{env['PATH_INFO'].inspect}"
      end

      response
    end
  rescue Exception => exception
    invoke_interceptors(request, exception)
    raise exception unless request.show_exceptions?
    render_exception(request, exception)
  ensure
    ActiveSupport::LogSubscriber.flush_all!
    StoryTeller::Book.clear!

    # This newline output is to separate logs from one action to another.
    # it is only useful in dev to give the user an easier time to browse through
    # their log
    STDOUT << "\n"
  end

  private

  # No-op with StoryTeller. The error is already logged in the chapter defined.
  def log_error(request, wrapper);end

  def request_id(env)
    env["action_dispatch.request_id"] || env["HTTP_X_REQUEST_ID"]
  end
end