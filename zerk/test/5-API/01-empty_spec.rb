require_relative 'test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] 0 - the empty ACS" do

    TS_[ self ]
    use :API

    it "builds" do
      build_top_
    end

    context "call it with nothing" do

      shared_subject :state_ do
        call_
        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "events" do

        only_emission.should ( be_emission :error, :expression do | y |

          y.should eql [ "** empty ** argument list." ]
        end )
      end
    end

    context "call it with something" do

      shared_subject :state_ do
        call_ :something
        flush_state_
      end

      it "fails" do
        expect_result_for_failure_
      end

      it "look at this whacky message for this case" do

        only_emission.should ( be_emission :error, :uninterpretable_token do | ev |

          _ = black_and_white ev

          _.should eql "invalid argument 'something', expecting {}"
        end )
      end
    end

    context "persist the empty ACS" do

      shared_subject :state_ do

        _ = build_top_

        @result = _.persist_into_ []

        flush_state_
      end

      it "looks as it does (an empty JSON object)" do

        state_.result.should eql EMPTY_JSON_LINES_
      end

      it "emits an event talking bout path and bytes" do

        only_emission.should ( be_emission :info, :wrote do | ev |

          ev.path and fail
          ev.bytes or fail

          black_and_white( ev ).should eql "wrote 3 bytes"
        end )
      end
    end

    context "unmarshals when payload looks right (no trailing newline necessary)" do

      shared_subject :state_ do

        _ = build_top_

        _x = _.unmarshal_from_ Callback_::Stream.via_nonsparse_array ['{}']

        @result = _x

        flush_state_
      end

      it "cannot be done - fails" do
        expect_result_for_failure_
      end

      it "error explains this" do

        only_emission.should ( be_emission :error, :empty_object do | ev |

          _s = black_and_white ev
          _s.should eql 'for now, will not parse empty JSON object for input JSON'
        end )
      end
    end

    shared_subject :top_ACS_class_ do

      class Zero_Empty

        def initialize & oes_p
          @oes_p_ = oes_p
        end

        include Unmarshal_and_Call_and_Marshal_

        self
      end
    end
  end
end
