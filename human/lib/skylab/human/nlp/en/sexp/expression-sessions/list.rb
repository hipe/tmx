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
      # this underlying algorithm can be accomplished in about two lines
      # (attested by the only remaining (ancient) cousin of this is one
      # in [ba] at our [#050]). the bulk of this file, then, is as a proof-
      # of-concept for [#049] the new "sexp" facility; as well as having
      # robustified against the cousin in that it can produce streaming
      # output from streaming input in either "word mode" or "flat" mode.

      class << self

        def via_ * x_a
          _st = Callback_::Polymorphic_Stream.via_array x_a
          expression_via_sexp_stream_ _st
        end

        def expression_via_sexp_stream_ st
          new.__init_via_sexp_stream st
        end

        def interpret_component st, asc
          new.__init_as_componet st, asc
        end

        private :new
      end  # >>

      def initialize
        @_expag = nil
        @_fsep_sexp = nil
        @_none_sexp_proc = nil
        @_sep_sexp = nil
      end

      def __init_as_componet st, asc

        _init_constituency_via_mixed st.gets_one
        @_association_symbol = asc.name_symbol
        self
      end

      def __init_via_sexp_stream st

        if st.unparsed_exists
          _init_constituency_via_mixed st.gets_one
          if st.unparsed_exists
            ___parse_inline_specification st
          end
        end

        self
      end

      def ___parse_inline_specification st
        begin
          send st.gets_one, st  # ..
        end until st.no_unparsed_exists
      end

      def with_list x

        o = dup
        o._init_constituency_via_mixed x
        o
      end

    private  # (all for the interpretation of "flags" in the sexp (for now))

      def alternation _
        be_alternation
      end

      def association_symbol st
        @_association_symbol = st.gets_one ; nil
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
        @_eemfsi = m ; nil
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

      def express_into_under y, expag

        # -- eek map each expression to string

        a = _read_only_array
        x = a.fetch 0
        if ! x.respond_to? :ascii_only?
          aa = []
          a.each do |x_|
            _ = x_.express_into_under "", expag
            aa.push _
          end
          @_top_secret_array = aa  # EEK
        end

        # --

        @_eemfsi ||= nil
        @_expag = expag
        express_into y
      end

      def express_into y
        _st = _assembly_sexp_stream_via_finish
        _st_ = Progressive_string_stream_via_assembly_sexp_stream___[ _st ]
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
        _st = _assembly_sexp_stream_via_finish
        Home_::Phrase_Assembly::Word_string_stream_via_sexp_stream[ _st ]
      end

      # --

      def _assembly_sexp_stream_via_finish  # #todo functional spaghetti - cleanup after lockdown

        st = __item_stream_via_finish

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

      def ___any_sexp_when_none
        p = @_none_sexp_proc
        if p
          p[]
        end
      end

      def __item_stream_via_finish

        expag = remove_instance_variable :@_expag
        if expag
          m = remove_instance_variable :@_eemfsi
        end

        if m
          ___flush_stream_under_expag m, expag
        else
          send @_build_stream_method
        end
      end

      def ___flush_stream_under_expag m, expag

        _p = expag.method m
        _pst = send @_build_stream_method
        _st = _pst.flush_to_stream
        _st_ = _st.map_by( & _p )
        _st_.flush_to_polymorphic_stream
      end

      def __final_separator_sexp

        @_fsep_sexp ? @_fsep_sexp.value_x : FINAL_SEPARATOR___
      end

      def __separator_sexp

        @_sep_sexp ? @_sep_sexp.value_x : SEPARATOR___
      end

      # --

      def _is_equivalent_to_counterpart_ bruh

        # is one list the same as another? we are doing this the long way..
        # assume that you are the "outside" one
        # aspects of this have an involved explanation at [#050]:#flatten

        a = bruh._read_only_array  # inside
        a_ = self._read_only_array  # outside

        if a.length == a_.length

          if a.fetch( 0 ).respond_to? :_aggregate_
            self._EEW
          end

          m = :==  # #equivalence: NOT `equal?`. NOT `===`. `eql?` is "strict"

          is_same = true

          a.length.times do |d|

            _x = a.fetch 0  # inside
            _x_ = a_.fetch 0  # outside

            _is_equivalent = _x_.send m, _x  # let outsider chose impl.

            if _is_equivalent
              next
            end

            is_same = false ; break
          end

          is_same
        else
          false
        end
      end

      # -- constituency writing / reading  (see [#050]:#flatten)

      def _init_constituency_via_mixed x

        if ::Array.try_convert x
          @_build_stream_method = :__build_stream_via_array
          @_read_read_only_array_method = :__top_secret_array
          @_top_secret_array = x
        else
          @_build_stream_method = :__release_one_time_use_PST
          @_read_read_only_array_method = :_CHA_CHA
          @__one_time_use_PST = x.flush_to_polymorphic_stream
        end
        NIL_
      end

      def __build_stream_via_array
        Callback_::Polymorphic_Stream.via_array @_top_secret_array
      end

      def __release_one_time_use_PST
        remove_instance_variable :@__one_time_use_PST
      end

      # --

      def number_exponent_symbol_
        if 1 == @_top_secret_array.length  # ..
          :singular
        else
          :plural
        end
      end

      def _read_only_array
        send @_read_read_only_array_method
      end

      def __top_secret_array
        @_top_secret_array
      end

      def association_symbol_
        @_association_symbol
      end

      def category_symbol_
        :list
      end

      def _can_aggregate_
        true
      end

      Progressive_string_stream_via_assembly_sexp_stream___ = -> st do

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
