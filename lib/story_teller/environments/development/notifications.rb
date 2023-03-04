module StoryTeller::Notifications
  INTERNAL_PARAMS = %w(controller action format _method only_path)
  VIEWS_PATTERN = /^\/app\/views\//

  ActiveSupport::Notifications.subscribe("process_action.action_controller") do |event|
    payload = event.payload
    additions = ::ActionController::Base.log_process_action(payload)
    status = payload[:status]

    if status.nil? && (exception_class_name = payload[:exception]&.first)
      status = ::ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
    end

    color_code = if status > 399
      "\e[1;31m%{status}\e[0m"
    else
      "\e[1m%{status}\e[0m"
    end

    StoryTeller.info(
      "Response: #{color_code} - %{status_code} in %{duration}ms.",
      controller: payload[:controller],
      action: payload[:action],
      allocations: event.allocations,
      status_code: status,
      status: Rack::Utils::HTTP_STATUS_CODES[status],
      duration: event.duration.round,
      duration_explained: additions.join(" | ")
    )
  end

  ActiveSupport::Notifications.subscribe("start_processing.action_controller") do |event|
    payload = event.payload
    params  = payload[:params].except(*INTERNAL_PARAMS)
    format  = payload[:format]
    format  = format.to_s.upcase if format.is_a?(Symbol)
    format  = "*/*" if format.nil?

    StoryTeller.info("Requested %{controller}#%{action} as %{format}",
      controller: payload[:controller],
      action: payload[:action],
      format: format
    )
    StoryTeller.info("Parameters: %{params}", params: params) unless params.empty?
  end

  ActiveSupport::Notifications.subscribe("render_template.action_view") do |event|
    path = event.payload[:identifier]
    if !path.starts_with?(Rails.root.to_s)
      next
    end

    path = path.sub(Rails.root.to_s, "").sub(VIEWS_PATTERN, "")
    StoryTeller.info("Rendered template %{path} in %{duration}ms", 
      path: path,
      duration: event.duration.round(1)
    )
  end

  ActiveSupport::Notifications.subscribe("render_partial.action_view") do |event|
    path = event.payload[:identifier]
    if !path.starts_with?(Rails.root.to_s)
      next
    end

    path = path.sub(Rails.root.to_s, "").sub(VIEWS_PATTERN, "")
    StoryTeller.info("Rendered partial %{path} in %{duration}ms", 
      path: path,
      duration: event.duration.round(1)
    )
  end

  ActiveSupport::Notifications.subscribe("render_collection.action_view") do |event|
    path = event.payload[:identifier]
    if !path.starts_with?(Rails.root.to_s)
      next
    end

    path = path.sub(Rails.root.to_s, "").sub(VIEWS_PATTERN, "")
    StoryTeller.info("Rendered collection of %{size} for %{path} in %{duration}ms", 
      path: path,
      size: event.payload,
      duration: event.duration.round(1)
    )
  end

  ActiveSupport::Notifications.subscribe("render_layout.action_view") do |event|
    path = event.payload[:identifier]
    if !path.starts_with?(Rails.root.to_s)
      next
    end

    path = path.sub(Rails.root.to_s, "").sub(VIEWS_PATTERN, "")
    StoryTeller.info("Rendered layout %{path} in %{duration}ms", 
      path: path,
      duration: event.duration.round(1)
    )
  end

  ActiveSupport::Notifications.subscribe("sql.active_record") do |event|
    payload = event.payload

    if payload[:binds]&.any?
      StoryTeller.info("%{name} (%{duration}ms) %{sql}",
        name: payload[:name],
        duration: event.duration.round(1),
        sql: payload[:sql],
      )
    end
  end

  ActiveSupport::Notifications.subscribe("deliver.action_mailer") do |event|
    perform_deliveries = event.payload[:perform_deliveries]
    if perform_deliveries
      StoryTeller.info("Delivered mail #{event.payload[:message_id]} (#{event.duration.round(1)}ms)")
    else
      StoryTeller.info("Skipped delivery of mail #{event.payload[:message_id]} as `perform_deliveries` is false")
    end
  end

  ActiveSupport::Notifications.subscribe("render.action_mailer") do |event|
    mailer = event.payload[:mailer]
    action = event.payload[:action]
    StoryTeller.info("#{mailer}##{action}: processed outbound mail in #{event.duration.round(1)}ms")
  end

  ActiveSupport::Notifications.subscribe("service_upload.active_storage") do |event|
    message = "Uploaded file to key: #{event.payload[:key]}"
    message += " (checksum: #{event.payload[:checksum]})" if event.payload[:checksum]

    StoryTeller.info "[#{event.payload[:service]} Storage] #{message}", duration: event.duration.round(1)
  end

  ActiveSupport::Notifications.subscribe("service_download.active_storage") do |event|
    StoryTeller.info "[#{event.payload[:service]} Storage] Downloaded file from key: #{event.payload[:key]}"
  end

  ActiveSupport::Notifications.subscribe("service_streaming_download.active_storage") do |event|
    StoryTeller.info "[#{event.payload[:service]} Storage] Downloaded file from key: #{event.payload[:key]}"
  end

  ActiveSupport::Notifications.subscribe("service_delete.active_storage") do |event|
    StoryTeller.info "[#{event.payload[:service]} Storage] Deleted file from key: #{event.payload[:key]}"
  end

  ActiveSupport::Notifications.subscribe("service_delete_prefixed.active_storage") do |event|
    StoryTeller.info "[#{event.payload[:service]} Storage] Deleted files by key prefix: #{event.payload[:prefix]}"
  end

  ActiveSupport::Notifications.subscribe("service_exist.active_storage") do |event|
    StoryTeller.info "[#{event.payload[:service]} Storage] Checked if file exists at key: #{event.payload[:key]} (#{event.payload[:exist] ? "yes" : "no"})"
  end

  ActiveSupport::Notifications.subscribe("service_url.active_storage") do |event|
    StoryTeller.info "[#{event.payload[:service]} Storage] Generated URL for file at key: #{event.payload[:key]} (#{event.payload[:url]})"
  end

  ActiveSupport::Notifications.subscribe("service_mirror.active_storage") do |event|
    message = "Mirrored file at key: #{event.payload[:key]}"
    message += " (checksum: #{event.payload[:checksum]})" if event.payload[:checksum]

    StoryTeller.info "[#{event.payload[:service]} Storage] #{message}"
  end

  ActiveSupport::Notifications.subscribe("enqueue.active_job") do |event|
    job = event.payload[:job]
    exception = event.payload[:exception_object]
    queue_name = event.payload[:adapter].class.name.demodulize.remove("Adapter") + "(#{event.payload[:job].queue_name})"

    if exception
      StoryTeller.info(
        "Failed enqueuing %{job_class} to %{queue_name}",
        job_class: job.class.name,
        queue_name: queue_name
      )
      StoryTeller.error(ex)
    elsif event.payload[:aborted]
      StoryTeller.info(
        "Failed enqueuing %{job_name} to %{queue_name}, a before_enqueue callback halted the enqueuing execution.",
        job_class: job.class.name,
        queue_name: queue_name
      )
    else
      StoryTeller.info(
        "Enqueued %{job_name} (Job ID: %{job_id}) to %{queue_name}",
        job_id: job.job_id,
        job_class: job.class.name,
        queue_name: queue_name
      )
    end
  end

  ActiveSupport::Notifications.subscribe("enqueue_at.active_job") do |event|
    job = event.payload[:job]
    ex = event.payload[:exception_object]
    queue_name = event.payload[:adapter].class.name.demodulize.remove("Adapter") + "(#{event.payload[:job].queue_name})"

    if ex
      StoryTeller.info(
        "Failed enqueuing %{job_class} to %{queue_name}",
        job_class: job.class.name,
        queue_name: queue_name
      )
      StoryTeller.error(StoryTeller::Exception.new(exception: ex))
    elsif event.payload[:aborted]
      StoryTeller.info(
        "Failed enqueuing %{job_class} to %{queue_name}, a before_enqueue callback halted the enqueuing execution.",
        job_class: job.class.name,
        queue_name: queue_name
      )
    else
      StoryTeller.info(
        "Enqueued %{job.class.name} (Job ID: %{job_id}) to %{queue_name} at %{scheduled_at}",
        job_class: job.class.name,
        job_id: job.job_id,
        queue_name: queue_name,
        scheduled_at: Time.at(event.payload[:job].scheduled_at).utc
      )
    end
  end

  ActiveSupport::Notifications.subscribe("perform_start.active_job") do |event|
    job = event.payload[:job]
    StoryTeller.info(
      "Performing %{job_class} (Job ID: %{job_id}) from %{queue_name} enqueued at %{enqueued_at}",
        job_class: job.class.name,
        job_id: job.job_id,
        queue_name: queue_name,
        enqueued_at: job.enqueued_at
    )
  end

  ActiveSupport::Notifications.subscribe("perform.active_job") do |event|
    job = event.payload[:job]
    ex = event.payload[:exception_object]
    queue_name = event.payload[:adapter].class.name.demodulize.remove("Adapter") + "(#{event.payload[:job].queue_name})"
    if ex
      StoryTeller.info("Error performing #{job.class.name} (Job ID: #{job.job_id}) from #{queue_name} in #{event.duration.round(2)}ms")
      StoryTeller.error(StoryTeller::Exception.new(ex))
    elsif event.payload[:aborted]
      StoryTeller.info("Error performing #{job.class.name} (Job ID: #{job.job_id}) from #{queue_name} in #{event.duration.round(2)}ms: a before_perform callback halted the job execution")
    else
      StoryTeller.info("Performed #{job.class.name} (Job ID: #{job.job_id}) from #{queue_name} in #{event.duration.round(2)}ms")
    end
  end

  ActiveSupport::Notifications.subscribe("enqueue_retry.active_job") do |event|
    job = event.payload[:job]
    ex = event.payload[:error]
    wait = event.payload[:wait]

    if ex
      StoryTeller.info(
        "Retrying %{job_class} in %{wait} seconds, due to a %{exception_class}",
        job_class: job.class,
        wait: wait.to_i,
        exception_class: ex.class
      )
    else
      StoryTeller.info(
        "Retrying %{job_class} in %{wait} seconds",
        job_class: job.class,
        wait: wait.to_i
      )
    end
  end

  ActiveSupport::Notifications.subscribe("retry_stopped.active_job") do |event|
    job = event.payload[:job]
    ex = event.payload[:error]

    StoryTeller.error(StoryTeller::Exception(exception: ex))
  end

  ActiveSupport::Notifications.subscribe("discard.active_job") do |event|
    job = event.payload[:job]
    ex = event.payload[:error]

    StoryTeller.error(StoryTeller::Exception(exception: ex))
  end
end