require 'forwardable'
module SnsEntityNotification
  module Messages
    class Gcm
      extend Forwardable

      def_delegators :@context, :data

      def initialize(context)
        @context = context
      end

      def notification
        {
            data: {
                default: data[:message],
                message: data,
                url: data[:url]
            }
        }
      end

      def execute
        {
            default: data[:message],
            GCM: notification.to_json
        }
      end
    end
  end
end