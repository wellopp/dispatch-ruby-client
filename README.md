# Dispatch

The Dispatch gem is used to slot in to a rails app and handle the app-to-Dispatch communication needed to manage SMS and email messaging for Wellopp.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dispatch', git: 'git://github.com/wellopp/dispatch-ruby-client.git'
```

## Usage

First, configure the app your code represents and the dispatch endpoint you're hitting.

```ruby
Dispatch.config do |c|
  c.key = 'randomly generated api key'
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

