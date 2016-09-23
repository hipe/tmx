module Skylab::DocTest

  class Models_::CopulaAssertion  # #[#025]

    class << self
      alias_method :via_code_line__, :new
      undef_method :new
    end  # >>

    def initialize code_line, cx
      @_choices = cx
      @code_line = code_line
    end

    def to_line_stream
      _to_particular_paraphernalia.to_line_stream
    end

    def to_line
      _to_particular_paraphernalia.to_line
    end

    def _to_particular_paraphernalia
      @_choices.particular_paraphernalia_for self
    end

    def to_three_pieces

      cl = @code_line
      s = cl.string

      cr = cl.copula_range

      _r1_begin = cl.content_begin
      _r1_end = cr.begin

      l_r = cl.LTS_range

      _r2_begin = cr.end
      _r2_end = l_r.begin

      [ s[ _r1_begin ... _r1_end ], s[ _r2_begin ... _r2_end ], s[ l_r ] ]
    end

    def add_parens_if_maybe_necessary actual_code_s

      # experimentally, try these translation rules:
      #
      #   • don't wrap the whole thing in parens if it
      #     starts or ends with parens. (we might broaden this.)
      #
      #   • otherwise, do add parens if it has any spaces in it EEK

      # eek - eek.

      if PROBABLY_OK___ =~ actual_code_s
        actual_code_s
      else
        "( #{ actual_code_s } )"
      end
    end

    PROBABLY_OK___ = / \A \( | \) \z | \A[^[:space:]]+\z /x

    attr_reader(
      :code_line,
    )

    def paraphernalia_category_symbol
      :copula_assertion
    end
  end
end
# #history: rename-and-rewrite of Predicate_Expressions
