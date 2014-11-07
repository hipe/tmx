module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_file_scan

      Callback_::Actor.methodic self, :simple, :properties,

        :property, :upstream_path_scan,
        :iambic_writer_method_to_be_provided, :ruby_regexp,
        :iambic_writer_method_to_be_provided, :do_highlight,
        :iambic_writer_method_to_be_provided, :read_only,
        :property, :on_event_selectively

      class << self

        def with * x_a
          new do
            process_iambic_fully x_a
          end.execute
        end
      end

      def initialize
        @on_event_selectively = nil
        @currier_x_a = []
        super
        @currier_x_a.push :on_event_selectively, @on_event_selectively
      end
    private

      def ruby_regexp=
        @currier_x_a.push :ruby_regexp, iambic_property
      end

      def do_highlight=
        @currier_x_a.push :do_highlight, iambic_property
      end

      def read_only=
        @currier = Self_::Models__::Read_Only_File_Session
      end

    public

      def execute

        producer = @currier.producer_via_iambic @currier_x_a

        path_count = 0
        @upstream_path_scan.map_reduce_by do |path|
          path_count += 1
          producer.produce_file_session_via_ordinal_and_path path_count, path
        end
      end

      Self_ = self
    end
  end
end
