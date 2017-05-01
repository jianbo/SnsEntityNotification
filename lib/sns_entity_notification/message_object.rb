# encoding: utf-8
#
require 'forwardable'
module PushNotification
  class MessageObject
    extend Forwardable

    attr_reader :message_list

    def self.event_types
      {
          USER_DETAIL_CHANGED:      0,
          COMPANY_DETAIL_CHANGED:   1,
          USER_ROLE_CHANGED:        2,
          ROLE_PERMISSION_CHANGED:  3,
          JOB_DETAIL_CHANGED:       4,
          JOB_DELETED:              5
      }
    end

    def initialize
      @message_list = []
      try(:compose_messages)
    end

    def compose_messages
      raise NotImplementedError
    end
  end
end