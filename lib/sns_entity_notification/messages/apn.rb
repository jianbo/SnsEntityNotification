# encoding: utf-8
#
require 'forwardable'

module PushNotification
  module Messages
    class Apn
      extend Forwardable

      def_delegators :@context, :data

      def initialize(context)
        @context = context
      end

      def notification
        {
            aps: {
                alert: data[:message],
                sound: sound,
                # badge: badge,
                url: data[:url],
                extra: data
            }
        }
      end

      def execute
        {
            default: data[:message],
            APNS_SANDBOX: notification.to_json,
            APNS: notification.to_json
        }
      end

      def sound
        'default'
      end

      def badge

      end
    end
  end
end