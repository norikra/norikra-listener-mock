require "norikra/listener"
require "json"

module Norikra
  module Listener
    class Mock < Norikra::Listener::Base
      def self.label
        "MOCK"
      end

      def initialize(argument, query_name, query_group)
        super
        @stdout = STDOUT
      end

      def process_sync(news, olds)
        news.each do |event|
          @stdout.puts "#{@query_name}\t#{@argument}\t" + JSON.dump(event)
        end
      end
    end

    class MockAsync < Norikra::Listener::Base
      def self.label
        "MOCK_ASYNC"
      end

      attr_accessor :stdout

      def initialize(argument, query_name, query_group)
        super
        @stdout = STDOUT
        @repeat = @argument.to_i
      end

      def process_async(events) # [ [unixtime, {event} ], ...
        # write events to STDOUT specified times, in background
        events.each do |time, e|
          @repeat.times do |i|
            @stdout.puts "#{@query_name}\t#{i + 1}\t#{Time.at(time)}\t" + JSON.dump(e)
          end
        end
      end
    end
  end
end
