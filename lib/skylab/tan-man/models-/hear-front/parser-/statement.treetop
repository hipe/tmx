module Skylab
  module TanMan
    grammar Statement
      rule statement
        forget_statement /
        copula_statement /
        dependency_statement /
        meaning_statement
      end

      rule forget_statement
        'forget' sep target:cluster
        { def tree ; TanMan::Sexp_::Auto::Recursive[ self ] end }
      end
      rule copula_statement
        agent:cluster sep 'is' sep target:cluster
        { def tree ; TanMan::Sexp_::Auto::Recursive[ self ] end }
      end
      rule dependency_statement
        agent:cluster sep polarity:( 'depends on' / 'does not depend on' ) sep target:cluster
        { def tree ; TanMan::Sexp_::Auto::Recursive[ self ] end }
      end
      rule meaning_statement
        agent:cluster sep 'means' sep target:cluster
        { def tree ; TanMan::Sexp_::Auto::Recursive[ self ] end }
      end
      rule cluster
        head:word tail:(sep content:word)*
      end
      rule word
          !( ( 'depends on' / 'does not depend on' / 'means' / 'is' )  !(!sep .) )
          [^,;\t\n\r ]+
        { def tree ; text_value end }
      end
      rule sep
        [ \t\n\r]+
      end
    end
  end
end
