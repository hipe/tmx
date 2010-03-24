require 'assess/util/sexpesque'
require 'json'
module Hipe
  module Assess
    class PersistentNode < Sexpesque
      class << self
        def create_or_get path
          if File.exist? path
            json = File.read(path)
            struct = JSON.parse(json)
            thing = new(*struct)
            thing.init_persistent_node(path, true, json)
            thing
          else
            thing = new()
            thing.init_persistent_node(path, false)
            thing
          end
        end
      end
      def init_persistent_node(path, existed, json=nil)
        @before_json = json || JSON.pretty_generate(self)
        @existed = existed
        @path = path
        Kernel.at_exit{ finalize }
      end
    private
      def finalize
        current_json = JSON.pretty_generate(self)
        if current_json != @before_json
          File.open(@path, 'w+'){|fh| fh.write(current_json)}
          puts("wrote session data to #{@path}")
        end
      end
    end
  end
end
