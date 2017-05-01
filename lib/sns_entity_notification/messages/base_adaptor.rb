# encoding: utf-8
#
module PushNotification
  module Messages
    class BaseAdaptor
      attr_reader :format, :data

      def initialize(format, data = {})
        raise 'Missing required push notification format' unless format
        @format = format
        @data = data
      end

      def render
        strategy = PushNotification::Messages.const_get(@format.to_s.capitalize).new self
        strategy.execute
      end
    end
  end
end