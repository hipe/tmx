module Skylab::Brazen::TestSupport

  class Expect_Event

    class << self

      def [] test_context_cls
        test_context_cls.include Test_Context_Instance_Methods__ ; nil
      end
    end

      module Test_Context_Instance_Methods__

        def call_API * x_a
          call_API_via_iambic x_a
        end

        def call_API_via_iambic x_a
          x_a.push :on_event_selectively, handle_event_selectively
          @result = subject_API.call( * x_a ) ; nil
        end

        def handle_event_selectively
          @__HES_p__ ||= bld_on_event_selectively
        end

        def bld_on_event_selectively
          evr = event_receiver_for_expect_event
          -> * x_a, & ev_p do
            _ev = if ev_p
              ev_p[]
            else
              Brazen_.event.inline_via_normal_extended_mutable_channel x_a
            end
            evr.receive_ev _ev
          end
        end

        def event_receiver_for_expect_event
          @evr ||= begin
            @ev_a = nil
            build_event_receiver_for_expect_event
          end
        end

        def build_event_receiver_for_expect_event  # :+#public-API :#hook-in
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
              raise "expected no more events, has #{ _ev.description }"
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
          @ev.render_all_lines_into_under s_a=[], expression_agent_for_expect_event
          if 1 == s_a.length
            s_a.fetch 0
          else
            s_a * NEWLINE_  # meh
          end
        end

        def expression_agent_for_expect_event
          Brazen_.event.codifying_expression_agent
        end

        def black_and_white ev
          black_and_white_lines( ev ).join NEWLINE_
        end

        def black_and_white_lines ev
          ev.render_all_lines_into_under y=[], event_expression_agent
          y
        end

        # ~ support and resolution

        def send_event_failure msg
          fail "#{ msg }: #{ @ev.terminal_channel_i }"
        end

        def via_ev_expect_via_proc p
          p[ @ev ]
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

        def initialize ev_p, test_context
          @ev_p = ev_p
          @test_context = test_context
          if test_context.do_debug
            @do_debug = true
            @debug_IO = test_context.debug_IO
          else
            @do_debug = false
          end
          @p_a = nil
        end

        def add_event_pass_filter &p
          ( @p_a ||= [] ).push p ; nil
        end

        def receive_ev ev
          if @p_a
            d = @p_a.index do |p|
              ! p[ ev ]
            end
          end
          if d
            prcss_supressed_event ev
          else
            prcss_passed_ev ev
          end
        end

      private

        def prcss_passed_ev ev
          @do_debug and express_event ev
          ev_ = ev.to_event
          if ev_.has_tag :flyweighted_entity
            was_wrapped = ev.object_id != ev_.object_id
            _ent = ev_.flyweighted_entity.dup
            ev_ = ev_.dup_with :flyweighted_entity, _ent
            ev = ev_
            if was_wrapped
              ev = Fake_Wrapper__.new ev
            end
          end
          @ev_p[ ev ]
          if ev_.has_tag :ok
            ev_.ok
          end
        end

        def prcss_supressed_event ev
          if @do_debug
            express_event ev, "(suppressed by filter:) " ; nil
          end
        end

      public

        def app_name
          @test_context.app_name
        end

        def express_event ev, comment=nil
          @ev = ev ; @ev_ = ev.to_event
          @ok_s = ok_s ; @tci = ev.terminal_channel_i
          @mems = "(#{ @ev_.tag_names * ', ' })"
          io = @debug_IO
          p = -> s do
            header_s = "#{ comment }#{ @ok_s } #{ @tci } #{ @mems } - "
            io.puts "#{ header_s }#{ s.inspect }"
            p = -> s_ do
              blank_s = Brazen_::SPACE_ * header_s.length
              io.puts "#{ blank_s }#{ s_.inspect }"
              p = -> s__ do
                io.puts "#{ blank_s }#{ s__.inspect }"
              end
            end ; nil
          end
          _y = ::Enumerator::Yielder.new do |s|
            p[ s ]
          end
          ev.render_all_lines_into_under _y, @test_context.event_expression_agent
          nil
        end

      private

        def ok_s
          ev_ = @ev.to_event
          if ev_.has_tag :ok
            x = ev_.ok
            if x.nil?
              '(neutral)'
            else
              x ? '(ok)' : '(not ok)'
            end
          else
            '(ok? not ok?)'
          end
        end
      end

      Fake_Wrapper__ = ::Struct.new :to_event

    Expectation__ = self

    class Expectation__

      def initialize x_a, p
        @call_a = [ [ :resolve_ev_by_expect_one_event ] ]
        @scn = Callback_::Iambic_Stream.via_array x_a
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
        scn = Callback_::Iambic_Stream.via_array @scn.gets_one
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

    NEWLINE_ = Brazen_::NEWLINE_
  end
end
