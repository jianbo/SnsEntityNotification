module SnsEntityNotification
  class ModelDetailChangesMessage < MessageBase
    attr_accessor :message, :title, :type, :changes, :ids, :entity, :recipients

    def initialize(type, title, message, changes, ids, entity, recipients = [])
      self.type = type
      self.message = message
      self.title = title
      self.changes = changes
      self.ids = ids || []
      self.entity = entity
      self.recipients = recipients
    end

    def to_json
      super.merge(changes: changes, ids: ids, entity: entity)
    end
  end

  class ModelDetailChangesComposer < MessageObject
    def initialize(message_data)
      @message_data = message_data
      super()
    end

    def changed_at
      previous_changes[:updated_at][1] if previous_changes and previous_changes[:updated_at]
    end

    def compose_messages
      self.message_list << SnsEntityNotification::ModelDetailChangesMessage.new(
          @message_data[:event],
          @message_data[:title],
          @message_data[:message],
          @message_data[:changes],
          @message_data[:ids],
          @message_data[:entity],
          @message_data[:recipients]
      )
    end
  end
end