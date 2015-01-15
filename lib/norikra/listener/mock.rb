require "norikra/listener"
require "json"

module Norikra
  module Listener
    class Mock < Norikra::Listener::Base
      def self.check(query_group_name)
        query_group_name && query_group_name =~ /^MOCK\((\d+)\)$/ && $1
      end

      def initialize(query_name, query_group, events_statistics)
        super
        @repeat = Mock.check(query_group).to_i
      end

      def process_async(events)
        # write events to STDOUT specified times, in background
        events.each do |e|
          @repeat.times do |i|
            STDOUT.puts @query_name + "\t#{i + 1}\t" + JSON.dump(e)
          end
        end
      end
    end
  end
end
