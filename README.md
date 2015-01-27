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
        "MY_NAME" # label must matches pattern /^[_A-Z]+$/
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

This listener is applied for query group name `MY_NAME(...)`. Argument string in the parenthesis will be set in `@argument`.

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

For sync listener plugins, add `#process_sync` instance method with 2 arguments.

```ruby
  def process_sync(news, olds)
    news.each do |event|
      # query_group: MY_NAME(DESTINATION)
      send_to_anywhere_specified_by_argument(@argument, query_name: @query_name, event: event)
    end
  end
```

Query output events for latest view are in `news` as Array of Hash objects, and events of previous view are in `olds`.

Norikra engine calls `#process_sync` per every query output timing. `#process_sync` should return as soon as possible. Use async listener for output methods with large latency.

### Async Listener

Async listener is to send events over large delay, or as batch writing. Add `#process_async` with 1 argument.

```ruby
  def process_async(events)
    events.each do |event|
      # query_group: MY_NAME(DESTINATION)
      send_to_anywhere_specified_by_argument(@argument, query_name: @query_name, event: event)
    end
  end
```

`events` is an Array of Hash events, which contain all output events between async calls of `#process_async`. This method is called per 0.1 seconds in default (plugin can overwrite this interval by setting `@async_interval` in `#initialize`).

```ruby
  def initialize(argument, query_name, query_group)
    super
    @async_interval = 1 # 1 #process_async call per 1 second
  end
```

### Listeners with engine/output pool

Norikra engine assigns its engine itself and output memory pool in `@engine` and `@output_pool` of listener plugins if `#engine=` or/and `#output_pool=` methods are defined.

```ruby
require "norikra/listener"

module Norikra
  module Listener
    class MyListener < Norikra::Listener::Base
      def self.label
        "MY_NAME"
      end

      attr_writer :engine # this defines #engine=
      attr_writer :output_pool # this defines #output_pool=

      def process_sync(news, olds)
        # use @engine and/or @output_pool here!
      end
    end
  end
end
```

**WARNING: Using engine/output_pool can break Norikra itself very easily!**

* engine
  * instance of Norikra::Engine, to re-send query output events into specified target
  * `@engine.send(TARGET_NAME, events)`
  * use engine to make plugins like `LOOPBACK()` with some data transformations
* output_pool
  * instance of Norikra::OutputPool, to store events in memory store to be fetched by HTTP API (or CLI)
  * `@output_pool.push(@query_name, modified_query_group, events)`
  * use output_pool to make plugins just as same with default output of queries, with some data transformations
  * `modified_query_group` may be `@query_group`, or modified query group value, or just `@argument`

### Writing tests

There're no special topic to write tests. Write simple tests with rspec3.

```ruby
require 'norikra/listener/my_listener'

describe Norikra::Listener::MyListener do
  it 'works well' # TODO: write!
end
```

Norikra has some classes to stub engine and output_pool.

```ruby
require 'norikra/listener_spec_helper'
include Norikra::ListenerSpecHelper

dummy_engine = DummyEngine.new
dummy_pool = DummyOutputPool.new

listener_instance = Norikra::Listener::MyListener.new('argument', 'query_name', 'MY_LISTENER(argument)')
listener_instance.engine = dummy_engine
listener_instance.output_pool = dummy_pool

# re-send events to engine in listener

expect(dummy_engine.events).to eql([events_tobe_sent])

# store events into output pools in listener

expect(dummy_pool.pool['query_group']['query_name']).to eql([events_tobe_stored])
```

## TODO

* Listener plugin in Java

## Copyright

* Copyright (c) 2015- TAGOMORI Satoshi (tagomoris)
* License
  * GPL v2
