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

      def _difference_against_counterpart_ o

        if :__listifiable  == o.category_symbol_
          ___diff_against_other_listifiable o
        else
          # for now we're going to be dirty and assume that the other is a
          # List and that it is nonzero in length (since it exists as a list)
          # and we, always being one in length (when imagined as a list):
          true
        end
      end

      def ___diff_against_other_listifiable o

        inner = o._inner_expression
        if inner.category_symbol_ == @_inner_expression.category_symbol_
          inner._difference_against_counterpart_ @_inner_expression
        end
      end

      def _aggregate_ o
        _a = [ @_inner_expression, o._inner_expression ]
        Siblings_::List.via_ _a, :association_symbol, @_ASC.name_symbol
      end

      def to_read_only_array__
        [ @_inner_expression ]
      end

      attr_reader :_inner_expression
      protected :_inner_expression

      # --

      def number_exponent_symbol_
        :singular
      end

      def person_exponent_symbol_
        :third  # ..
      end

      def category_symbol_
        :__listifiable
      end

      def _can_aggregate_
        true
      end

      def has_content_
        true
      end
    end
  end
end
