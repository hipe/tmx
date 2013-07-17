module Skylab::TestSupport

  module Quickie

    class Plugin_::Box_

      def initialize host, mod
        @host = host ; @mod = mod
        @a = @h = nil
      end

      def _host  # #hacks-only
        @host
      end

      def ready
        @a ||= Get_const_i_a_[ @mod ].map do |const_i|
          Plugin_::Adapter_.
            new( const_i, @mod.const_get( const_i, false ), self )
        end
        true
      end

      Get_const_i_a_ = -> mod do
        ::Dir[ "#{ mod.dir_pathname }/*#{ Autoloader::EXTNAME }" ].
            reduce [] do |m, path|
          m << Autoloader::Inflection::FUN.constantize[
            ::Pathname.new( path ).basename.sub_ext '' ]
        end
      end

      def _a
        @a
      end

      def keys
        @h.nil? and ready_h
        @h.keys
      end

      def [] i
        @h.nil? and ready_h
        @a.fetch( @h.fetch i )
      end

      #  ~ services that plugins want (this is a line of demarcation) ~

      %i| y paystream program_moniker get_test_path_a |.each do |i|
        define_method i do @host.send i end
      end

      def plugins
        self
      end

    private

      def ready_h  # assume @h is nil
        @h = if ready then
          ::Hash[ @a.each_with_index.map { |x, idx| [ x.plugin_i, idx ] } ]
        else false end
      end
    end
  end
end
