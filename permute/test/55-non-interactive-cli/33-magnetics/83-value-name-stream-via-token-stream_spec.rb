require_relative '../../test-support'

module Skylab::Permute::TestSupport

  describe "[pe] non-interactive CLI - magnetics - [magnet #3]" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

    context "ambiguity" do

      shared_subject :_this do
        _against '--corynthian', 'bleep', '--coronation', 'bloop', '-c', 'doop'
      end

      it "fails" do
        fails
      end

      it "complains nicely - did you mean \"foobizzie\" or \"foobozzie\"?" do

        want_emission :error, :ambiguous_property do |ev|

          _ = black_and_white ev

          _ == %q(ambiguous category letter "c" - #{
            }did you mean "corynthian" or "coronation"?)
        end
      end
    end

    context "works" do

      shared_subject :_this do
        __want_no_emission_against '--abcde', 'fg', '-a', 'hi', '--jklm', 'p'
      end

      it "emits nothing" do
        want_no_emissions
      end

      it "for now, strings everywhere" do
        _ = _this.result
        _ == [['fg', :abcde], ['hi', :abcde], ['p', :jklm]] || fail
      end
    end

    def _against * argv  # result in state

      _p = event_log.handle_event_selectively

      _xx = _send _p, argv

      flush_event_log_and_result_to_state _xx
    end

    def __want_no_emission_against * argv  # result in state

      _xx = _send Want_no_emission_, argv

      Home_::Common_::TestSupport::Want_Emission::State.new _xx
    end

    def _send p, argv

      _mags = Home_::CLI::Magnetics_

      _ts = _mags::TokenStream_via_ArgumentArray_and_Tokenizer[ argv, & p ]

      _mags::ValueNameStream_via_TokenStream[ _ts, & p ]
    end

    def state_for_want_emission
      _this
    end
  end
end
