# Your application has a story to tell

StoryTeller is a library to let you create meaningful messages that tells a story about how your application behave in production. You create "stories" by generating structured logs that shares context. Since this gem is about telling stories, then let's use one to illustrate how using StoryTeller can help you understand what goes on in your application.

```ruby
class PurchaseController < ApplicationController
  around_action do |controller, &action|
    StoryTeller.chapter(title: controller.action_name, subtitle: params[:item_id]) do
      action.call
    end
  end

  def create
    valuable = Valuable.buy(user: current_user, product: Product.find(params[:item_id]))
    if valuable.errors.any?
      StoryTeller.info("purchased.failed",
        user_id: current_user.id
      )
    end
  end
end

class Valuable < ApplicationModel
  def self.buy(user:, product:)
    StoryTeller.info("User: %{user_id} buying %{product_id}",
      user_id: user.id,
      product_id: product.id
    )

    # Your code processing the purchase
  end
end


class SendSomethingValuableJob < ActiveJob
  def perform(valuable_id)
    StoryTeller.chapter(title: self.class.name, subtitle: valuable_id) do
      # Send the valuable and retrieve the URL
      valuable = Valuable.find(valuable_id)

      private_url = Sender.send_valuable(valuable)
      email = Email::Valuable(url: private_url)
      email.send!

      StoryTeller.log("Sending valuable",
        url: private_url
      )
    end
  end
end
```

## Structured Logging, with a little extra


## Logs and Exception, side by side
Most application uses an error logging tool that allows them to track the exception that occurs during the lifetime of an application. However, it's not always easy to map your logs with your error tracking.

By having the logs include your error, you can still use the error logging tool you love, but you can also find a better history as to why that exception rose in the first place. Yes, backtrace are useful, but if you're logging the states of some objects, or the conditions that led to the exception, the error becomes much easier to diagnose.

## Tag logs with chapters
Chapters is how StoryTeller groups logs, and exception, together.

## Built for development, ready for production
Your production logs is most likely ingested, parsed and stored somewhere. For a machine, reading a bunch of JSON output is perfect but for our human eyes, it can be overwhelming. StoryTeller comes with different formatters that allows you to configure the output of your log based on the environment you're in.

The development environment has a bunch of optimization to keep your log readable as you work on your feature. The same log that you generate for yourself in development, is then formatted in production to the format you need it to be.

Same code, different use cases.

StoryTeller come with builtin tools that allow you to get the most out of your log. 

