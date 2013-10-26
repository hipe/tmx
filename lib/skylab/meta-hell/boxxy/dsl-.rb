module Skylab::MetaHell

  module Boxxy

    class DSL_

      Autoloader = ::Skylab::Autoloader

      def self.load ; end

      def initialize mod, bxy
        @mod, @bxy = mod, bxy
      end

      def dir_pathname
        @mod.dir_pathname
      end

      def extname
        Autoloader::EXTNAME
      end

      def get_const x
        @mod.const_get x, false
      end

      def original_constants
        @mod.boxxy_original_constants
      end

      def pathify x
        Autoloader::FUN.pathify[ x ]
      end

      def upwards mod
        MetaHell::MAARS::Upwards[ mod ]
      end
    end

    class Boxxy__

      undef_method :dsl

      def dsl blk
        @dsl ||= DSL_.new @mod, self
        @dsl.instance_exec( & blk )
        nil  # ok to open it up when needed
      end
    end
  end
end
