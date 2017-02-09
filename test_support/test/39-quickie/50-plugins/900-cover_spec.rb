require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - cover" do

    TS_[ self ]
    use :quickie_plugins

    context "(longest common base path)" do

      it "finds longest common base path when there is one" do

        _against_these do |y|
          y << "/senate/elizabeth/warren/flarren"
          y << "/senate/elizabeth/chuck/schumer"
        end

        _LCBP == "/senate/elizabeth" || fail
      end

      it "when there is none, NIL" do

        _against_these do |y|
          y << "/A"
          y << "/B"
        end

        _LCBP.nil? || fail
      end

      it "no leading slash (absolute-looking paths) OK" do

        _against_these do |y|
          y << "a/b/c"
          y << "a/b/e"
        end

        _LCBP == "a/b" || fail
      end

      it "but switching from absolute to relative (or vice versa) nope" do

        _against_these do |y|
          y << "/a/b/c"
          y << "a/b/d"
        end

        _LCBP.nil? || fail
      end

      it "against nothing, nothing" do

        _against_these do |y|
        end

        _LCBP.nil? || fail
      end

      def _against_these( & p )
        @LCBP = p
      end

      def _LCBP
        _p = remove_instance_variable :@LCBP
        a = []
        _y = ::Enumerator::Yielder.new do |path|
          a.push path
        end
        _p[ _y ]
        _st = Home_::Stream_[ a ]

        x = Home_::Quickie::Plugins::Cover::
          LongestCommonBasePath_via_Stream___.new( _st ).execute

        if x
          x.to_string  # more natural to read in tests this way
        else
          x
        end
      end
    end

    # ==
    # ==
  end
end
# #tombstone-A: full rewrite from when standalone executable to quickie plugin
