require_relative '.././test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] internal models", wip: true do

    TS_[ self ]

    context "the `paths` node (and more importantly, procs as nodes)" do

      it "missing" do

        call_API :paths

        _em = expect_not_OK_event :error

        ev = _em.cached_event_value.to_event

        COMMON_MISS_ == ev.terminal_channel_symbol or fail

        black_and_white( ev ).should match(
          %r(\bmissing required arguments 'path' and 'verb') )

        expect_fail
      end

      it "extra" do

        call_API :paths, :wiz, :waz, :wazoozle

        _em = expect_not_OK_event :error

        ev = _em.cached_event_value.to_event

        :extra_properties == ev.terminal_channel_symbol or fail

        black_and_white( ev ).should match(
          %r(\bunexpected arguments :wiz and :wazoozle) )

        expect_fail
      end

      it "strange verb" do

        call_API :paths, :path, :generated_grammar_dir, :verb, :wiznippl

        _em = expect_not_OK_event :unrecognized_verb

        _em.cached_event_value.verb.should eql :wiznippl

        expect_fail
      end

      it "strange noun" do

        call_API :paths, :path, :waznoozle, :verb, :retrieve

        _em = expect_not_OK_event :unknown_path

        _em.cached_event_value.did_you_mean.should be_include :generated_grammar_dir

        expect_fail
      end

      it "retrieves (and possibly generates) the GGD path" do
        # it may or may not emit events based on whether the dir already existed
        call_API :paths, :path, :generated_grammar_dir, :verb, :retrieve
        %r([^/]+\z).match( @result )[ 0 ].should eql Home_.lib_.tmpdir_stem
      end
    end
  end
end
