require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - express brazenly" do

    TS_Joist_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization

    it "all inline / expression / negative - nothing" do

      _a = _lines_via_emission :error, :expression, :_no_see_2_ do |y|
        y << "not in the #{ highlight 'mood' } for shenanigans"
        y << "nope"
        y << "fire"
      end

      _a.should eql [
        "not in the ** mood ** for shenanigans\n",
        "nope\n", "fire\n" ]
    end

    it "all inline / expression / neutral - nothing" do

      _a = _lines_via_emission :info, :expression, :_no_see_ do |y|
        y << "things look #{ highlight 'good' }"
        y << "yep"
        y << "such good"
      end

      _a.should eql [ "things look ** good **\n", "yep\n", "such good\n" ]
    end

    _Fake_lexeme = -> x do

      class TS_::Fake_Lexeme_EEK
        def initialize s
          @_s = s
        end
        def progressive
          "#{ @_s }ing"
        end
        def preterite
          "#{ @_s }ed"
        end
        def lemma_string
          @_s
        end
      end
      _Fake_lexeme = TS_::Fake_Lexeme_EEK.method :new
      _Fake_lexeme[ x ]
    end

    it "all inline / event / negative - LOOK uses special members to inflect" do

      _a = _lines_via_emission :error, :wazzozie do
        Common_::Event.inline_not_OK_with(
          :wazoozicle,
          :noun_lexeme, _Fake_lexeme[ 'fish' ],
          :verb_lexeme, _Fake_lexeme[ 'eat' ],
        ) do | y, o |
          y << "rick snyder #{ highlight 'failed' }"
          y << 'too bad'
        end
      end

      _a.should eql(
        [ "couldn't eat fish because rick snyder ** failed **\n",
          "too bad\n",
        ] )
    end

    it "../ event / completion / two words - " do

      _a = _lines_via_emission :"_anything?_", :_no_see_ do

        Common_::Event.inline_OK_with(
          :wazoozicle,
          :inflected_noun, 'fish',
          :verb_lexeme, _Fake_lexeme[ 'eat' ],
          :is_completion, true
        ) do | y, o |
          y << 'woop woop'  # need 2 words here
          y << 'wee'
        end
      end

      _a.should eql [ "eated fish: woop woop\n", "wee\n" ]
    end

    it "../ event / completion - one word - " do

      _a = _lines_via_emission :"_anything?_", :_no_see_ do

        Common_::Event.inline_OK_with(
          :wazoozicle,
          :inflected_noun, 'fish',
          :verb_lexeme, _Fake_lexeme[ 'eat' ],
          :is_completion, true
        ) do | y, o |
          y << 'donezo'  # need 1 words here
          y << 'wee'
        end
      end

      _a.should eql [ "donezo eating fish\n", "wee\n" ]
    end

    def _lines_via_emission * i_a, & ev_p

      o = subject_class_.new
      a = []
      o.expression_agent = common_expag_
      o.line_yielder = a
      o.express_emission i_a, & ev_p
      a
    end
  end
end
