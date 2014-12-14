module Skylab::BeautySalon

  class Models_::Search_and_Replace

    Autoloader_[ Actors_::Build_file_scan = ::Module.new ]

    class Actors_::Build_file_stream

      Callback_::Actor.methodic self, :simple, :properties,

        :property, :upstream_path_stream,
        :iambic_writer_method_to_be_provided, :property, :ruby_regexp,
        :iambic_writer_method_to_be_provided, :property, :grep_extended_regexp_string,
        :iambic_writer_method_to_be_provided, :property, :do_highlight,
        :iambic_writer_method_to_be_provided, :property, :read_only,
        :iambic_writer_method_to_be_provided, :property, :for_interactive_search_and_replace,
        :iambic_writer_method_to_be_provided, :property, :max_file_size_for_multiline_mode,
        :property, :on_event_selectively

      def initialize
        @on_event_selectively = nil
        @currier_x_a = []
        super
        @currier_x_a.push :on_event_selectively, @on_event_selectively
      end
    private

      def ruby_regexp=
        @currier_x_a.push :ruby_regexp, iambic_property
        KEEP_PARSING_
      end

      def grep_extended_regexp_string=
        @currier_x_a.push :grep_extended_regexp_string, iambic_property
        KEEP_PARSING_
      end

      def do_highlight=
        @currier_x_a.push :do_highlight, iambic_property
        KEEP_PARSING_
      end

      def read_only=
        @currier = Self_::Models__::Read_Only_File_Session
        KEEP_PARSING_
      end

      def for_interactive_search_and_replace=
        @currier = Self_::Models__::Interactive_File_Session
        KEEP_PARSING_
      end

      def max_file_size_for_multiline_mode=
        @currier_x_a.push :max_file_size_for_multiline_mode, iambic_property
        KEEP_PARSING_
      end

    public

      def execute

        producer = @currier.producer_via_iambic @currier_x_a

        path_count = 0
        @upstream_path_stream.map_reduce_by do |path|
          path_count += 1
          producer.produce_file_session_via_ordinal_and_path path_count, path
        end
      end

      KEEP_PARSING_ = true

      Self_ = Actors_::Build_file_scan
    end
  end
end
