require_relative 'test-support'

module Skylab::Callback::TestSupport::Event_Tests__

  ::Skylab::Callback::TestSupport[ self ]

  include Constants

  Callback_ = Callback_

  Callback_::Lib_::Quickie[ self ]

  describe "[cb] event" do

    it "you must construct it with 1 arg" do
      -> do
        subject_class.new
      end.should raise_error ::ArgumentError,
        'wrong number of arguments (0 for 1)'
    end

    def subject_class
      Callback_::TestSupport::Event::Assertion
    end

    context "the empty assertion against" do

      let :nub do
        subject_class.new []
      end

      d = 'nothing'

      -> do
        m = "expected 1 event, had 0"
        it "the empty array - x, '#{ d }', #{ m.inspect }" do
          match []
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call

      -> do
        it "the 1-length array (with nil) - o, #{ d }" do
          match [ nil ]
          expect_result true
          expect_description d
        end
      end.call

      -> do
        m = 'expected 1 event, had 2'
        it "the 2-length ary - x, '#{ d }', #{ m.inspect }" do
          match [ nil, nil ]
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call
    end

    context "an assertion with one symbol against" do

      let :nub do
        subject_class.new [:nerk]
      end

      -> do
        d = 'emit :nerk' ; m = 'expected 1 event, had 0'

        it "an empty array - x, #{ m.inspect }" do
          match []
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call

      -> do
        d = 'emit :nerk'
        it "an event with a matching stream name - o, '#{ d }'" do
          match [ build_event( :nerk ) ]
          expect_result true
          expect_description d
        end
      end.call

      -> do
        d = 'emit :nerk' ; m = 'expected stream_name :nerk, had :jerk'
        it "an event with a not-matching stream name - x, #{ m.inspect }" do
          match [ build_event( :jerk ) ]
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call

      -> do
        rx = /undefined method `stream_name'/
        it "an array with a non-event element - X #{ rx }" do
          -> do
            match [ nil ]
          end.should raise_error ::NoMethodError, rx
        end
      end.call
    end

    context "an assertion with one string against" do

      let :nub do
        subject_class.new [ 'fing' ]
      end

      d = 'emit "fing"'

      -> do
        rx = /undefined method `payload_x'/
        it "a raw event with a matching string payload - X, #{ rx }" do
          -> do
            match [ build_event( :wtvr, 'fing' ) ]
          end.should raise_error ::NoMethodError, rx
        end
      end.call

      -> do
        m = 'expected text "fing", had "fung"'
        it "a textual event with a nonmatching string - #{
            }x, '#{ d }', #{ m.inspect }" do
          match [ build_text_event( :wtvr, 'fung' ) ]
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call

      -> do
        it "one textual event with equal text - o" do
          match [ build_text_event( :wtvr, 'fing' ) ]
          expect_result true
          expect_description d
        end
      end.call

      -> do
        m = 'expected text "fing", had "feltch". expected 1 event, had 2'
        it "two events, only first of which is matching - #{
            }x, #{ m.inspect }" do
          match [ build_text_event( :wtvr, 'fing' ),
                  build_text_event( :wver, 'feltch' ) ]
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call

      -> do
        m = 'expected 1 event, had 2'
        it "two events, only last of which is matching - #{
            }x, #{ m.inspect }" do
          match [ build_text_event( :wtvr, 'fing' ),
                  build_text_event( :wver, 'fing' ) ]
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call
    end

    context "an assertion at a particular index" do
      let :nub do
        subject_class.new [ 1, /foo/ ]
      end

      -> do
        -> do
          d = 'emit second /foo/'
          it "when matching second element - o, describes #{
              }regex as matching string" do
            match [ build_text_event( :x, 'fee' ),
                    build_text_event( :x, 'foo' ), build_text_event( :x, 'fum' ) ]
            expect_result true
            expect_description d
          end
        end.call

        -> do
          d = "emit second /foo/"
          m = 'expected text to match /foo/, had "fiz"'
          it "when non-matching second element - x, #{ m.inspect }" do
            match [ nil, build_text_event( :x, 'fiz' ), nil ]
            expect_result false
            expect_fail_msg_for_should m
            expect_description d
          end
        end.call
      end.call
    end

    context "stacking multiple asserions for one index" do

      let :nub do
        subject_class.new [ 2, :bazzle, 'foo' ]
      end

      d = 'emit third  :bazzle "foo"'

      -> do
        it "o" do
          match [ nil, nil, build_text_event( :bazzle, 'foo' ), nil,
            build_text_event( :wvr, 'doolicious' ), :not_see ]
          expect_result true
          expect_description d
       end
      end.call

      -> do

        m = 'expected text "foo", had "fop"'

        it "x, #{ m.inspect }" do
          match [ nil, nil, build_text_event( :bazzle, 'fop' ), nil ]
          expect_result false
          expect_description d
          expect_fail_msg_for_should m
        end
      end.call
    end

    context "stacking multiple assertions for multiple indices" do
      let :nub do
        subject_class.new [ 2, :bazzle, 'foo', 4, /doo/ ]
      end

      rx = /\bcannot stack assertions\b/

      it "is not currently possible - X #{ rx }" do
        a = [ nil, nil, build_text_event( :bazzle, 'foo' ), nil,
          build_text_event( :wvr, 'doolicious' ), :not_see ]
        -> do
          match a
        end.should raise_error ::RuntimeError, rx
      end
    end

    context "an assertion of channel, style and regexp" do

      let :nub do
        subject_class.new [ :important, :styled, /\bfoo\b/ ]
      end

      -> do
        d = "emit styled :important /\\bfoo\\b/"
        m = "expected stream_name :important, had :impordunt"
        it "everything correct but channel - x, #{ m.inspect }" do
          match [ build_text_event( :impordunt, "\e[32mfoo\e[0m" ) ]
          expect_result false
          expect_fail_msg_for_should m
          expect_description d
        end
      end.call

      -> do
        m = "expected string to be styled, was not: foo"
        it "everything correct but style - x, #{ m.inspect }" do
          match [ build_text_event( :important, "foo" ) ]
          expect_result false
          expect_fail_msg_for_should m
        end
      end.call

      -> do
        m = "expected text to match /\\bfoo\\b/, had \"foosball\""
        it "everything correct but regexp - x, #{ m.inspect }" do
          match [ build_text_event( :important, "\e[32mfoosball\e[0m" ) ]
          expect_result false
          expect_fail_msg_for_should m
        end
      end.call

      -> do
        it "everything correct - o" do
          match [ build_text_event( :important, "hi \e[32mfoo\e[0m hey" ) ]
          expect_result true
        end
      end.call
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    -> do
      stderr = ::STDERR
      define_method :stdinfo do stderr end
    end.call

    def match x
      res = nub.match x
      if do_debug
        e = stdinfo
        e.puts "(with `num.match #{ x.inspect }`)"
        e.puts "(result - #{ res.inspect })"
        e.puts "(description - #{ nub.description.inspect })"
        if nub.instance_variable_get :@fail_a
          e.puts "(fmfs - #{ nub.failure_message_for_should.inspect })"
        end
      end
      __memoized[:last_result] = res
      nil
    end

    def expect_result x
      __memoized.fetch( :last_result ).should eql x
      nil
    end

    def expect_description x
      nub.description.should eql x
      nil
    end

    def expect_fail_msg_for_should x
      nub.failure_message_for_should.should eql x
    end

    def build_event stream_name, *rest
      # (a necessarily much simpler version than the one found in p.s)
      Callback_::Event::Unified.new false, stream_name, *rest  # (no event graph)
    end

    def build_text_event stream_name, text
      TextEvent__.new false, stream_name, text
    end
    #
    class TextEvent__ < Callback_::Event::Unified

      def initialize esg, stream_name, text
        super esg, stream_name
        @payload_x = text
      end

      attr_reader :payload_x
    end
  end
end
