
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
      StoryTeller.analytic("purchased.failed",
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

This workflow is spread between a request orchestrated by a user, and a job being dispatched to a sidekiq job. Here's the stories that get generated.

```
{}
{}
{}
```

There are a couple of neat things happening with that. First, even though the whole flow is disconnected, the logs are connected through an implicit chapter generated for you.

Also, chapter are embeddable by default. It's helpful when a request comes in, and the controller's job is to handle more than 1 feature at once. Obviously, when you start working on your project, things are pretty linear, but as projects grow, it often turns out that endpoints get coupled with multiple features.

This is normal, but if you want to organize your logs into subset, you can do so by specifying a chapter.
