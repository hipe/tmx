module Skylab::Human

  module NLP::EN

    class SimpleInflectionSession  # [#032]

      class << self

        def edit_module mod, * x_a
          x_a.length.zero? and self._NEVER
          edit_module_via_iambic mod, x_a
        end
      end  # >>

      # this WAS its hacky power:
      #
      #   "#{ s a, :no }known person#{ s a } #{ s a, :is } #{ and_ a }".strip
      #
      # note there is redundancy with passing the `a` argument multiple times.
      #
      # the extended form of this is concerned with mitigating that redundancy:

      # (don't add constants to the client module)

#===BEGIN NEW

      # the code in this section is a fully blind mostly rewrite of whatever
      # code remains in this file after this section (probably).
      #
      # it is spiritually quite similar to its forebear, but
      #
      #   - unlike whatever the forebear did, we are decidedly only a single
      #     module meant to extend an instance of an expression agent.
      #
      #   - whereas the forebear was loosey goosey about letting you write
      #     the count multiple times in one session, we are not.
      #
      #   - for code readablilty and decoupling, we implement all these
      #     hacky mans anew rather than reach up
      #
      #   - very soon we are going to do something massive to shrink this up

      module Methods

        # exactly [#ze-040.3]

        def oxford_join buff, scn=nil, final=AND__, sep=COMMA_SPACE__, & p

          count = 0
          use_p = if p
            -> x { count += 1 ; calculate x, & p }
          else
            -> x { count += 1 ; x }
          end
          x = oxford_join_do_not_store_count buff, scn, final, sep, & use_p
          write_count_for_inflection count
          x
        end

        def oxford_join_do_not_store_count buff, scn=nil, final=AND__, sep=COMMA_SPACE__, & p

          if ! scn
            # ick/meh: the scanner is the only required argument; all others
            # have defaults. but convention dictates that buffer is leftmost.
            scn = buff ; buff = ""
          end

          OxfordJoin___.call_by do |o|
            o.buffer = buff
            o.scanner = scn
            o.map_by = p || IDENTITY_
            o.nonfinal_separator = sep
            o.final_separator = final
            o.expression_agent = self
          end
        end

        def the_only  # #coverpoint-1-1
          @_is_negative_HU = true
          d = count_for_inflection
          case 1 <=> d
          when -1 ; "none of the #{ d }"
          when  0 ; "the only"
          when  1 ; "there are no"
          else never
          end
        end

        def no_double_negative s  # #coverpoint-1-1
          @_is_negative_HU = true
          d = count_for_inflection
          case 1 <=> d
          when -1 ; _verb_HU d, false, s
          when  0 ; "fails to #{ _verb_HU d, false, s }"
          when  1 ; "so nothing #{ _verb_HU d, false, s }"
          else never
          end
        end

        def none_of_them s
          @_is_negative_HU = true
          case count_for_inflection
          when 2 ; "neither or them #{ _verb_HU 0, true, s }"
          when 1 ; "it does not #{ v s }"
          when 0 ; "there is nothing to #{ _verb_HU 0, true, s }"
          else   ; "none of them #{ v s }"
          end
        end

        def both_or_all numberish=nil
          _d = numberish ? write_count_for_inflection( numberish ) : count_for_inflection
          case _d
          when 0..1 ;
          when 2    ; "both"
          else      ; "all"
          end
        end

        def both_
          if 2 == count_for_inflection
            "both "
          end
        end

        def all_
          if 2 < count_for_inflection
            "all "
          end
        end

        def v numberish=nil, mixed_string

          # awfuly, numberish if TRUE or FALSE is the polarity of the verb..

          if numberish
            if true == numberish
              @_is_negative_HU = false ; yes = true ; d = count_for_inflection
            else
              d = write_count_for_inflection numberish ; yes = ! _is_negative_HU
            end
          elsif numberish.nil?
            d = count_for_inflection ; yes = ! _is_negative_HU
          else
            @_is_negative_HU = true ; yes = false ; d = count_for_inflection
          end

          _verb_HU d, yes, mixed_string
        end

        def n numberish=nil, mixed_string

          _d = numberish ? write_count_for_inflection( numberish ) : count_for_inflection
          _noun_HU _d, mixed_string
        end

        def _verb_HU count, yes=true, mixed_string
          if mixed_string.respond_to? :id2name
            __inflect_irregular_verb_HU count, yes, mixed_string
          else
            __inflect_verb_hackily_HU count, yes, mixed_string
          end
        end

        def __inflect_irregular_verb_HU count, yes, sym
          case sym
          when :is ; ( 1 == count ? "is" : "are" ).tap { |s| yes or s << "n't" }
          else ; never
          end
        end

        def __inflect_verb_hackily_HU count, yes, mixed_string

          # SUPER hacky: conjugate verbs for count with the exact same
          # underlying logic as we use for the noun hack:
          # 0: "nothing floofs"  1: "it floofs"  2: "they floof"

          if yes
            case 1 <=> count
            when -1 ; _noun_HU 1, mixed_string  # ~2: they make
            when  0 ; _noun_HU 2, mixed_string  #  1: it makes
            when  1 ; _noun_HU 1, mixed_string  #  0: zero Xs make
            else never
            end
          else
            case 1 <=> count
            when -1 ; _noun_HU 2, mixed_string  # ~2: none of them makes
            when  0 ; _noun_HU 1, mixed_string  #  1: it failed to make
            when  1 ; _noun_HU 2, mixed_string  #  0: [ so nothing ] makes  # EEK
            else never
            end
          end
        end

        def _noun_HU count, mixed_string

          # assume the argument noun is inflected for singular or plural,
          # and might be in all caps, and might have any number of modifier
          # words (e.g adjectives) before the final, "lemmatic"-ISH word.
          #
          # given the argument numberish, inflect the mixed string noun
          # appropriately (only if necessary) using a hack that uses some
          # rudimentary morphological rules of EN, both to interpret the
          # argument string and to produce the result. YEEHAH hacktown

          md = SING_PLUR_REGEX_HACK___.match mixed_string

          looks_plural = md.offset( :looks_plural ).first
          the_Y_category = md.offset( :the_Y_category ).first
          all_caps = md.offset( :all_caps ).first

          if _is_negative_HU
            # (all hi.)
            case count <=> 1
            when -1 ; use_count = count  # none of the N foobrics frobulate
            when  0 ; use_count = count  # the only foobric fails to forbulate
            when  1 ; use_count = count  # there are no foobrics so nothing frobulates
            else never
            end
          else
            use_count = count
          end

          if 1 == use_count
            if looks_plural
              if the_Y_category
                "#{ md.pre_match }#{ all_caps ? "Y" : "y" }"
              else
                "#{ md.pre_match }"
              end
            else
              mixed_string
            end
          elsif looks_plural
            mixed_string
          elsif the_Y_category
            "#{ md.pre_match }#{ all_caps ? "IES" : "ies" }"
          else
            "#{ md.pre_match }#{ all_caps ? "S" : "s" }"
          end
        end

        attr_reader :_is_negative_HU

        def write_count_for_inflection numberish
          count = if numberish.respond_to? :bit_length
            numberish
          else
            numberish.length
          end
          _write_count_via_integer_for_HU count
          count
        end

        def _write_count_via_integer_for_HU d
          send ( @_write_count_for_HU ||= :__write_count_initially_for_HU ), d
        end

        def __write_count_initially_for_HU d
          @_read_count_for_HU = :__read_count_for_HU
          @_write_count_for_HU = :__COUNT_ALREADY_WRITTEN
          @_count_for_HU = d ; nil
        end

        def count_for_inflection
          send @_read_count_for_HU
        end

        def __read_count_for_HU
          @_count_for_HU
        end

        def clear_count_for_inflection
          remove_instance_variable :@_read_count_for_HU
          remove_instance_variable :@_write_count_for_HU
          remove_instance_variable :@_count_for_HU ; nil
        end
      end

      # ==

      class OxfordJoin___ < Common_::MagneticBySimpleModel

        # (the age-old "algorithm" exposed as a simple model session.)
        # (this interface was going to be exposed to the public but not yet.)

        attr_writer(
          :buffer,
          :expression_agent,
          :final_separator,
          :map_by,
          :nonfinal_separator,
          :scanner,
        )

        def execute
          if @scanner.no_unparsed_exists
            @buffer << "nothing"  # a coarse default.
          else
            _receive @scanner.gets_one  # for 1st, no preceding separator
            if ! @scanner.no_unparsed_exists
              __central_algorithm
            end
          end
          @buffer
        end

        def __central_algorithm

          begin  # for all non-first non-final, preceding sep then item
            on_deck = @scanner.gets_one
            @scanner.no_unparsed_exists && break
            @buffer << @nonfinal_separator
            _receive on_deck
            redo
          end while above

          @buffer << @final_separator  # for the non-first final
          _receive on_deck
          NIL
        end

        def _receive raw
          _formatted = @expression_agent.calculate raw, & @map_by
          @buffer << _formatted ; nil
        end
      end

      SING_PLUR_REGEX_HACK___ = /  # #testpoint
        (?:

          (?<looks_plural>

            (?<the_Y_category> ies | (?<all_caps> IES ) )
            |
            (?<the_not_Y_category> s | (?<all_caps> S ) )

          )|
          (?<looks_singular>

            (?<the_Y_category>
              (?<![aeou]) y    |   (?<all_caps> (?<![AEOU]) Y )  # NOT: play convey toy guy
            )
            |
            (?<the_not_Y_category>
              (?<=[^y]) | (?<=[aeou]y) | (?<all_caps> (?<=[^Y]) | (?<=[AEOU]Y) )
            )
          )
        )
      \z/x

      AND__ = " and "
      COMMA_SPACE__ = ', '

