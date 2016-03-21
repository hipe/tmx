module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::Listifiable

      # experiment - this is *NOT* for building plural lists outright -
      # rather it is for those parts of an expression that can *become*
      # a list thru aggregation.
      #
      # this fact means that we can treat any argument *array* as a sexp..

      class << self

        def interpret_component st, asc

          x = st.gets_one

          o = new asc
          if x.respond_to? :ascii_only?
            o.__init_via_string x
          else
            o.__init_via_not_string x
          end
        end

        private :new
      end  # >>

      def initialize asc
        @_ASC = asc
      end

      def __init_via_string x  # assume is string
        @_inner_expression = String_as_Expression_[ x, @_ASC ]
        self
      end

      def __init_via_not_string x

        _exp = Here_.expression_via_these_ x, @_ASC
        @_inner_expression = _exp
        self
      end

      # --

      def express_into_under y, expag
        x = @_inner_expression
        if x.respond_to? :ascii_only?
          y << x
        else
          x.express_into_under y, expag
        end
      end

      # --

      def _is_equivalent_to_counterpart_ o

        inner = o._inner_expression
        if inner.category_symbol_ == @_inner_expression.category_symbol_
          inner._is_equivalent_to_counterpart_ @_inner_expression
        end
      end

      def _aggregate_ o
        _a = [ @_inner_expression, o._inner_expression ]
        Siblings_::List.via_ _a, :association_symbol, @_ASC.name_symbol
      end

      attr_reader :_inner_expression
      protected :_inner_expression

      # --

      def number_exponent_symbol_
        :singular
      end

      def person_exponent_symbol__
        :third  # ..
      end

      def _can_aggregate_
        true
      end
    end
  end
end
