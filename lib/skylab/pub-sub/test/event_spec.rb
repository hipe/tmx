require_relative 'test-support'

module Skylab::PubSub::TestSupport::Event_Tests__

  ::Skylab::PubSub::TestSupport[ self ]

  include CONSTANTS

  PubSub = PubSub

  extend TestSupport::Quickie

  describe "[ps] event" do

    it "you must construct it with 1 arg" do
      -> do
        subject_class.new
      end.should raise_error ::ArgumentError,
        'wrong number of arguments (0 for 1)'
    end

    def subject_class
      PubSub::TestSupport::Event::Predicate::Nub
    end

    context "the empty assertion against" do

      let :nub do
        subject_class.new []
      end

      -> do

        desc = 'nothing'
        msg = "expected 1 event, had 0"

        it "the empty array - no match - desc is #{desc} / #{msg.inspect}" do
          match []
          expect_result false
          expect_description desc
          expect_fmfs msg
        end
      end.call

      -> do
        it "the 1-length array (with nil) - matches - desc is 'nothing'" do
          match [nil]
          expect_result true
          expect_description 'nothing'
        end
      end.call

      -> do
        desc = 'nothing'
        msg = 'expected 1 event, had 2'
        it "the 2-length ary - no match - desc is #{desc} / #{msg.inspect}" do
          match [nil, nil]
          expect_description desc
          expect_fmfs msg
        end
      end.call
    end

    context "an assertion with one symbol against" do

      let :nub do
        subject_class.new [:nerk]
      end

      -> do
        d = 'nothing' ; m = 'expected 1 event, had 0'

        it "an empty array - no match - #{ m.inspect } " do
          match []
          expect_description d
          expect_result false
          expect_fmfs m
        end
      end.call

      -> do
        d = 'emit :nerk'

        it "an event with a matching stream name - matches - #{
            }(desc:) #{ d.inspect }" do
          match [ build_event( :nerk ) ]
          expect_result true
          expect_description d
        end
      end.call

      -> do
        d = 'emit :nerk' ; m = 'expected stream_name :nerk, had :jerk'
        it "an event with a not-matching stream name - #{
            } no matche - #{ m.inspect }" do
          match [ build_event( :jerk ) ]
          expect_result false
          expect_description d
          expect_fmfs m
        end
      end.call

      -> do
        it "an array with a non-event element - borks: NoMethodError" do
          -> do
            match [ nil ]
          end.should raise_error( ::NoMethodError,
                                  /undefined method `stream_name'/ )
        end
      end.call
    end

    context "an assertion with one string against" do

      let :nub do
        subject_class.new [ 'fing' ]
      end

      d = 'emit "fing"'

      -> do
        it "a raw event with a matching string payload - #{
            }raises - must respond to `text`" do
          -> do
            match [ build_event( :wtvr, 'fing' ) ]
          end.should raise_error( ::NoMethodError, /undefined method `text'/ )
        end
      end.call

      -> do
        m = 'expected text "fing", had "fung"'
        it "a textual event with a nonmatching string - #{
            }no match - #{ d } / #{ m }" do
          match [ build_text_event( :wtvr, 'fung' ) ]
          expect_result false
          expect_description d
          expect_fmfs m
        end
      end.call

      -> do
        it "one textual event with equal text - matches." do
          match [ build_text_event( :wtvr, 'fing' ) ]
          expect_result true
          expect_description d
        end
      end.call

      -> do
        m = 'expected text "fing", had "feltch". expected 1 event, had 2'
        it "two events, only first of which is matching - #{
            }no match - #{ m.inspect }" do
          match [ build_text_event( :wtvr, 'fing' ),
                  build_text_event( :wver, 'feltch' ) ]
          expect_result false
          expect_description d
          expect_fmfs m
        end
      end.call

      -> do
        m = 'expected 1 event, had 2'
        it "two events, only last of which is matching - #{
            }no match - #{ m.inspect }" do
          match [ build_text_event( :wtvr, 'fing' ),
                  build_text_event( :wver, 'fing' ) ]
          expect_result false
          expect_description d
          expect_fmfs m
        end
      end.call
    end

    context "an assertion at a particular index" do
      let :nub do
        subject_class.new [ 1, /foo/ ]
      end

      -> do
        -> do
          d = 'emit second "foo"'
          it "when matching second element - matches, describes #{
              }regex as matching string" do
            match [ build_text_event( :x, 'fee' ),
                    build_text_event( :x, 'foo' ), build_text_event( :x, 'fum' ) ]
            expect_result true
            expect_description d
          end
        end.call

        -> do
          d = "emit second (?-mix:foo)"
          m = 'expected text to match /foo/, had "fiz"'
          it "when non-matching second element - #{ m.inspect }" do
            match [ nil, build_text_event( :x, 'fiz' ), nil ]
            expect_fmfs m
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
        it "when matching - works" do
          match [ nil, nil, build_text_event( :bazzle, 'foo' ), nil,
            build_text_event( :wvr, 'doolicious' ), :not_see ]
          expect_result true
          expect_description d
       end
      end.call

      -> do

        m = 'expected text "foo", had "fop"'

        it "when no match - works" do
          match [ nil, nil, build_text_event( :bazzle, 'fop' ), nil ]
          expect_result false
          expect_description d
          expect_fmfs m
        end
      end.call
    end

    context "stacking multiple asserions for multiple indices" do
      let :nub do
        subject_class.new [ 2, :bazzle, 'foo', 4, /doo/ ]
      end

      it "is not currently possible" do
        a = [ nil, nil, build_text_event( :bazzle, 'foo' ), nil,
          build_text_event( :wvr, 'doolicious' ), :not_see ]
        -> do
          match a
        end.should raise_error( ::RuntimeError, /primitive type mutex - pos/i )
      end
    end

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    -> do
      stderr = $stderr
      define_method :stdinfo do stderr end
    end.call

    def match x
      res = nub.match x
      if do_debug
        stdinfo.puts "(with `num.match #{ x.inspect }`)"
        stdinfo.puts "(result - #{ res.inspect })"
        stdinfo.puts "(description - #{ nub.description.inspect })"
        if nub.instance_variable_get :@fail_a
          stdinfo.puts "(fmfs - #{ nub.failure_message_for_should.inspect })"
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

    def expect_fmfs x
      nub.failure_message_for_should.should eql x
    end

    def build_event stream_name, *rest
      # (a necessarily much simpler version than the one found in p.s)
      PubSub::Event::Unified.new false, stream_name, *rest  # (no event graph)
    end

    def build_text_event stream_name, text
      TextEvent__.new false, stream_name, text
    end
    #
    class TextEvent__ < PubSub::Event::Unified

      def initialize esg, stream_name, text
        super esg, stream_name
        @text = text
      end

      attr_reader :text
    end
  end
end