#===END NEW

      _COLLECTION = nil
      _NMN = nil
      _SLL = nil

      define_singleton_method :edit_module_via_iambic do | mod, x_a |

        # (for now the syntax is a mirage until we need it to be fuller)

        2 == x_a.length or raise ::ArgumentError,  __say_two( x_a )

        case x_a.first
        when :private
          do_private = true
        when :public
        else
          raise ::ArgumentError, __say_visibility( x_a.first )
        end

        mod.module_exec do

          write = if do_private
            -> sym do
              define_method sym, _COLLECTION[ sym ]
              private sym
            end
          else
            -> sym do
              define_method sym, _COLLECTION[ sym ]
            end
          end

          x_a.fetch( -1 ).each( & write )
          define_method :_NLP_normalize_and_memoize_numerish, _NMN
          define_method :_set_NLP_last_length_, _SLL

        end
      end

      class << self

        def __say_visibility x
          "public or private, not: '#{ x }'"
        end

        def __say_two x_a
          "#{ x_a.length } for 2"
        end
      end  # >>

      _COLLECTION = -> do  # define all the methods

        method_name_a = []
        method_proc_a = []

        o = -> sym, p do
          method_name_a.push sym
          method_proc_a.push p
          NIL_
        end

        class << o
          alias_method :[]=, :call
        end

        %i| an an_ |.each do | sym |

          o[ sym ] = -> lemma, x=false do

            _x_ = _NLP_normalize_and_memoize_numerish x
            EN_[ sym ][ lemma, _x_ ]
          end
        end

        o[ :_and ] = -> a do  # (when you want the leading space conditionally on etc)

          s = and_ a
          if s
            "#{ SPACE_ }#{ s }"
          else
            s
          end
        end

        _Memoize_length__ = -> & p do

          -> a do
            _set_NLP_last_length_ a.length
            instance_exec a, &p
          end
        end

        o[ :both ] = _Memoize_length__.call do | a |
          EN_.both a
        end

        o[ :indefinite_noun ] = -> lemma_s do

          EN_::POS.indefinite_noun lemma_s
        end

        o[ :_non_one ] = -> x=nil do  # for nlp hacks, leading space iff not 1

          x_ = _NLP_normalize_and_memoize_numerish x
          if 1 != x_
            "#{ SPACE_ }#{ x_ }"
          end
        end

        _NP = [ :when, :syntactic_category, :noun_phrase ]
        o[ :noun_phrase ] = -> * x_a do
          x_a[ 0, 0 ] = _NP
          _fr = EN_::Sexp.expression_session_via_sexp x_a
          _fr.express_into ""
        end

        o[ :plural_noun ] = -> count_d=nil, lemma_s do

          EN_::POS.plural_noun count_d, lemma_s
        end

        o[ :preterite_verb ] = -> lemma_s do

          EN_::POS.preterite_verb lemma_s
        end

        o[ :progressive_verb ] = -> lemma_s do

          EN_::POS.progressive_verb lemma_s
        end

        o[ :s ] = -> * args do  # [length] [lexeme_i]

          len_x, lexeme_sym = Home_.lib_.parse.parse_serial_optionals(

            args,
            -> x { ! x.respond_to? :id2name },  # defer it
            -> x { x.respond_to? :id2name },
          )

          lexeme_sym ||= :s

          # when `len_x` is nil it means "use memoized"

          if :identity == lexeme_sym

            _NLP_normalize_and_memoize_numerish len_x
          else

            _x_ = _NLP_normalize_and_memoize_numerish len_x
            EN_.s _x_, lexeme_sym
          end
        end

        _SP = [ :when, :syntactic_category, :sentence_phrase ]

        o[ :sentence_phrase_via_mutable_iambic ] = -> x_a do

          x_a[ 0, 0 ] = _SP
          _fr = EN_::Sexp.expression_session_via_sexp x_a
          _fr.express_into ""
        end

        -> do
          o[ :and_ ] = _Memoize_length__.call do |a|
            EN_::Oxford_and[ a ]
          end

          o[ :or_ ] = _Memoize_length__.call do |a|
            EN_::Oxford_or[ a ]
          end
        end.call

        ::Struct.new( * method_name_a ).new( * method_proc_a )

      end.call

      _NMN = -> x do  # normalize and memoize numerish

        if x

          x_ = ( if x.respond_to? :length  # result

            x.length
          else
            x
          end )

          _set_NLP_last_length_ x_
          x_

        elsif false == x
          false
        else
          @__NLP_last_length__
        end
      end

      _SLL = -> x do  # set last length
        @__NLP_last_length__ = x ; nil
      end
    end
  end
end
