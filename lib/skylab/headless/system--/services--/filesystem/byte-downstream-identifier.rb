module Skylab::Headless

  class System__::Services__::Filesystem

    class Byte_Downstream_Identifier

      # :+(near [#br-019])

      def initialize path, & oes_p
        @path = path
        @on_event_selectively = oes_p
      end

      # ~ reflection

      def description_under expag
        Headless_.lib_.basic::Pathname.description_under_of_path expag, @path
      end

      def shape_symbol
        :path
      end

      # ~~ off-grid reflection

      attr_reader :path

      # ~ data acceptance exposures

      def to_minimal_yielder  # :+#open-filehandle
        ::File.open @path, ::File::CREAT | ::File::WRONLY # | ::File::EXCL
      end
    end
  end
end
