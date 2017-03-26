module Skylab::Human

  module Sexp

    #   - "s-expression" is probably a misnomer. probably what we mean is
    #     [#fi-033] "iambic", but at one point we hoped (and indeed still
    #     hope) that we could replace our widespread but internal idiom with
    #     a term more widely accepted outside our universe. #open [#063]
    #
    #   - ultimately what is happening with the expression exposures #here1
    #     is that we are loading a "magnetic" class in the ordinary way
    #     and building (by passing what remains in the scanner) it and
    #     executing it.
    #
    #   - however we want our interface to disallow the direct use of
    #     particular class constants in such expressions so that our
    #     "expression specification" (i.e iambic expression) endures as
    #     somewhat more "readable" and insulated from whatever the
    #     particular implementation is today.
    #
    #   - under #tombstone-A we used to drive this by something like a
    #     hand-written [#pl-024], but A) this was more trouble than it was
    #     worth and B) it hindered readability, debugability and flexibility..
    #
    # :#spot1.5

    class << self

      # ~ :#here1

      def express * sx

        scn = Scanner_[ sx ]
        _cls = _parse_class scn
        _cls.interpret_and_express_ scn
      end

      def expression_session_for * sx
        __expression_session_via_sexp sx
      end

      def __expression_session_via_sexp sx  # #testpoint

        scn = Scanner_[ sx ]
        _cls = _parse_class scn
        _cls.interpret_ scn
      end

      def _parse_class scn

        _const =
        case scn.head_as_is
        when :list
          scn.advance_one
          Keywords_must_be[ :via, scn ]
          case scn.head_as_is
          when :eventing
            scn.advance_one
            :List_via_Eventing
          when :columnar_aggregation
            scn.advance_one
            :List_via_ColumnarAggregation_of_Phrases
          else ; etc
          end
        else ; etc
        end

        Home_::Magnetics.const_get _const, false
      end

      # ~
    end  # >>

    # ==

    class MagneticConst_via_Tokens  # [hu] only

      # being that these are considered "magnetics", this parser should move
      # to the post-contemporaneous [ta]. at writing we tried to leverage
      # that one, but the syntax was different enough that this was warranted.

      class << self

        def via_head head
          _via_token_array head.split DASH_
        end

        def _via_token_array s_a
          _scn = Scanner_[ s_a ]
          new( _scn ).execute
        end
      end  # >>

      def initialize scn
        @_result_pieces = []
        @_scanner = scn
      end

      def execute
        if __token_is_head_keyword
          _joiney_joiney
        else
          _joiney_joiney
        end
        __finish
      end

      def __finish
        @_result_pieces.join( UNDERSCORE_ ).intern
      end

      def _joiney_joiney

        _one_business_part
        until @_scanner.no_unparsed_exists
          __one_keyword
          _one_business_part
        end
        NIL
      end

      def __one_keyword
        _is_keyword || fail
        @_result_pieces.push @_scanner.gets_one
        NIL
      end

      def _one_business_part

        @_business_buffer = ""

        __must_not_be_keyword
        _accept_business_token
        until @_scanner.no_unparsed_exists || _is_keyword
          _accept_business_token
        end

        @_result_pieces.push @_business_buffer

        NIL
      end

      def __must_not_be_keyword
        _is_keyword && fail
      end

      def _accept_business_token
        _s = @_scanner.gets_one
        @_business_buffer.concat Ucfirst_[ _s ]
        NIL
      end

      def _is_keyword
        KW___[ @_scanner.head_as_is ]
      end

      KW___ = {
        'and' => true,
        'of' => true,
        'via' => true,
      }

      def __token_is_head_keyword
        if THE_ONLY_HEAD_KEYWORD___ == @_scanner.head_as_is
          @_scanner.advance_one
          @_result_pieces.push 'Express'
          ACHIEVED_
        end
      end

      THE_ONLY_HEAD_KEYWORD___ = 'express'
    end

    # ==

    Keywords_must_be = -> * sym_a, scn do

      sym_a.each do |sym|
        if scn.no_unparsed_exists
          raise ::ArgumentError, "expecting '#{ sym }' at end of iambic expression"
        end
        if sym != scn.head_as_is
          raise ::ArgumentError, "expecting '#{ sym }' at '#{ scn.head_as_is }'"
        end
        scn.advance_one
      end
    end

    # ==
    # ==
  end
end
# :#tombstone-A: unification into magnetics
