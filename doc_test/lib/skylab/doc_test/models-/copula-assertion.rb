module Skylab::DocTest

  class Models_::CopulaAssertion

    # implement [#025] "common paraphernalia model"

    class << self
      alias_method :via_code_line__, :new
      undef_method :new
    end  # >>

    def initialize code_line, cx
      @_choices = cx
      @code_line = code_line
    end

    def to_line
      _pp = @_choices.particular_paraphernalia_for self
      _pp.to_line
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

    attr_reader(
      :code_line,
    )

    def paraphernalia_category_symbol
      :copula_assertion
    end
  end
end
# #history: rename-and-rewrite of Predicate_Expressions
