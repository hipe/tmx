module Skylab::Human

  module NLP::EN::Sexp

    class << self

      def say * sexp
        express_into "", sexp
      end

      def express_into y, sexp
        expression_session_via_sexp( sexp ).express_into y
      end

      def expression_session_for * sexp
        expression_session_via_sexp sexp
      end

      def expression_session_via_sexp sx
        __expression_session_via_sexp_stream _ps sx
      end

      def association_via_symbol_ sym
        Require_fields_lib_[]
        Field_::SimplifiedName.new sym do end
      end

      def expression_via_these_ sx, asc
        st = _ps sx
        _cls = _lookup_class st
        _cls.interpret_component_with_own_stream_ st, asc
      end

      def _ps x
        Common_::Polymorphic_Stream.via_array x
      end

      def __expression_session_via_sexp_stream st

        if :when == st.current_token
          st.advance_one
          ___magnetic_collection.expression_session_via_sexp_stream__ st
        else
          _cls = _lookup_class st
          _cls.expression_via_sexp_stream_ st
        end
      end

      def ___magnetic_collection
        @___mc ||= Home_::Sexp::Expression_Collection.
          new_via_multipurpose_module__( EN_::Sexp::Expression_Sessions )
      end

      def _lookup_class st
        _const = Home_::Sexp::Parse_expression_session_name[ st ]
        Expression_Sessions.const_get _const, false
      end
    end  # >>

    module AnyExpression ; class << self

      def interpret_component st, asc
        _sx = st.gets_one
        st_ = Common_::Polymorphic_Stream.via_array _sx
        _cls = Here_._lookup_class st_
        _cls.interpret_component_with_own_stream_ st_, asc
      end
    end ; end

    class String_as_Expression_

      class << self
        alias_method :[], :new
        private :new
      end  # >>

      def initialize x, asc
        @_x = x
        @_ASC = asc
      end

      def express_into_under y, _
        y << @_x
      end

      def _difference_against_counterpart_ otr
        otr._x != @_x  # #equivalence
      end

      attr_reader :_x
      protected :_x

      def category_symbol_
        :_plain_old_string_
      end
    end

    Siblings_ =
    module Expression_Sessions

      class ForExpag  # #stowaway

        class << self

          alias_method :interpret_component_with_own_stream_, :new
          undef_method :new
        end  # >>

        def initialize st, asc

          @_m = st.gets_one
          @_x = st.gets_one
          st.assert_empty
        end

        def express_into_under y, expag
          y << expag.send( @_m, @_x )
        end

        def _difference_against_counterpart_ otr
          if otr._m == @_m
            if otr._x == @_x
              NOTHING_
            else
              :_x_
            end
          else
            :_m_
          end
        end

        attr_reader :_m, :_x
        protected :_m, :_x

        def category_symbol_
          :_for_expag_
        end
      end

      class WordList  # #stowaway

        class << self

          def interpret_component st, asc
            new( asc ).__init_comp st
          end

          def interpret_component_with_own_stream_ st, asc
            new( asc ).__init_own st
          end

          private :new
        end

        def initialize asc
          @_asc = asc
        end

        def __init_comp st
          @_s_a = st.gets_one
          self
        end

        def __init_own st
          @_s_a = st.gets_one
          st.assert_empty
          self
        end

        # --

        def express_into_under y, _expag
          st = Common_::Polymorphic_Stream.via_array @_s_a
          y << st.gets_one
          until st.no_unparsed_exists
            y << SPACE_
            y << st.gets_one
          end
          y
        end

        # -- see [#050]:"note about aggregating word-lists"

        def _can_aggregate_
          true
        end

        def _difference_against_counterpart_ otr
          otr._s_a != @_s_a  # #equivalence
        end

        attr_reader :_s_a
        protected :_s_a

        # --
      end

      class Freeform_Phrase

        class << self

          def interpret_component st, _asc
            x = st.gets_one
            if x
              via_ x
            else
              x  # life is easier to allow the client to pass nils
            end
          end

          def via_ x
            if x.respond_to? :ascii_only?
              String_as_Freeform_Phrase___.new x
            elsif x.respond_to? :id2name
              Symbol_as_Freeform_Phrase.new x
            else
              self._K
            end
          end
        end
      end

      class String_as_Freeform_Phrase___ < Freeform_Phrase

        def initialize s
          @_s = s
        end

        def _as_string
          @_s
        end

        def _inner_x
          @_s
        end
      end

      class Symbol_as_Freeform_Phrase < Freeform_Phrase

        def initialize sym
          @_sym = sym
        end

        def _as_string
          @_sym.id2name
        end

        def _inner_x
          @_sym
        end
      end

      class Freeform_Phrase  # (re-open)

        def express_into_phrase_builder__ pb
          pb.add_string _as_string
          NIL_
        end

        def express_into_under y, _
          y << _as_string
        end

        def _can_aggregate_
          true
        end

        def _difference_against_counterpart_ x
          _inner_x != x._inner_x
        end
      end

      Autoloader_[ self ]
      self
    end

    EN_ = NLP::EN
    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
    Here_ = self
  end
end
