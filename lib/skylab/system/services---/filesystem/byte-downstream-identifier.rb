module Skylab::System

  class Services___::Filesystem

    class Byte_Downstream_Identifier

      # :+(near [#br-019])

      def initialize path, & oes_p
        @path = path
        @on_event_selectively = oes_p
      end

      # ~ reflection

      def is_same_waypoint_as x
        :path == x.shape_symbol && @path == x.path  # can fail because etc.
      end

      def description_under expag
        System_.lib_.basic::Pathname.description_under_of_path expag, @path
      end

      def EN_preposition_lexeme
      end

      def shape_symbol
        :path
      end

      # ~~ off-grid reflection

      attr_reader :path

      # ~ data acceptance exposures

      def to_minimal_yielder  # :+#open-filehandle  :+[#ba-046]
        ::File.open @path, ::File::CREAT | ::File::WRONLY # | ::File::EXCL
      end
    end
  end
end
