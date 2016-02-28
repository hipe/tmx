require_relative '../../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] [..] expression sessions - count and noun" do

    extend TS_
    use :NLP_EN_sexp_magnetics

    if false  #  the mentor case, here for reference:

      y << "(#{ match_count } match#{ s match_count, :es } #{
        }in #{ file_count } file#{ s file_count })"

    # after:

      y << "(#{ np_ match_count, 'match' } in #{
        }#{ np_ file_count, 'file' })"
    end

    it "x." do

      _ef = Home_::NLP::EN.expression_session_for_(
        :syntactic_category, :noun_phrase,
        :subject, 3, :subject, 'amigo' )

      _ef.noun_phrase.to_string.should eql '3 amigos'
    end

    it "y." do

      _a 0, 'folly'
      e_ '0 follies'
    end

    it "z." do

      _a 1, 'folly'
      e_ '1 folly'
    end

    def _a d, s
      @the_iambic_for_the_request_ = [ :subject, d, :subject, s ]
    end

    def magnetic_module_
      magnetic_module_for_ :When_Count_and_Noun
    end
  end
end
