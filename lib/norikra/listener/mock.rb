require "norikra/listener"
require "json"

module Norikra
  module Listener
    class Mock < Norikra::Listener::Base
      def self.check(query_group_name)
        query_group_name && query_group_name =~ /^MOCK\((\d+)\)$/ && $1
      end

      attr_accessor :stdout

      def initialize(query_name, query_group, events_statistics)
        super
        @stdout = STDOUT
        @repeat = Mock.check(query_group).to_i
      end

      def process_async(events) # [ [unixtime, {event} ], ...
        # write events to STDOUT specified times, in background
        events.each do |time, e|
          @repeat.times do |i|
            @stdout.puts @query_name + "\t#{i + 1}\t#{Time.at(time)}\t" + JSON.dump(e)
          end
        end
      end
    end
  end
end
