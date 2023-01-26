module StoryTeller::ActionController
  around_action do |controller, &action|
    StoryTeller.chapter(title: controller.name, subtitle: controller.action_name) do |attributes|
      if controller.env.key?("X-Request-ID")
        attributes[:request_id] = controller.env["X-Request-ID"]
      end

      StoryTeller.tell(
        "%{request_method} %{request_path}",
        request_method: request.raw_request_method,
        request_path: request.filtered_path,
        remote_ip: request.remote_ip
      )

      yield
    end
  end
end
