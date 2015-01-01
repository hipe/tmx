require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Internal

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[tm] internal models" do

    extend TS_

    context "the `paths` node (and more importantly, procs as nodes)" do

      it "missing" do
        call_API :paths
        ev = expect_not_OK_event :missing_required_properties
        black_and_white( ev ).should match %r(\bmissing required argument\W+path\b)i
        expect_failed
      end

      it "extra" do
        call_API :paths, :wiz, :waz, :wazoozle
        ev = expect_not_OK_event :extra_properties
        black_and_white( ev ).should match %r(\bunexpected argument\W+wazoozle\b)i
        expect_failed
      end

      it "strange verb" do
        call_API :paths, :generated_grammar_dir, :wiznippl
        expect_not_OK_event :unrecognized_verb
        expect_failed
      end

      it "strange noun" do
        call_API :paths, :baznoozer, :retrieve
        expect_not_OK_event :unknown_path
        expect_failed
      end

      it "retrieves (and possibly generates) the GGD path" do
        # it may or may not emit events based on whether the dir already existed
        call_API :paths, :generated_grammar_dir, :retrieve
        %r([^/]+\z).match( @result )[ 0 ].should eql TanMan_.lib_.tmpdir_stem
      end
    end
  end
end
