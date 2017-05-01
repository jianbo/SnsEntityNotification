# encoding: utf-8
#
require 'geoop/exceptions'
module PushNotification
  class FeedLog
    attr_accessor :owner_id, :entity_type, :entity_id, :entity, :origin_object

    def initialize(version, owner_id = nil)
      self.origin_object = version
      self.entity_type = version.object_type
      self.entity_id = version.item_id
      self.entity = version.item.try(:to_json)
      self.owner_id = owner_id || version.owner_id
    end

    def get_message_title_and_body(title, body)
      {
          title: title,
          message: body,
          entity_type: entity_type,
          entity_id: entity_id,
          entity: entity
      }
    end

    def messages
      @messages ||= PushNotification.const_get(get_class_type).new(self).message_list
    end

    private

    def get_class_type
      "#{origin_object.try(:item_type).underscore.classify}MessageComposer"
    end
  end
end