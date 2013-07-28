require 'assess/util/sexpesque'
require 'json'
module Hipe
  module Assess
    class PersistentNode < Sexpesque
      class << self
        # block is called only when create, not get; and must exist
        def exist? path
          File.exist? path
        end
        def get path
          fail("can't get if doesn't exist: #{path}") unless File.exist?(path)
          json = File.read(path)
          struct = JSON.parse(json)
          thing = new(*struct)
          thing.persistent_node_init(path, true, json)
          thing
        end
        def create path
          fail("can't create if exists: #{path}") if File.exist?(path)
          thing = new()
          thing.persistent_node_init(path, false)
          thing
        end
      end
      def persistent_node_init(path, existed, json=nil)
        @before_json = json || JSON.pretty_generate(self)
        @existed = existed
        @path = path
        Kernel.at_exit{ finalize }
      end
      def def! name, &block
        fail("no") unless block
        fail("no") if respond_to?(name)
        class << self; self end.send(:define_method, name, &block)
        nil
      end
    private
      def finalize
        current_json = JSON.pretty_generate(self)
        if current_json != @before_json
          File.open( @path, WRITEMODE_ ){ |fh| fh.write current_json }
          puts("wrote session data to #{@path}")
        end
      end
      WRITEMODE_ = Headless::WRITEMODE_
    end
  end
end
