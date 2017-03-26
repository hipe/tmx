require_relative '../test-support'

module Skylab::Human::TestSupport

  describe "[hu] expression pipeline - const string via term scanner" do

    TS_[ self ]
    use :memoizer_methods

    it "for those parts of your name that \"look like\" business, camel case" do

      _against %w( gerundish phraseicle )
      _expect :GerundishPhraseicle
    end

    it "a fixed set of special keywords is recognized and etc" do

      _against %w( lerst via columnicar accretion of phraseicles )
      _expect :Lerst_via_ColumnicarAccretion_of_Phraseicles
    end

    # it "you can't start with a keyword"  # meh

    # it "you can't end on a keyword"  # meh

    def _against s_a
      @WORDS = s_a
    end

    def _expect expect_const
      _words = remove_instance_variable :@WORDS
      _scn = Home_::Scanner_[ _words ]
      actual = Home_::ExpressionPipeline_::ConstString_via_TermScanner[ _scn ].intern
      if actual != expect_const
        fail "expected `#{ expect_const }`, had `#{ actual }`"
      end
    end

    # ==
    # ==
  end
end
