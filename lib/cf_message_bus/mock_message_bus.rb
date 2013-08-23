module CfMessageBus
  class MockMessageBus
    def initialize(config = {})
      @logger = config[:logger]
      @subscriptions = Hash.new { |hash, key| hash[key] = [] }
      @requests = {}
      @published_messages = []
    end

    def subscribe(subject, opts = {}, &blk)
      @subscriptions[subject] << blk
      subject
    end

    def publish(subject, message = nil, &callback)
      @subscriptions[subject].each { |subscription| subscription.call(message) }

      @published_messages.push({subject: subject, message: message, callback: callback})

      callback.call if callback
    end

    def request(subject, data=nil, options={}, &blk)
      @requests[subject] = blk
      publish(subject, data)
      subject
    end

    def synchronous_request(subject, data=nil, options={})
    end

    def unsubscribe(subscription_id)
      @subscriptions.delete(subscription_id)
      @requests.delete(subscription_id)
    end

    def recover(&block)
      @recovery = block
    end

    def connected?
      true
    end

    def respond_to_request(request_subject, data)
      block = @requests.fetch(request_subject) { lambda { |data| nil } }
      block.call(data)
    end

    def do_recovery
      @recovery.call if @recovery
    end

    def published_messages
      @published_messages
    end

    def clear_published_messages
      @published_messages.clear
    end

    def has_published?(subject)
      @published_messages.find { |message| message[:subject] == subject }
    end

    def has_published_with_message?(subject, message)
      @published_messages.find { |publication| publication[:subject] == subject && publication[:message] == message }
    end
  end
end
