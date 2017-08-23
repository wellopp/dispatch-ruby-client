# Dispatch

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/dispatch`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dispatch', git: 'git://github.com/wellopp/dispatch-ruby-client.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dispatch

## Usage

First, configure the app your code represents and the dispatch endpoint you're hitting.

```ruby
Dispatch.config do |c|
  c.app = :my_app
  c.endpoint = 'http://localhost:3000'
end
```

Then, send a text message or email.

```ruby
Dispatch.sms(to: '555-234-1234', body: 'Hey, there!')
# => #<Dispatch::Delivery>

Dispatch.email(to: { name: 'Jacob', email: 'jacob@wellopp' },
               body: 'mandrill-template-slug',
               data: {
                 merge_data: 'This key-value pair will be interpolated into the template'
               })
# => #<Dispatch::Delivery>
```

Dispatch will raise a couple different types of exceptions.

```ruby
Dispatch::EmptyArgumentError
Dispatch::InvalidArgumentError

begin
  Dispatch.sms(to: nil, body: 'Hello')
rescue Dispatch::ArgumentError => e
  e.attribute # => :to
  e.value # => nil
  e.message # => "To cannot be empty, but nil was provided"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/dispatch.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
