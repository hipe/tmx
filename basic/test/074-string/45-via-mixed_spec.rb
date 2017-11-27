require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - `via_mixed`" do

    TS_[ self ]
    use :string  # only defines `subject_module_`

    it "a string 10 chars wide gets quoted and becomes 12 characters wide" do
      __want_quotes 'ten_chars_'
    end

    it "the quoting happens via 'inspect' so things get escaped too" do
      expect( subject( "\"\n" ) ).to eql '"\"\n"'
    end

    it "a string 16 chars wide becomes 15 chars wide and is ellipsified" do
      expect( subject( 'sixteen_chars_wd' ) ).to eql '"sixteen_cha[..]"'
    end

    it "a typical symbol gets single quotes" do
      expect( subject( :"foo_Bar baz 123" ) ).to eql "'foo_Bar baz 123'"
    end

    it "a crazy symbol is inspected as-is" do
      expect( subject( :"\thi" ) ).to eql ':"\thi"'
    end

    context "customization (through dup)" do

      it "you can increase or reduce the max width like so" do

        mutable_policy = _begin_dup_in_same_way
        mutable_policy.max_width = 4

        mutable_policy.against('heya') == '"heya"' || fail

        mutable_policy.against('hello') == '"[..]"' || fail
      end

      it "you can alter CERTAIN hooks this way (for now).." do

        mutable_policy = _begin_dup_in_same_way

        mutable_policy.non_long_string_by = -> s do
          "XxY>> #{ s.capitalize }#{ s[-1] * 2 }! <<YyX"
        end

        mutable_policy.against( 'wee' ) == "XxY>> Weeee! <<YyX" || fail
      end

      it "typically `to_proc` is called on these mutated policies" do

        mutable_policy = _begin_dup_in_same_way
        mutable_policy.max_width = 1
        _p = mutable_policy.to_proc

        _p[ "hi" ] == '"."' || fail
      end

      def _begin_dup_in_same_way

        # (nowadays we would insist on putting the "edit session" of the
        # policy in a definition block and freezing the policy (recursively)
        # after the edit, but there is enough legacy code written expecting
        # it to use no block that we're leaving it for now.)

        subject_module_.via_mixed.dup
      end
    end

    def __want_quotes s
      expect( subject( s ) ).to eql "\"#{ s }\""
    end

    def subject s
      subject_module_.via_mixed s
    end
  end
end
