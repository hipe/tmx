module Skylab::Human

  module NLP::EN::Sexp

    class Expression_Sessions::List

      # this is what has become of the "oxford comma" algorithm.
      #
      # (by default not actually oxford comma, it's just a mnemonic name.)
      #
      # it expresses a stream of 0-N items thru two kinds of separators
      # (a "final" separator and a non-final separator), to make expressions
      # like "A, B and C" from lists like `%w(A B C)`.
      #
      # internally it requires *two* items of lookahead.
      #
      # (coverd by the "proof of concept" test #here-1)
      #
      # ancestors that are assimilation candidates are tracked with [#050]

      class << self
        def via_sexp__ x
          new.__init_via_sexp x
        end
        private :new
      end  # >>

      def initialize
        @_expag = nil
        @_fsep_sexp = nil
        @_none_sexp_proc = nil
        @_sep_sexp = nil
      end

      def __init_via_sexp sexp

        d = sexp.length
        if 1 < d
          _accept_list_x sexp.fetch 1
          if 2 < sexp.length
            ___parse_inline_specification sexp
          end
        end

        self
      end

      def ___parse_inline_specification sexp
        st = Callback_::Polymorphic_Stream.via_start_index_and_array 2, sexp
        begin
          send st.gets_one, st  # ..
        end until st.no_unparsed_exists
      end

      def with_list x

        o = dup
        o._accept_list_x x
        o
      end

      def _accept_list_x x

        @_build_stream_once = if ::Array.try_convert x
          -> do
            Callback_::Polymorphic_Stream.via_array x
          end
        else
          pst = x.flush_to_polymorphic_stream  # fail early
          -> { pst }
        end
        NIL_
      end

    private  # (all for the interpretation of "flags" in the sexp (for now))

      def alternation _
        be_alternation
      end

      def none _
        @_none_sexp_proc = -> do
          NONE___
        end
        NIL_
      end

    public

      def be_alternation
        @_fsep_sexp = Callback_::Known_Known[ FINAL_SEPARATOR_FOR_ALTERNATION___ ]
        NIL_
      end

      def expression_agent_method_for_saying_item m
        @__eemfsi = m ; nil
      end

      def express_none_by & p
        @_none_sexp_proc = -> do
          # ..
          s = p[]
          if s
            [ :wordish, s ]  # assume it's meant to stand alone
          else
            THE_EMPTY_SEXP___  # don't let this end the stream..
          end
        end ; nil
      end

      def final_separator= x
        self.final_separator_sexp = Home_::Phrase_Assembly::Guess_sexp_via_string[ x ]
      end

      def final_separator_sexp= x
        @_fsep_sexp = Callback_::Known_Known[ x ] ; nil
      end

      def separator= x
        self.separator_sexp = Home_::Phrase_Assembly::Guess_sexp_via_string[ x ]
      end

      def separator_sexp= x
        @_sep_sexp = Callback_::Known_Known[ x ] ; nil
      end

      # --

      def say
        s = express_into ""
        if s.length.nonzero?
          s
        end
      end

      def express_into y
        _st = _sexp_stream_via_finish
        _st_ = Progressive_string_stream_via_sexp_stream___[ _st ]
        Flush_string_stream_into__[ y, _st_ ]
      end

      def express_words_into_under y, expag
        @_expag = expag
        express_words_into y
      end

      def inflect_words_into_against_sentence_phrase y, _

        # #open [#051] - these shouldn't be words but phrase assembly sexp's
        # then we could knock out all that stuff with word streaming..

        y << ':'
        express_words_into y
      end

      def inflect_words_into_against_noun_phrase y, _
        express_words_into y
      end

      def express_words_into y
        _st = flush_to_word_string_stream___
        Flush_string_stream_into__[ y, _st ]
      end

      def flush_to_word_string_stream___
        _st = _sexp_stream_via_finish
        Home_::Phrase_Assembly::Word_string_stream_via_sexp_stream[ _st ]
      end

      # --

      def _sexp_stream_via_finish  # #todo functional spaghetti - cleanup after lockdown

        st = ___item_stream_via_finish

        p = -> do

          if st.no_unparsed_exists
            p = EMPTY_P_
            ___any_sexp_when_none
          else

            first = st.gets_one
            if st.no_unparsed_exists  # == when one
              p = EMPTY_P_
              [ :wordish, first ]
            else
              final = st.gets_one

              begin_phrase_assembly = -> do
                Home_::Phrase_Assembly.begin_phrase_builder
              end

              final_p = -> do
                p = EMPTY_P_
                pa = begin_phrase_assembly[]
                pa.add_any_sexp __final_separator_sexp
                pa.add_any_string final
                pa.sexp_via_finish
              end

              if st.no_unparsed_exists  # == when two
                p = final_p
                [ :wordish, first ]

              else  # == when three or more

                # egads four categories:
                #                           (C)
                # "foo,"     " bar,"    " bizzo"   " and blammo"  # normal mode
                # "foo,"     "bar,"     "bizzo"    "and blammo"   # word mode

                memo = final ; final = nil

                sep_sexp = __separator_sexp

                hamm = -> item_s do

                  pa = begin_phrase_assembly[]
                  pa.add_any_string item_s
                  pa.add_any_sexp sep_sexp
                  pa.sexp_via_finish
                end

                p = -> do

                  item_s = memo
                  memo = st.gets_one

                  if st.no_unparsed_exists
                    final = memo
                    p = final_p

                    pa = begin_phrase_assembly[]
                    pa.add_any_string item_s
                    pa.sexp_via_finish
                  else
                    hamm[ item_s ]
                  end
                end

                hamm[ first ]
              end
            end
          end
        end

        Callback_.stream do
          p[]
        end
      end

      def ___item_stream_via_finish

        expag = remove_instance_variable :@_expag
        if expag

          _m = remove_instance_variable :@__eemfsi  # ..

          _p = expag.method _m

          orig_strmr = @_build_stream_once

          @_build_stream_once = -> do

            _st = orig_strmr[].flush_to_stream
            _st_ = _st.map_by( & _p )
            _st_.flush_to_polymorphic_stream
          end
        end

        remove_instance_variable( :@_build_stream_once )[]
      end

      def ___any_sexp_when_none
        p = @_none_sexp_proc
        if p
          p[]
        end
      end

      def __final_separator_sexp

        @_fsep_sexp ? @_fsep_sexp.value_x : FINAL_SEPARATOR___
      end

      def __separator_sexp

        @_sep_sexp ? @_sep_sexp.value_x : SEPARATOR___
      end

      Progressive_string_stream_via_sexp_stream___ = -> st do

        # "normally" (i.e not in "word mode") the onus is on us to add
        # spaces to the beginnings of subsequent "phrases" ..
        #
        #     "foo", " and bar"

        prev = nil

        main = -> do
          begin
            sx = st.gets
            sx or break
            if :the_empty_sexp == sx.first
              redo
            end
            s = if Home_::Phrase_Assembly::Add_space_between[ prev, sx ]
              "#{ SPACE_ }#{ sx.fetch 1 }"
            else
              sx.fetch 1
            end
            prev = sx
            break
          end while nil
          s
        end

        p = -> do
          begin
            sx = st.gets
            sx or break
            if :the_empty_sexp == sx.first
              redo
            end
            prev = sx
            p = main
            s = sx.fetch 1
            break
          end while nil
          s
        end

        Callback_.stream { p[] }
      end

      Flush_string_stream_into__ = -> y, st do

        begin
          s = st.gets
          s or break
          y << s
          redo
        end while nil
        y
      end

      FINAL_SEPARATOR___ = [ :wordish, 'and' ]

      FINAL_SEPARATOR_FOR_ALTERNATION___ = [ :wordish, 'or' ]

      SEPARATOR___ = [ :trailing, ',' ]

      THE_EMPTY_SEXP___ = [ :the_empty_sexp ]

      NONE___ = [ :wordish, '[none]' ]
    end
  end
end
# #history (moved here from elsewhere) "a storied history"
