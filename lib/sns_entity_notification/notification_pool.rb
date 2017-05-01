module SnsEntityNotification
  class NotificationPool
    attr_accessor :message_list, :batched_message_list

    def self.batch_process(message_list, options = {})
      @pool = self.new(message_list, options)
      @pool.process_messages
    end

    def initialize(message_list, options)
      @message_list = message_list
      @options = options
      @batched_message_list = []
      @recipients = options[:recipients] if options[:recipients].present?
    end

    def process_messages
      recipients.each do |device_id|
        send_to_device([device_id], get_batched_message(device_id))
      end
    end

    private

    def send_to_device(device_ids, message)
      SnsEntityNotification::ModelChangedNotificationWorker.
          perform_async(device_ids, message.to_json)
    end

    def get_batched_message(device_id)
      messages = get_messages_by_device_id(device_id)
      message = messages.first.clone
      message.ids = messages.map { |message| message.ids }.flatten.uniq
      message.type = @options[:type] if @options[:type]
      message
    end

    def get_messages_by_device_id(id)
      list = @message_list.select { |message| message.recipients.include?(id)  }
      raise 'Unable to find device id from notification pool' if list.empty?
      list
    end

    def recipients
      @recipients ||= @message_list.map { |message| message.recipients }.flatten.uniq
    end
  end
end