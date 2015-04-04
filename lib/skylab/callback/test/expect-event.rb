module Skylab::Callback::TestSupport

  class Expect_Event

    class << self

      def [] test_context_cls
        test_context_cls.include Test_Context_Instance_Methods ; nil
      end
    end  # >>

    # ->

      module Test_Context_Instance_Methods

        def call_API * x_a
          call_API_via_iambic x_a
        end

        def call_API_via_iambic x_a
          x_a.push :on_event_selectively, handle_event_selectively
          @result = subject_API.call( * x_a )
          NIL_
        end

        def handle_event_selectively
          event_receiver_for_expect_event.handle_event_selectively
        end

        def event_receiver_for_expect_event  # :+#public-API
          @evr ||= begin
            @ev_a = nil
            build_event_receiver_for_expect_event
          end
        end

        def build_event_receiver_for_expect_event  # :+#public-API :#hook-in

          # (this is frequently hooked-in to to implement ignoring certain events)

          Event_Receiver__.new -> ev do
            ( @ev_a ||= [] ).push ev
          end, self
        end

        def expect_one_event_and_neutral_result * x_a, & p
          expect_event_via_iambic_and_proc [ :shorthand, x_a ], p
          expect_no_more_events
          expect_neutralled
        end

        def expect_one_event * x_a, & p
          expect_event_via_iambic_and_proc [ :shorthand, x_a ], p
          expect_no_more_events
        end

        def expect_not_OK_event * x_a, & p
          expect_event_via_iambic_and_proc [ :is_ok, false, :shorthand, x_a ], p
        end

        def expect_neutral_event * x_a, & p
          expect_event_via_iambic_and_proc [ :is_ok, nil, :shorthand, x_a ], p
        end

        def expect_OK_event * x_a, & p
          expect_event_via_iambic_and_proc [ :is_ok, true, :shorthand, x_a ], p
        end

        def expect_N_events d, term_chn_sym
          block_given? and raise ::ArgumentError
          idx = ( 0 ... d ).detect do | d_ |
            term_chn_sym != @ev_a.fetch( d_ ).terminal_channel_i
          end
          if idx
            fail "expected '#{ term_chn_sym }', #{
              }had '#{ @ev_a.fetch( idx ).terminal_channel_i }' (event at index #{ idx })"
          else
            @ev_a[ 0, d ] = EMPTY_A_
            nil
          end
        end

        def expect_event * x_a, & p
          expect_event_via_iambic_and_proc [ :shorthand, x_a ], p
        end

        def expect_event_via_iambic_and_proc x_a, p
          @ev = nil
          exp = Expectation__.new x_a, p
          exp.call_a.each do | method_i, args |
            send method_i, * args
          end
          @ev
        end

        def expect_no_events
          @ev_a.should be_nil
        end

        def expect_no_more_events
          if @ev_a
            if @ev_a.length.nonzero?
              _ev = @ev_a.first.to_event
              raise "expected no more events, had #{ @evr.first_line_description _ev }"
            end
          end
        end

        def resolve_ev_by_expect_one_event
          if @ev_a
            if @ev_a.length.zero?
              raise "expected event, had no more."
            else
              @ev = @ev_a.shift ; nil
            end
          else
            raise "expected event, had none."
          end
        end

        def flush_to_event_stream
          st = Callback_::Stream.via_nonsparse_array @ev_a
          @ev_a = EMPTY_A_
          st
        end

        # ~ expectations along the different qualities of events

        def via_ev_expect_terminal_channel_of i
          @ev.to_event.terminal_channel_i.should eql i
        end

        def via_ev_expect_OK_value_of bool
          ev = @ev.to_event
          if bool.nil?
            if ev.has_tag :ok
              if ! ev.ok.nil?
                when_ev_OK_value_is_not_nil ev.ok
              end
            else
              when_neutral_expected_and_ev_does_not_have_OK_tag
            end
          elsif ev.has_tag :ok
            x = ev.ok
            if bool
              x or when_ev_is_not_OK
            else
              x and when_ev_is_OK
            end
          else
            when_ev_does_not_have_OK_tag
          end
        end

        def when_ev_OK_value_is_not_nil x
          send_event_failure "expected OK value of `nil`, had #{ x.inspect }"
        end

        def when_ev_is_not_OK
          send_event_failure "was not 'ok', expected 'ok'"
        end

        def when_ev_is_OK
          send_event_failure "was 'ok', expected not"
        end

        def when_neutral_expected_and_ev_does_not_have_OK_tag
          when_ev_does_not_have_OK_tag
        end

        def when_ev_does_not_have_OK_tag
          send_event_failure "did not have 'ok' tag"
        end

        def via_ev_expect_codified_message_string s
          s_ = expct_that_event_renders_as_one_string
          s_ and s_.should eql s
        end

        def via_ev_expect_codified_message_string_via_regexp rx
          s = expct_that_event_renders_as_one_string
          s and s.should match rx
        end

        def expct_that_event_renders_as_one_string
          @ev.express_into_under s_a=[], expression_agent_for_expect_event
          if 1 == s_a.length
            s_a.fetch 0
          else
            s_a * NEWLINE_  # meh
          end
        end

        def expression_agent_for_expect_event
          Callback_::Event.codifying_expression_agent
        end

        def black_and_white ev
          black_and_white_lines( ev ).join NEWLINE_
        end

        def black_and_white_lines ev
          ev.express_into_under y=[], black_and_white_expression_agent_for_expect_event
          y
        end

        # ~ support and resolution

        def send_event_failure msg
          fail "#{ msg }: #{ @ev.terminal_channel_i }"
        end

        def via_ev_expect_via_proc p
          p[ @ev ]
        end

        def expect_failed_by * x_a, & x_p

          expect_event_via_iambic_and_proc(
            [ :is_ok, false, :shorthand, x_a ], x_p )

          expect_failed
        end

        def expect_failed
          expect_no_more_events
          expect_failed_result
        end

        def expect_neutralled
          expect_no_more_events
          expect_neutral_result
        end

        def expect_succeeded
          expect_no_more_events
          expect_succeeded_result
        end

        def expect_failed_result
          @result.should eql false
        end

        def expect_neutral_result
          @result.should be_nil
        end

        def expect_succeeded_result
          @result.should eql true
        end
      end

      class Event_Receiver__

        def initialize recv_ev_p, test_context

          @chan_p = method :__receive_on_channel_unclassified

          if test_context.do_debug
            @do_debug = true
            @debug_IO = test_context.debug_IO
          else
            @do_debug = false
          end

          @recv_ev_p = recv_ev_p

          @test_context = test_context
        end

        def __receive_on_channel_unclassified i_a, & x_p

          if i_a && :expression == i_a[ 1 ]  # buy-in to :+[#br-023]
            __receive_expression i_a, & x_p
          else
            _receive_passed_event(
              if x_p
                x_p[]
              else
                Callback_::Event.inline_via_normal_extended_mutable_channel i_a
              end )
          end
        end

        def __receive_expression i_a, & msg_p

          _ok = case i_a.first
          when :info    ; nil
          when :payload ; true
          else          ; false  # meh
          end

          _ev = Callback_::Event.inline_with(

              i_a.fetch( 2 ), :ok, _ok ) do | y, _ |

            instance_exec y, & msg_p
          end

          _receive_passed_event _ev
        end

        def handle_event_selectively
          @__HES_p ||= -> * i_a, & ev_p do
            @chan_p[ i_a, & ev_p ]
          end
        end

        def maybe_receive_on_channel_event i_a, & ev_p
          @chan_p[ i_a, & ev_p ]
        end

        def add_map_reducer & map_reducer_p

          next_p = @chan_p

          @chan_p = -> i_a, & ev_p do
            map_reducer_p[ ev_p, i_a, next_p ]
          end ; nil
        end

        def _receive_passed_event ev
          @do_debug and __express_event_into ev, @debug_IO
          ev_ = ev.to_event
          if ev_.has_tag :flyweighted_entity
            was_wrapped = ev.object_id != ev_.object_id
            _ent = ev_.flyweighted_entity.dup
            ev_ = ev_.with :flyweighted_entity, _ent
            ev = ev_
            if was_wrapped
              ev = Fake_Wrapper___.new ev
            end
          end
          @recv_ev_p[ ev ]
          if ev_.has_tag :ok
            ev_.ok
          end
        end

        def __express_event_into ev, io
          st = _description_line_stream_for ev
          begin
            line = st.gets
            line or break
            io.puts line
            redo
          end while nil
        end

        def first_line_description comment=nil, ev
          _description_line_stream_for( comment, ev ).gets
        end

        def _description_line_stream_for comment=nil, ev

          desc = Describer___.new ev,
            comment,
            @test_context.expression_agent_for_expect_event

          Callback_.stream do
            desc.gets
          end
        end
      end

      Fake_Wrapper___ = ::Struct.new :to_event

    # <-

    Expectation__ = self

    class Expectation__

      def initialize x_a, p
        @call_a = [ [ :resolve_ev_by_expect_one_event ] ]
        @scn = Callback_::Polymorphic_Stream.via_array x_a
        while @scn.unparsed_exists
          send @scn.gets_one
        end
        p and @call_a.push [ :via_ev_expect_via_proc, [ p ] ]
      end

      attr_reader :call_a

      def is_ok
        @call_a.push [ :via_ev_expect_OK_value_of, [ @scn.gets_one ] ] ; nil
      end

      def shorthand
        scn = Callback_::Polymorphic_Stream.via_array @scn.gets_one
        scn.unparsed_exists and parse_shorthand scn
      end

      def parse_shorthand scn
        @call_a.push [ :via_ev_expect_terminal_channel_of, [ scn.gets_one ] ]

        if scn.unparsed_exists
          x = scn.current_token
          if x.respond_to? :ascii_only?
            @call_a.push [ :via_ev_expect_codified_message_string,
              [ scn.gets_one ] ]
          elsif x.respond_to? :named_captures
            @call_a.push [ :via_ev_expect_codified_message_string_via_regexp,
              [ scn.gets_one ] ]
          end
        end

        if scn.unparsed_exists
          raise ::ArgumentError, "unreasonable expectation: #{ scn.current_token }"
        end ; nil
      end
    end

    class Describer___

      # we build "Good Design" into our deugging "UI" only because we
      # know empirically (and state tautologically) that it stands to improve
      # development productivity by way of improving debugging usability.

      def initialize ev, comment, expag
        @comment = comment
        @ev = ev.to_event  # we ignore wrappers completely
        @expag = expag
        @is_active = true
        @meth = :__gets_when_line_zero
      end

      def gets
        if @is_active
          send @meth
        end
      end

      def __gets_when_line_zero
        if @ev.message_proc
          __gets_when_line_zero_and_event_is_expressive
        else
          __gets_when_line_zero_and_event_is_not_expressive
        end
      end

      def __gets_when_line_zero_and_event_is_not_expressive
        @is_active = false
        "« #{ _render_data_head } »"  # :+#guillemets
      end

      def __gets_when_line_zero_and_event_is_expressive
        @st = @ev.to_stream_of_lines_rendered_under @expag
        @line = @st.gets
        if @line
          __render_first_line
        else
          @is_active = nil
        end
      end

      def __render_first_line

        # if the event itself renders out multiple lines, render it with the
        # event "metadata" creating the first and only line of a left column
        # with each content line from the event in a right column, an effect
        # only noticable for the few events that render into multiple lines.

        @first_line_header = "#{ _render_data_head } - "

        s = "#{ @first_line_header }#{ @line.inspect }"
        @line = @st.gets
        if @line
          @meth = :__gets_via_second_line
        else
          @is_active = false
        end
        s
      end

      def _render_data_head
        "#{ @comment }#{ __OK_s }#{
         } #{ @ev.terminal_channel_i }#{
          } (#{ @ev.tag_names * ', ' })"
      end

      def __OK_s
        ev = @ev.to_event
        if ev.has_tag :ok
          x = ev.ok
          if x.nil?
            '(neutral)'
          else
            x ? '(ok)' : '(not ok)'
          end
        else
          '(ok? not ok?)'
        end
      end

      def __gets_via_second_line

        @blank_s = Callback_::SPACE_ * @first_line_header.length
        @meth = :_via_line_flush_subsequent_line
        _via_line_flush_subsequent_line
      end

      def _via_line_flush_subsequent_line

        s = "#{ @blank_s }#{ @line.inspect }"
        @line = @st.gets
        if ! @line
          @is_active = false
        end
        s
      end
    end
  end
end
