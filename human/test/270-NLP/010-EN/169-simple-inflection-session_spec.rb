require_relative '../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - simple inflection session" do  # :#cov2.0

    # usage notes:
    #
    #   - verbs, nouns and pronouns that "modify" "irregularly" (i.e
    #     "irregulars") are an uninteresing problem but we cannot for any
    #     practical purposes avoid them: because of some linguistic
    #     phenomenon, their occurrence is more frequent among frequently
    #     used verbs and pronouns (and for whatever reason, many nouns for
    #     animals, which we do not cover here).
    #
    #     our hacky solution to irregular verbs is that you pass a symbol
    #     not a string as the "lemma" for the verb. the lemma being a
    #     symbol tells us it is irregular, and we should expect some
    #     hard-coded solution for it rather than derivinng its inflection
    #     "algorithmically"..
    #

    TS_[ self ]

    context "(this new regex)" do

      it "looks plural" do
        _against "foos"
        _plural ; _not_Y ; _lowercase
      end

      it "looks plural (ends in Y)" do
        _against "PONIES"
        _plural ; _Y ; _uppercase
      end

      it "looks singular (ends in Y but not of the category)" do
        _against "play"
        _singular ; _not_Y ; _lowercase
      end

      def _against s
        md = _subject_module::SING_PLUR_REGEX_HACK___.match s
        md or fail "regex failed against: #{ s.inpsect }"
        @MD = md ; nil
      end

      def _plural
        @MD[ :looks_plural ]
      end

      def _singular
        @MD[ :looks_singular ]
      end

      def _not_Y
        @MD[ :the_not_Y_category ]
      end

      def _Y
        @MD[ :the_Y_category ]
      end

      def _uppercase
        @MD[ :all_caps ]
      end

      def _lowercase
        ! @MD[ :all_caps ]
      end
    end

    context "(redux of hacky stuff)" do

      context "(..)" do

        it "is" do
          _given true, :is
          _expect "is"
        end

        it "are" do
          _given 2, :is
          _expect "are"
        end

        # a note about using the contracted form ("wasn't") vs the non-
        # contracted from ("was not"): a cop-out answer is that we express
        # in the contracted form only for legacy reasons. the deepter truth
        # is that:
        #
        #   - the contracted form sounds more natural when the copula
        #     is an auxilary:
        #       more natural: "the document didn't have such a section"
        #       too formal:   "the document did not have such a section"
        #
        #   - but the contracted form may sound too casual when it is not
        #     acting as an auxiliary. (not sure..)
        #
        # so there is almost a desire to make this a new semantic category
        # of expression, but we'll hold off on that for now..  :#cov2.2

        it "was not" do
          _given false, :was
          _expect "wasn't"
        end

        def _given * x_a
          @TWO = x_a
        end

        def _expect s

          sess = X_nlp_en_sis_SessionClass.new

          two = remove_instance_variable :@TWO
          if ! two.first.respond_to? :bit_length
            sess.write_count_for_inflection 1  # meh
          end
          _actual = sess.v( * two )
          _actual == s || fail
        end
      end

      context "(the primitive cases)" do

        it "many" do
          _given_count 3
          _expect "3 foobrics frobulate"
        end

        it "one" do
          _given_count 1
          _expect "1 foobric frobulates"
        end

        it "none" do
          _given_count 0
          _expect "0 foobrics frobulate"
        end

        def _express_by sess
          sess.calculate do
            _d = count_for_inflection
            "#{ _d } #{ n "foobric" } #{ v "frobulate" }"
          end
        end
      end

      # :#cov2.1:
      #
      # when using those noun modifer functions with the same classification
      # as that of `the_only` (for example, itself);
      #
      # since the "polarity" of the sentence "frame" is expressed by the
      # count of the subject noun phrase, it sounds non-idiomatic at best
      # and incorrect at worst to express again this polarity through verb
      # inflection. so observe how the verb phrase is or isn't inflected by
      # negative polarity:
      #
      #   yes: "none of the 10 squirrels saw me walk by"
      #   not: "none of the 10 squirrels didn't see me walk by"
      #
      #   yes: "the only squirrel didn't see me walk by"
      #   not: "the only squirrel saw me walk by"
      #
      #   yes: "there are no squirrels, so none saw me walk by"
      #   not: "there are no squirrels didn't see me walk by"
      #   not: "no squirrels saw me walk by"  # (because the reason is ambiguous)
      #
      # so:
      #   if more than one: positive
      #   else if one: negative
      #   otherwise (and none): positive (and assume hack by the other function)

      context "(this target thing)" do

        it "many" do
          _given_count 3
          _expect "none of the 3 state transitions brings etc"
        end

        it "one" do
          _given_count 1
          _expect "the only state transition fails to bring etc"
        end

        it "none" do
          _given_count 0
          _expect "there are no state transitions so nothing brings etc"
        end

        def _express_by sess
          sess.calculate do
            "#{ the_only } #{ n "state transition" } #{ no_double_negative "bring" } etc"
          end
        end
      end

      context "(the above plus preterite plus irregular OH MY)" do

        it "many" do
          _given_count 10
          _expect "none of the 10 sections was about etc"
        end

        it "one" do
          _given_count 1
          _expect "the only section wasn't about etc"
        end

        it "none" do
          _given_count 0
          _expect "there are no sections so nothing was about etc"
        end

        def _express_by sess
          sess.calculate do
            "#{ the_only } #{ n "section" } #{ no_double_negative :was } about etc"
          end
        end
      end

      def _given_count d
        @COUNT = d
      end

      def _expect want_s

        sess = X_nlp_en_sis_SessionClass.new
        sess.write_count_for_inflection remove_instance_variable :@COUNT
        actual_s = _express_by sess
        actual_s == want_s or actual_s.should eql want_s
      end
    end

    it "an - matches a/an, case" do

      sc = _soliloquizing_client_for :an

      sc.instance_exec{ an 'apple' }.should eql( 'an apple' )
      sc.instance_exec{ an 'PEAR' }.should eql( 'A PEAR' )
      sc.instance_exec{ an 'beef', 0 }.should eql( 'no beef' )
      sc.instance_exec{ an 'wing', 2 }.should eql( 'wing' )
    end

    it "`s` - memoizes last numeric" do

      sc = _soliloquizing_client_for :s

     sc.instance_exec{ s 2 }.should eql( 's' )
     sc.instance_exec{ s }.should eql( 's' )
     sc.instance_exec{ s 1 }.should eql( nil )
     sc.instance_exec{ s }.should eql( nil )
    end

    it "`and_` - memoizes last numeric" do

      sc = _soliloquizing_client_for :and_, :s, :or_

      x = sc.instance_exec do
        "#{ and_ ['foo', 'bar'] } #{ s :is } ready"
      end

      x.should eql( "foo and bar are ready" )

      x = sc.instance_exec do
        "#{ or_ ['foo'] } #{ s :is } ready"
      end

      x.should eql( 'foo is ready' )

      x = sc.instance_exec do
        "#{ and_( [] ) || 'none' } #{ s :is } ready"
      end

      x.should eql( 'none are ready' )
    end

    it "integration 0" do

      _against
      _expect "no known persons exist in these 0 locations."
    end

    it "integration 1" do

      _against 'A'
      _expect "the only known person is A in this location."
    end

    it "integration 2" do

      _against 'A', 'B'
      _expect "known persons are A and B in these 2 locations."
    end

    def _against * s_a
      @_s_a = s_a
    end

    define_method :_expect, -> do

      # ( has a counterpart test in #spot1.2 )
      # ( note the example is somewhat un-realistic because we are using the
      # same count-variable referrant for two different noun phrases. )

      o = nil
      -> exp_s do

        o ||= __dangerous_build
        s_a = @_s_a

        _s_ = ( o.instance_exec do
         "#{ s s_a, :no }known person#{ s } #{ s :exist }#{ _and s_a }#{
           } in #{ s :this }#{ _non_one } location#{ s }."
        end )

        _s_.should eql exp_s
      end
    end.call

    def __dangerous_build

      _soliloquizing_client_for :and_, :_and, :_non_one, :s
    end

    define_method :_soliloquizing_client_for, -> do

      d = 0
      prefix = "NLP_EN_Method_User_"
      -> * i_a do

        cls = ::Class.new
        TS_.const_set "#{ prefix }#{ d += 1 }", cls
        X_nlp_en_sis_lib[].edit_module_via_iambic cls, [ :public, i_a ]
        cls.new
      end
    end.call

    X_nlp_en_sis_lib = -> do
      NLP_EN_.lib::SimpleInflectionSession
    end

    class X_nlp_en_sis_SessionClass
      include X_nlp_en_sis_lib[]::Methods
      alias_method :calculate, :instance_exec
    end

    define_method :_subject_module, X_nlp_en_sis_lib
  end
end
