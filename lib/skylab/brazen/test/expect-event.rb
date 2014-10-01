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
          x_a.push :event_receiver, event_receiver
          @result = subject_API.call( * x_a ) ; nil
        end

        def event_receiver
          @event_receiver ||= bld_event_receiver
        end

        def bld_event_receiver
          @ev_a = nil
          Event_Receiver__.new -> ev do
            ( @ev_a ||= [] ).push ev ; nil
          end, self
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
          exp = Expectation__.new x_a, p
          exp.call_a.each do | method_i, args |
            send method_i, * args
          end ; nil
        end

        def expect_no_events
          @ev_a.should be_nil
        end

        def expect_no_more_events
          if @ev_a
            if @ev_a.length.nonzero?
              raise "expected no more events, has #{ @ev_a.first.description }"
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
          @ev.terminal_channel_i.should eql i
        end

        def via_ev_expect_OK_value_of bool
          ev = @ev.to_event
          if bool.nil?
            ev.has_tag( :ok ) and when_ev_has_OK_tag
          elsif ev.has_tag :ok
            if bool
              ev.ok or when_ev_is_not_OK
            else
              ev.ok and when_ev_is_OK
            end
          else
            when_ev_does_not_have_OK_tag
          end
        end

        def when_ev_has_OK_tag
          send_event_failure "expect event not to have 'ok' tag"
        end

        def when_ev_is_not_OK
          send_event_failure "was not 'ok', expected 'ok'"
        end

        def when_ev_is_OK
          send_event_failure "was 'ok', expected not"
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
          @ev.render_all_lines_into_under s_a=[],
            Brazen_::Event_[].codifying_expression_agent
          1 == s_a.length or raise "expected 1 had #{ s_a.length } lines"
          s_a.fetch 0
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
          @result.should eql nil
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

        def receive_event ev
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
            ev.object_id == ev_.object_id or self._DO_ME
            _ent = ev_.flyweighted_entity.dup
            ev_ = ev_.dup_with :flyweighted_entity, _ent
            ev = ev_
          end
          @ev_p[ ev ]
          if ev_.has_tag :ok
            ev_.ok ? true : false
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
          y = ::Enumerator::Yielder.new do |s|
            @debug_IO.puts "#{ comment }#{ @ok_s } #{ @tci } #{ @mems } - #{ s.inspect }"
          end
          ev.render_all_lines_into_under y, @test_context.event_expression_agent
          nil
        end

      private

        def ok_s
          ev_ = @ev.to_event
          if ev_.has_tag :ok
            ev_.ok ? '(ok)' : '(not ok)'
          else
            '(ok? not ok?)'
          end
        end
      end


    Expectation__ = self

    class Expectation__

      def initialize x_a, p
        @call_a = [ [ :resolve_ev_by_expect_one_event ] ]
        @scn = Brazen_::Entity_[].iambic_scanner.new 0, x_a
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
        scn = Brazen_::Entity_[].iambic_scanner.new 0, @scn.gets_one
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
  end
end
