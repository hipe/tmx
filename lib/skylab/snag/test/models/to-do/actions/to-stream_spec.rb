require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - to-do" do

    extend TS_
    use :expect_event

    context 'this is a hack [#068]' do

      it "but will try to skip false matches" do

        @result = subject
        __expect_this
      end

      def __expect_this

        expect_neutral_event :did_not_match do | ev |

          black_and_white( ev ).should match(
            %r(\Askipping a line that matched via `grep`) )

          ev.path.should eql '(poth)'
          ev.line.should match %r(\A@#{}todo\.blah )
          ev.line_number.should eql 33
        end

        expect_no_more_events
      end
    end

    def subject
      Snag_::Models_::To_Do.build( * args, & handle_event_selectively )
    end

    def args
      [ line_s, line_number_string, path, pattern_s ]
    end

    def line_s
      "@#{}todo.blah  # not a todo tag"
    end

    def line_number_string
      '33'
    end

    def path
      '(poth)'
    end

    def pattern_s
      Snag_::Models_::To_Do.default_pattern_s
    end
  end
end
