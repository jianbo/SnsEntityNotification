require "sns_entity_notification/version"

module SnsEntityNotification
  extend ActiveSupport::Autoload

  autoload :FeedLog
  autoload :HasChangedNotification

  autoload_under 'message_composer'  do
    autoload :JobVisitMessageComposer
    autoload :RolePermissionMessageComposer
    autoload :UserRoleMessageComposer
    autoload :UserDetailChangeMessageComposer
    autoload :ModelDetailChangesComposer
    autoload :MessageBase
  end

  class << self
    def enabled?
      push_notification_store[:request_enabled_model] == true
    end

    def disable_notification(&block)
      disabled_notification
      block.call
    ensure
      enable_notification
    end

    def push_notification_store
      RequestStore.store[:push_notification_store] ||= { request_enabled_model: true }
    end

    private

    def enable_notification
      push_notification_store[:request_enabled_model] = true
    end

    def disabled_notification
      push_notification_store[:request_enabled_model] = false
    end
  end
end
