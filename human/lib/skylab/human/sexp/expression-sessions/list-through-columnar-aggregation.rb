module Skylab::Human

  module Sexp

    class Expression_Sessions::List_through_ColumnarAggregation < ::Module  # see [#055]

      Attributes_actor_[ self ]

      # Entity_.event.selective_builder_sender_receiver self

      class << self

        def expression_via_sexp_stream_ st
          new.__init_and_produce_via_etc st
        end

        private :new
      end  # >>

      def initialize
        @ok = true
        @nucleus = Nucleus__.new
      end

      Nucleus__ = ::Struct.new(
        :name_i_a,
        :field_box,
        :frame,
        :template,
        :do_frame_redundancy,
        :do_field_redundancy,
        :do_field_aggregation,
        :on_zero_items_p )

      def __init_and_produce_via_etc st

        _ok = process_polymorphic_stream_fully st
        _ok && self
      end

    private

      def on_zero_items=
        @nucleus.on_zero_items_p = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def template=

        @nucleus.template = Home_.lib_.basic::String.template.via_string(
          gets_one_polymorphic_value )

        via_template_parse_remainder_of_polymorphic_stream polymorphic_upstream
      end

      def via_template_parse_remainder_of_polymorphic_stream st

        bx = Common_::Box.new

        @nucleus.template.to_parameter_occurrence_stream.each do |occu|
          bx.add occu.name_symbol, Behaviors___.new( occu )
        end

        @nucleus.field_box = bx
        @nucleus.name_i_a = bx.get_names.freeze
        via_template_variables_parse_remainder_of_polymorphic_stream st
      end

      def via_template_variables_parse_remainder_of_polymorphic_stream st
        bx = @nucleus.field_box
        while st.unparsed_exists
          field = bx[ st.current_token ]
          field or break when_extra_field_template_variables
          st.advance_one
          field.process_iambic_passively_via_st st
          if field.does_frame_redundancy
            @nucleus.do_frame_redundancy = true
          end
          if field.does_field_redundancy
            @nucleus.do_field_redundancy = true
          end
          if field.does_field_aggregation
            @nucleus.do_field_aggregation = true
          end
          field.cleanup_after_scan
        end
        @ok and begin
          when_parsed_fields_OK
        end
      end

      def when_extra_field_template_variables

        _ev = build_not_OK_event_with :extra_properties,
            :name_i_a, [ current_iambic_token ],
            :expecting_i_a, @nucleus.name_i_a,
            :error_category, :argument_error do |y, o|

          s_a = o.name_i_a.map do |i|
            ick i
          end

          _s_a_ = o.expecting_i_a.map do |i|
            code i
          end

          y << "unrecognized #{ plural_noun s_a.length, 'template variable' }#{
            } #{ and_ s_a }"
          y << "did you mean #{ or_ _s_a_ }?"
        end
        receive_extra_values_event _ev  # #hook-in (local)
      end

      def when_parsed_fields_OK
        _ = Aggregator_Maker__.new @nucleus
        const_set :Aggregator_Maker__, _
        KEEP_PARSING_
      end

    public

      def field_i_a  # :+#public-API
        @nucleus.name_i_a
      end

      class Behaviors___

        def initialize tparam
          @aggregate_p = nil
          @tparam = tparam
        end

        def process_iambic_passively_via_st st
          process_polymorphic_stream_passively st
          nil
        end

        include Home_.lib_.fields::Attributes::Lib::Polymorphic_Processing_Instance_Methods

      private

          def aggregate=
            @does_field_aggregation = true
            @aggregate_p = gets_one_polymorphic_value
            KEEP_PARSING_
          end

          def on_first_mention=
            @does_field_redundancy = true
            @when_field_value_count_is_one_p = gets_one_polymorphic_value
            KEEP_PARSING_
          end

          def on_subsequent_mentions=
            @does_field_redundancy = true
            @when_field_value_count_is_two_or_more_p = gets_one_polymorphic_value
            KEEP_PARSING_
          end

          def on_subsequent_mentions_of=
            st = polymorphic_upstream
            i = st.current_token
            case i
            when :frame
              st.advance_one
              @does_frame_redundancy = true
              @when_frame_value_count_is_two_or_more_p = st.gets_one
              KEEP_PARSING_
            when :field
              st.advance_one
              @does_field_redundancy = true
              @derivative_of_field_i = st.gets_one
              @when_field_value_count_is_two_or_more_p = st.gets_one  # BE CAREFUL
              KEEP_PARSING_
            else

              _ev = Home_.lib_.fields::Events::Extra.build(
                [i], [:frame, :field] )

              receive_extra_values_event _ev  # #hook-in (local)
            end
          end

        public

        attr_reader :aggregate_p,
          :derivative_of_field_i,
          :does_frame_redundancy,
          :does_field_redundancy,
          :does_field_aggregation,
          :when_frame_value_count_is_two_or_more_p,
          :when_field_value_count_is_one_p,
          :when_field_value_count_is_two_or_more_p

        def name_symbol
          @tparam.name_symbol
        end

        def cleanup_after_scan
          @scanner = nil
        end
      end

      def map_reduce_under scn
        aggregator = const_get( :Aggregator_Maker__, false ).produce
        p = -> do
          if aggregator.output_now
            aggregator.flush_now
          else
            while true
              even_x_a = scn.gets
              even_x_a or break
              aggregator.receive_even_iambic even_x_a
              if aggregator.output_now
                break
              end
            end
            aggregator.flush
          end
        end
        Common_::Scn.new do
          p[]
        end
      end

      class Aggregator_Maker__ < ::Module

        def initialize nucleus
          @nucleus = nucleus
          _cls = Frame__.new( * @nucleus.name_i_a )
          _cls.include Frame_IM__
          const_set :Frame___, _cls
          @nucleus.frame = _cls
        end

        def produce
          Aggregator__.new @nucleus
        end
      end

      Frame__ = ::Class.new ::Struct

      module Frame_IM__
        attr_accessor :_number_of_times_repeated_with_this_identity
      end

      class Aggregator__

        def initialize nucleus
          @nucleus = nucleus
          @entire_frame_value_count_h = ::Hash.new { |h, x| h[ x ] = 0 }
          @iframe_count = 0 ; @did_zero = false
          @output_now = @do_single = @queue = @afield = false
          @number_of_fields = @nucleus.name_i_a.length
          @reducer = Reducer__.new @nucleus
        end

        attr_reader :output_now

        def receive_even_iambic x_a
          init_iframe_via_event_iambic x_a
          d = @entire_frame_value_count_h[ @iframe ] += 1
          if 1 == d
            when_unique
          else
            when_repeated d
          end ; nil
        end

      private

        def init_iframe_via_event_iambic x_a
          @iframe = @nucleus.frame.new
          @iframe_count += 1
          x_a.each_slice 2 do |i, x|
            @iframe[ i ] = x
          end ; nil
        end

        def when_repeated d
          if @nucleus.do_frame_redundancy
            will_output_repeated d
          end ; nil
        end

        def will_output_repeated d
          @iframe._number_of_times_repeated_with_this_identity = d - 1
          will_output_now ; nil
        end

        def when_unique
          if @nucleus.do_field_aggregation
            when_aggregate
          elsif @nucleus.do_field_redundancy
            will_output_now
          else
            will_output_now
          end
        end

        def when_aggregate
          @queue ||= []
          case 1 <=> @queue.length
          when  1 ; when_first_frame
          when  0 ; when_second_frame
          when -1 ; when_nth_frame
          end ; nil
        end

        def when_first_frame
          # when looking for aggregation, always we store this "first" frame,
          # never do we output it right away. we need something to aggregate!
          @queue.push @iframe
          @iframe = nil
        end

        def when_second_frame
          @same_i_a = any_same_i_a @iframe
          if @same_i_a
            when_some_same_on_second_frame
          else
            when_none_same_on_second_frame
          end
        end

        def when_nth_frame
          @same_i_a_ = any_same_i_a @iframe
          if @same_i_a_
            when_some_same_on_nth_frame
          else
            when_none_same_on_nth_frame
          end
        end

        def any_same_i_a frame_
          same_i_a = nil
          frame = @queue.first
          scn = @nucleus.field_box.to_pair_stream
          while pair = scn.gets
            _fld_NOT_USED, i = pair.to_a
            x = frame[ i ]
            x_ = frame_[ i ]
            if x == x_
              same_i_a ||= []
              same_i_a.push i
            end
          end
          same_i_a
        end

        def when_some_same_on_second_frame  # :#310
          @is_repeated_h = ::Hash[ @same_i_a.map { |i| [ i, true ] } ]
          scn = @nucleus.field_box.to_value_minimal_stream
          agg_fld_a = []
          while fld = scn.gets
            @is_repeated_h[ fld.name_symbol ] and next
            if fld.does_field_aggregation
              agg_fld_a.push fld
            else
              had_non_aggregating_field = true
              break
            end
          end
          @afield = nil
          if had_non_aggregating_field
            when_none_same_on_second_frame
          elsif 1 == agg_fld_a.length
            @afield = agg_fld_a.fetch 0
            @queue.push @iframe
          else
            when_none_same_on_second_frame
          end ; nil
        end

        def when_none_same_on_second_frame
          swap = @iframe
          @iframe = @queue.fetch 0
          @queue[ 0 ] = swap
          will_output_now ; nil
        end

        def when_some_same_on_nth_frame
          if @same_i_a == @same_i_a_
            @queue.push @iframe
          else
            when_dissimilar_same_on_nth_frame
          end ; nil
        end

        def when_dissimilar_same_on_nth_frame
          @output_now = true
          @do_single = false
          @now_queue = @queue ; @now_afield = @afield ; @afield = nil
          @queue = [ @iframe ] ; nil
        end

        def when_none_same_on_nth_frame
          @output_now = true
          @do_single = false
          @now_queue = @queue ; @now_afield = @afield ; @afield = nil
          @queue = [ @iframe ] ; nil
        end

        def will_output_now
          @output_now = true
          @do_single = true
          @single = @iframe
          @iframe = nil
        end

      public

        def flush
          if @output_now
            flush_now
          elsif @queue && @queue.length.nonzero?
            via_queue_flush
          elsif @iframe_count.zero? && ! @did_zero
            @did_zero = true
            @reducer.when_zero
          end
        end

        def flush_now
          @output_now = false
          if @do_single
            x = @reducer.produce_output_via_single @single
            @single = nil
          else
            x = @reducer.produce_output @now_queue, @now_afield
            @now_queue = @now_afield = nil
          end
          x
        end

     private

        def via_queue_flush
          x = @reducer.produce_output @queue, @afield
          @queue.clear ; @same_i_a = nil
          x
        end
      end

      class Reducer__

        def initialize nucleus
          @nucleus = nucleus
          @field_value_count_h = ::Hash.new do |h, i|
            h[ i ] = ::Hash.new { |h_, x| h_[ x ] = 0 }
          end
        end

        def produce_output_via_single frame
          otr = dup
          otr.init_via_one frame
          otr.execute
        end

        def produce_output frame_a, afield
          otr = dup
          otr.init_via_two frame_a, afield
          otr.execute
        end

        def when_zero
          @p = @nucleus.on_zero_items_p
          @p && via_proc_zero
        end

      protected

        def init_via_one frame
          @do_single = true
          @oframe = frame ; nil
        end

        def init_via_two frame_a, afield
          @do_single = false
          @frame_a = frame_a
          @afield = afield ; nil
        end

        def execute
          if @do_single
            via_oframe
          else
            via_frames
          end
        end

      private

        def via_frames
          if 1 == @frame_a.length
            @oframe = @frame_a.first
            via_oframe
          else
            via_aggregate
          end
        end

        def via_oframe
          if @oframe._number_of_times_repeated_with_this_identity
            via_redundant_oframe
          else
            via_unique_oframe
          end
        end

        def via_redundant_oframe
          @subs_h = {}
          scn = @nucleus.field_box.to_value_minimal_stream
          while @fld = scn.gets
            @p = @fld.when_frame_value_count_is_two_or_more_p
            if @p
              via_proc_substitute_value
            else
              via_passthru_increment_and_substitute_value
            end
          end
          @nucleus.template.call @subs_h
        end

        def via_aggregate
          @oframe = @frame_a.fetch 0
          @subs_h = {} ; @derivative_p_a = false  # #experiment 1 of 2
          scn = @nucleus.field_box.to_value_minimal_stream
          agg_i = @afield.name_symbol
          while @fld = scn.gets
            if agg_i == @fld.name_symbol
              @p = @afield.aggregate_p
              @x = @frame_a.map { |frame| frame[ agg_i ] }
              via_proc_and_value_substitute_value
            else
              via_field_substitute_value
            end
          end
          @derivative_p_a and flush_derivatives
          @nucleus.template.call @subs_h
        end

        def via_unique_oframe
          @subs_h = {} ; @derivative_p_a = false  # #experiment 2 of 2
          scn = @nucleus.field_box.to_value_minimal_stream
          while @fld = scn.gets
            via_field_substitute_value
          end
          @derivative_p_a and flush_derivatives
          @nucleus.template.call @subs_h
        end

        def via_field_substitute_value
          if @fld.derivative_of_field_i
            derivative_field_will_substitute_value
          elsif @fld.does_field_redundancy
            via_field_with_redundancy_sensitivity_substitute_value
          else
            via_passthru_increment_and_substitute_value
          end ; nil
        end

        def via_field_with_redundancy_sensitivity_substitute_value
          via_field_increment_and_resolve_value_count
          via_value_count_resolve_proc
          if @p
            via_proc_substitute_value
          else
            via_passthru_increment_and_substitute_value
          end ; nil
        end

        def derivative_field_will_substitute_value
          false == @derivative_p_a and @derivative_p_a = []
          _FIELD_ = @fld
          @derivative_p_a.push -> do
            process_derivative_field _FIELD_
          end ; nil
        end

        def flush_derivatives
          @derivative_p_a.each do |p|
            p.call
          end
          @derivative_p_a = nil
        end

        def process_derivative_field field
          @fld = field
          remote_i = @fld.derivative_of_field_i
          remote_x = @oframe[ remote_i ]
          @value_count = @field_value_count_h.fetch( remote_i ).fetch( remote_x )
          via_value_count_resolve_proc
          if @p
            @x = remote_x
            via_proc_and_value_substitute_value
          else
            via_nil_sustitute_value
          end ; nil
        end

        def via_value_count_resolve_proc
          @p = if 1 == @value_count
            @fld.when_field_value_count_is_one_p
          else
            @fld.when_field_value_count_is_two_or_more_p
          end ; nil
        end

        def via_proc_zero
          @p[ @y=[] ]
          if @y.length.nonzero?
            @y * EMPTY_S_
          end
        end

        def via_proc_substitute_value
          @x = @oframe[ @fld.name_symbol ]
          via_proc_and_value_substitute_value ; nil
        end

        def via_proc_and_value_substitute_value
          @p[ @y=[], @x ]
          via_yielded_array_substitute_value ; nil
        end

        def via_yielded_array_substitute_value
          if @y.length.zero?
            via_nil_sustitute_value
          else
            @subs_h[ @fld.name_symbol ] = @y * EMPTY_S_
          end ; nil
        end

        def via_passthru_increment_and_substitute_value
          via_field_increment_value_count
          @subs_h[ @fld.name_symbol ] = @oframe[ @fld.name_symbol ]
          nil
        end

        def via_field_increment_and_resolve_value_count
          @value_count = via_field_produce_incremented_value_count ; nil
        end

        def via_field_increment_value_count
          via_field_produce_incremented_value_count ; nil
        end

        def via_field_produce_incremented_value_count
          fld_i = @fld.name_symbol
          _x = @oframe[ fld_i ]
          @field_value_count_h[ fld_i ][ _x ] += 1
        end

        def via_nil_sustitute_value  # if we don't add the key, the template will
          @subs_h[ @fld.name_symbol ] = nil   # substitute the mustache variable name
        end
      end
    end
  end
end
