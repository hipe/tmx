module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    Strategies___::Row_Formatter::Models__ = ::Module.new

    class Strategies___::Row_Formatter::Models__::Field

      Callback_::Actor.methodic self

      def some_label
        @label or self._SANITY
      end

      attr_reader(
        :celifier_builder,
        :fill_parts,
        :is_fill,
        :is_right,
        :label,
      )

      def initialize & edit_p

        @_needs_label = true
        instance_exec( & edit_p )
      end

    private

      def celifier_builder=
        @celifier_builder = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def fill=
        @is_fill = true
        st = @polymorphic_upstream_
        @fill_parts = if :parts == st.current_token
          st.advance_one
          st.gets_one
        end
        KEEP_PARSING_
      end

      def label=
        @_needs_label = false
        @label = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def left=
        KEEP_PARSING_
      end

      def right=
        @is_right = true
        KEEP_PARSING_
      end

      # ~ hack methodic's syntax

      def process_polymorphic_stream_passively st

        kp = super
        if kp
          if @_needs_label
            remove_instance_variable :@_needs_label
            @label = st.gets_one
          end
        end
        kp
      end

      def polymorphic_writer_method_name_passive_lookup_proc
        p = super
        -> x do
          if x.respond_to? :id2name
            p[ x ]
          end
        end
      end
    end
  end
end
