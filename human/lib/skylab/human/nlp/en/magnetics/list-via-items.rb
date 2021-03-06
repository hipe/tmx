module Skylab::Human

  module NLP::EN

    class Magnetics::List_via_Items < Common_::SimpleModel  # [here] only

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
      # (coverd by the "proof of concept" test at #spot1.1)
      #
      # this underlying algorithm can be accomplished in about two lines
      # (attested by the only remaining (ancient) cousin of this is one
      # in [ba] at our [#050]). the bulk of this file, then, is as a proof-
      # of-concept for [#049] the new "sexp" facility; as well as having
      # robustified against the cousin in that it can produce streaming
      # output from streaming input in either "word mode" or "flat" mode.

      class << self

        def via_ * x_a
          interpret_ Scanner_[ x_a ]
        end

        def interpret_ scn
          define.__init_via_sexp_scanner scn
        end

        def interpret_component scn, asc
          define.__init_as_component scn, asc
        end
      end  # >>

      def initialize
        @_expag = nil
        @_fsep_sexp = nil
        @_none_sexp_proc = nil
        @_sep_sexp = nil
        if block_given?  # tricky
          yield self
          freeze
        else
          self
        end
      end

      define_method :redefine, self::DEFINITION_FOR_THE_METHOD_CALLED_REDEFINE

      def __init_as_component scn, asc

        _init_constituency_via_mixed scn.gets_one
        @_association_symbol = asc.name_symbol
        self
      end

      def __init_via_sexp_scanner scn

        if scn.unparsed_exists
          _init_constituency_via_mixed scn.gets_one
          if scn.unparsed_exists
            ___parse_inline_specification scn
          end
        end

        self
      end

      def ___parse_inline_specification scn
        begin
          send scn.gets_one, scn  # ..
        end until scn.no_unparsed_exists
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

      def association_symbol scn
        @_association_symbol = scn.gets_one ; nil
      end

      def none _
        @_none_sexp_proc = -> do
          NONE___
        end
        NIL_
      end

    public

      def be_alternation
        @_fsep_sexp = Common_::KnownKnown[ FINAL_SEPARATOR_FOR_ALTERNATION___ ]
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
        self.final_separator_sexp = Home_::PhraseAssembly::Guess_sexp_via_string[ x ]
      end

      def final_separator_sexp= x
        @_fsep_sexp = Common_::KnownKnown[ x ] ; nil
      end

      def separator= x
        self.separator_sexp = Home_::PhraseAssembly::Guess_sexp_via_string[ x ]
      end

      def separator_sexp= x
        @_sep_sexp = Common_::KnownKnown[ x ] ; nil
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
        _scn = _assembly_sexp_scanner_via_finish
        _st = Progressive_string_stream_via_assembly_sexp_scanner___[ _scn ]
        Flush_string_stream_into__[ y, _st ]
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
        _scn = _assembly_sexp_scanner_via_finish
        Home_::PhraseAssembly::Word_string_stream_via_sexp_scanner[ _scn ]
      end

      # --

      def _assembly_sexp_scanner_via_finish  # #todo functional spaghetti - cleanup after lockdown

        scn = __item_stream_via_finish

        p = -> do

          if scn.no_unparsed_exists
            p = EMPTY_P_
            ___any_sexp_when_none
          else

            first = scn.gets_one
            if scn.no_unparsed_exists  # == when one
              p = EMPTY_P_
              [ :wordish, first ]
            else
              final = scn.gets_one

              begin_phrase_assembly = -> do
                Home_::PhraseAssembly.begin_phrase_builder
              end

              final_p = -> do
                p = EMPTY_P_
                pa = begin_phrase_assembly[]
                pa.add_any_sexp __final_separator_sexp
                pa.add_any_string final
                pa.sexp_via_finish
              end

              if scn.no_unparsed_exists  # == when two
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
                  memo = scn.gets_one

                  if scn.no_unparsed_exists
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

        Common_.stream do
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
        _scn = _pst.flush_to_stream
        _st_ = _scn.map_by( & _p )
        _st_.flush_to_scanner
      end

      def __final_separator_sexp

        @_fsep_sexp ? @_fsep_sexp.value : FINAL_SEPARATOR___
      end

      def __separator_sexp

        @_sep_sexp ? @_sep_sexp.value : SEPARATOR___
      end

      # --

      def _difference_against_counterpart_ bruh

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

          diff_x = NOTHING_

          a.length.times do |d|

            _x = a.fetch 0  # inside
            _x_ = a_.fetch 0  # outside

            _is_equivalent = _x_.send m, _x  # let outsider chose impl.

            if _is_equivalent
              next
            end

            diff_x = d
            break
          end

          diff_x
        else
          true
        end
      end

      def _aggregate_ o

        if :list == o.category_symbol_
          self._COVER_AND_WRITE_ME_list_on_list_concatenation
        else
          ___aggregate_non_list o
        end
      end

      def ___aggregate_non_list o

        _a = o.to_read_only_array__

        @_top_secret_array.concat _a  # mutate self or don't..

        self
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
          @__one_time_use_PST = x.flush_to_scanner
        end
        NIL_
      end

      def __build_stream_via_array
        Scanner_[ @_top_secret_array ]
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

      def person_exponent_symbol_
        :third  # ..
      end

      def _read_only_array
        send @_read_read_only_array_method
      end

      def has_content_
        @_top_secret_array.length.nonzero?
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

      Progressive_string_stream_via_assembly_sexp_scanner___ = -> scn do

        # "normally" (i.e not in "word mode") the onus is on us to add
        # spaces to the beginnings of subsequent "phrases" ..
        #
        #     "foo", " and bar"

        prev = nil

        main = -> do
          begin
            sx = scn.gets
            sx or break
            if :the_empty_sexp == sx.first
              redo
            end
            s = if Home_::PhraseAssembly::Add_space_between[ prev, sx ]
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
            sx = scn.gets
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

        Common_.stream { p[] }
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

      # ==
    end
  end
end
# #history (moved here from elsewhere) "a storied history"
