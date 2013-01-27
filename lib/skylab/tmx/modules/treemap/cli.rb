require_relative '../../../treemap/core'
require 'skylab/meta-hell/core'

module Skylab
  module Tmx
    module Treemap
    end

    # **ALL** of this is goofing around to see how far we can get etc..
    # it would be totally fine to throw it all away!

    class Treemap::Adapter_Ass < ::Module # yes, subclass module wtf
      def command_tree
        Treemap::Box_Ass.new @box_module
      end
      def new wat_h
        cli = @klass.new nil, wat_h.fetch(:out), wat_h.fetch(:err)
        cli.program_name = wat_h.fetch(:program_name)
        cli
      end
      def initialize klass
        @klass = klass
        @box_module = klass.const_get( :Actions, false )
      end
    end

    module Treemap
      extend ::Skylab::Porcelain
      namespace :'treemap', Treemap::Adapter_Ass.new( ::Skylab::Treemap::CLI )
    end

    class Treemap::Box_Ass < ::Skylab::MetaHell::Formal::Box

      def map
        each.map.to_a
      end

      def initialize mod
        super( )
        @box_module = mod
        mod.constants.each do |x|
          add x, mod.const_get( x , false )
        end
        nil
      end
    end
  end
end
