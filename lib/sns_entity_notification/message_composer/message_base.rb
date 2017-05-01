# encoding: utf-8
#
module PushNotification
  class MessageBase
    MESSAGE_PARTS = [:event, :title, :message]

    def to_json
      {
          title: title,
          type: type,
          message: message
      }
    end
  end
end