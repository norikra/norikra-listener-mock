# Norikra::Listener Mocks

This repository is a example of Norikra Listener plugin.

Norikra Listener plugin gem can contain some listener plugins. Listener implementations can be written in Ruby(JRuby).

## Steps to write/release your Listener plugin

1. Install JRuby and Bundler
```
rbenv install jruby-1.7.18
rbenv shell jruby-1.7.18
rbenv rehash
gem install bundler
rbenv rehash
```
2. Generate repository
```
bundle gem norikra-listener-yours
cd norikra-udf-users
rbenv local jruby-1.7.18
```
3. Edit gemspec
  * Add `spec.platform = "java"`
  * Add `norikra` to `spec.add_runtime_dependency`
  * Add `bundler`, `rake` and `rspec` to `spec.add_runtime_dependency`
  * Edit other fields
4. Write Listeners
  * see `Writing Listeners and tests`
5. Run rspecs
```
bundle
bundle exec rspec
```
6. Run norikra-server with your Listener, and test it
```
bundle exec norikra start --more-verbose
```
7. Commit && Plugin release to rubygem.org
```
 # git add && git commit ...
bundle exec rake release
```

## Writing Listeners and tests

Example codes are for `norikra-listener-my_listener`. `my_listener` is an example name, and should be replaced with your own listener name.

At first, add `lib/norikra-listener-my_listener.rb` for loading plugins, which just require `norikra/listener/my_listener`.

```ruby
# lib/norikra-listener-my_listener.rb
require "norikra/listener/my_listener"
```

Listener class implementations should be in `lib/norikra/listener/my_listener.rb`.

```ruby
require "norikra/listener"

module Norikra
  module Listener
    class MyListener < Norikra::Listener::Base
      def self.label
        "MY_NAME"
      end

      def initialize(argument, query_name, query_group)
        super # 3 arguemnts are set to @argument, @query_name and @query_group
        ### TODO: and your own initialization
      end

      def start
        super
        ### TODO: your own startup process if needed
      end

      def shutdown
        ### TODO: your own shutdown process if needed
        super
      end

      ### TODO: your own implementation for sync/async listener
    end
  end
end
```

### Sync or Async

There are 2 types of Norikra listeners, named as Sync listenrs and Async listenrs. Methods implemented decides types of listeners.

* Sync listener
  * method to be implemented: `#process_sync(new_events, old_events)`
  * `#process_sync` called every time when Norikra query produce output records
* Async listener
  * method to be implemented: `#process_async(events)`
  * `#process_async` called once per 0.1 seconds, with output records of that interval

Async listener works very well for many use cases, and are easy to write.

Sync listener is good for these cases:
* You want to deliver events as early as possible
* What you want to do needs previous events (`old_events`)

### `.label` method

`.label` method is needed for both of Sync/Async listeners. Norikra engine determines which listener is used for queries by this method and query group name. Built-in memory pool is used if no listener plugins match or no query group specified.

`.label` MUST return a string, matches to `/^[_A-Z]+$/`.

### Sync Listener

TBD

### Async Listener

TBD

### Listeners with engine/output pool

TBD

### Writing tests

TBD

## TODO

* Listener plugin in Java

## Copyright

* Copyright (c) 2015- TAGOMORI Satoshi (tagomoris)
* License
  * GPL v2
