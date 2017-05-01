# encoding: utf-8
#
# This module is to be included into Device class, and expect device to have
# valid device_uuid (device token) endpoint_arn AWS SNS arn
#
# class Device
#   include PushNotification::Client
# end
# device = Device.find(1)
# device.send_notification('message')
#
# data = {
#   user_id: 1,
#   os_family: 'Android',
#   os_version: 'iOS6'
#   ..
# }
#
# To createa a device
# Device.create_device!({
#            device: 'Android',
#            device_token: 'device_token',
# })
#
# Custom sns message protocols
# http://docs.aws.amazon.com/sns/latest/dg/mobile-push-send-custommessage.html

module PushNotification
  module DeviceConcerns
    extend ActiveSupport::Concern
    DEVICE = ['android', 'ios']

    class_methods do
      def get_arn(device)
        device = device.downcase
        raise 'Required valid device e.g. android, ios' unless DEVICE.include?(device)
        case device
          when 'android' then Figaro.env.aws_sns_gcm
          when 'ios' then Figaro.env.aws_sns_apn
          else nil
        end
      end


      def remove_device!(device_token)
        destroyed = ::Device.where(device_uuid: device_token).destroy_all
        destroyed.length
      end


      def create_device!(device_options, data = {}, sns_options = {})
        raise 'Missing required device type' unless device_options[:device]
        raise 'Missing required device token' unless device_options[:device_token]
        arn = get_arn(device_options[:device])
        raise 'Invalid aws sns arn' unless arn
        sns = Aws::SNS::Client.new(sns_options)
        endpoint = sns.create_platform_endpoint(
            platform_application_arn: arn,
            token: device_options[:device_token]
        )
        raise 'Unable to generate sns arn, please try again' unless endpoint[:endpoint_arn]
        ::Device.create!(data.merge(device_uuid: device_options[:device_token],
                                    endpoint_arn: endpoint[:endpoint_arn],
                                    device: device_options[:device]))
      end
    end

    def send_notification(message, url = nil, data = {}, sound = 'default', badge = 1)
      raise 'Missing required arn endpoint' unless self.try(:endpoint_arn)
      get_sns_client.publish(target_arn: self.try(:endpoint_arn),
                             message: PushNotification::Messages::BaseAdaptor.new(get_message_type, message).render.to_json,
                             message_structure: 'json')
    end

    private

    def get_sns_client
      @sns_client ||= Aws::SNS::Client.new
    end

    def get_message_type
      case device.downcase
        when 'ios'
          return :apn
        when 'android'
          return :gcm
        else
          :unknow
      end
    end
  end
end