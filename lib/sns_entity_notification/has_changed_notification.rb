# encoding: utf-8
#
module PushNotification
  module HasChangedNotification
    extend ActiveSupport::Concern

    included do
      after_commit :send_changed_notification
    end

    class_methods do
      def has_changed_notification(option={}, &block)
        option[:composer] ||= PushNotification::ModelDetailChangesComposer
        instance_variable_set(:@_notification_composer, option[:composer]) if option[:composer]
        instance_variable_set(:@_get_recipient, option[:recipients]) if option[:recipients]
        if block_given?
          self.instance_eval &block
        end
      end

      def set_message_details(&block)
        raise 'Missing required block' unless block_given?
        @_message_details_lambda = block
      end

      def message_details_lambda
        @_message_details_lambda
      end

      def notification_composer
        @_notification_composer
      end
    #   class methods end
    end

    def get_push_notification_messages
      message_list_composer(:changes).message_list
    end

    protected

    def send_changed_notification
      return if !PushNotification.enabled? || get_recipient_devices.empty?
      message_list_composer.message_list.each do |message|
        PushNotification::ModelChangedNotificationWorker.
            perform_async(get_recipient_devices.to_a.map(&:id), message.to_json)
      end
    end

    def message_list_composer(context = :after_commit)
      self.class.base_class.notification_composer.new(message_data(context))
    end

    def message_data(context)
      {
          event: get_message_detail(:event),
          title: get_message_detail(:title),
          message: get_message_detail(:message),
          changes: changes_data(context),
          ids: [id],
          entity: self.class.name,
          recipients: get_recipient_devices.to_a.map(&:id)
      }
    end

    def get_changed_notification_composer
      self.class.instance_variable_get(:@_notification_composer).to_s
    end

    def get_recipient_devices
      _r = self.class.base_class.instance_variable_get(:@_get_recipient)
      @_recipient_devices ||= _r.call(self) if _r
    end

    def changes_data(context)
       case context
         when :after_commit
           previous_changes
         when :changes
           changes
        end
    end

    def get_message_detail(type)
      raise 'Invalid get type' unless PushNotification::MessageBase::MESSAGE_PARTS.include?(type)
      message_body[type]
    end

    private

    def message_body
      lambda = self.class.base_class.message_details_lambda
      return {} unless lambda.respond_to? :call
      @message_body ||= lambda.call(self)
    end
  end
end