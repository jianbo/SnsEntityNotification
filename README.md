# SnsEntityNotification

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/sns_entity_notification`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sns_entity_notification'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sns_entity_notification

## Usage

      This module is to be included into Device class, and expect device to have
      valid device_uuid (device token) endpoint_arn AWS SNS arn

      class Device
        include PushNotification::Client
      end
      device = Device.find(1)
      device.send_notification('message')

      data = {
        user_id: 1,
        os_family: 'Android',
        os_version: 'iOS6'
        ..
      }

      To createa a device
      Device.create_device!({
                 device: 'Android',
                 device_token: 'device_token',
      })

      Custom sns message protocols
      http://docs.aws.amazon.com/sns/latest/dg/mobile-push-send-custommessage.html

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sns_entity_notification.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

