module Skylab::Human

  module NLP::EN

    class SimpleInflectionSession  # [#032]

      # this is a old/new hybrid node. #todo the counterpart document is only for the older

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
      #

      # the spec file (#cov2.0) has usage documentation

      module Methods

        # exactly #open [#ze-040.3] unify expression agent-ry between niCLI and iCLI

        # -- oxford join & family

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

        # -- these (the main functions)

        def the_only  # #cov2.1
          @_is_negative_HU = true
          d = count_for_inflection
          case 1 <=> d
          when -1 ; "none of the #{ d }"
          when  0 ; "the only"
          when  1 ; "there are no"
          else never
          end
        end

        def the_only_
          if 1 == count_for_inflection
            'the only '
          end
        end

        def no_double_negative lemma_x  # #cov2.1

          # (strongly recommended that you read the explanation at the spec)
          # (also has [#008.1] supplemental coverage by [br])

          v = _verb_HU lemma_x
          is_preterite = v.is_preterite  # (snuck in through irregular, for now)
          _d = count_for_inflection
          @_is_negative_HU = true

          case 1 <=> _d
          when -1
            if is_preterite
              v.to_string  # "[none of the 10 foobrics] were about"
            else
              v.be_singular.to_string  # "[none of the 10 foobrics] brings"
            end
          when 0
            if is_preterite
              v.to_negative.to_string  # "[the only foobric] was not about"
            else
              "fails to #{ v.to_string }"  # "[the only foobric] fails to bring"
            end
          when 1
            if is_preterite
              "so nothing #{ v.to_string }"  # "[there were no foobrics] so there was nothing about"
            else
              "so nothing #{ v.be_singular.to_string }"  # "so nothing brings"
            end
          else ; never
          end
        end

        def none_of_them s

          v = _verb_HU s

          @_is_negative_HU = true
          case count_for_inflection
          when 2 ; "neither of them #{ v.be_singular.to_string }"
          when 1 ; "it does not #{ v.to_string }"
          when 0 ; "there is nothing to #{ v.to_string }"
          else   ; "none of them #{ v.to_string }"
          end
        end

        def this_or_these
          _d = count_for_inflection
          case _d
          when 1    ; "this"
          else      ; "these"
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

        def v numberish_or_polarity=nil, mixed_string

          if numberish_or_polarity
            if true == numberish_or_polarity
              yes = true
            else
              numberish = numberish_or_polarity
            end
          elsif false == numberish_or_polarity
            yes = false
          end

          if yes.nil?
            yes = ! _is_negative_HU
          else
            @_is_negative_HU = ! yes
          end

          count = if numberish
            write_count_for_inflection numberish
          else
            count_for_inflection
          end

          _verb_HU( mixed_string ).have_count( count ).have_polarity( yes ).to_string
        end

        def indef lemma_s

          d = count_for_inflection

          tail = _noun_HU( lemma_s ).have_count( d ).to_string

          if 1 == d
            "#{ An_[ lemma_s, d ] }#{ tail }"
          else
            tail
          end
        end

        def n numberish=nil, mixed_string

          _d = numberish ? write_count_for_inflection( numberish ) : count_for_inflection

          _noun_HU( mixed_string ).have_count( _d ).to_string
        end

        # -- these two

        def _noun_HU mixed_s
          MutableInflectedNoun_REDUX__.new mixed_s
        end

        def _verb_HU mixed
          if mixed.respond_to? :id2name
            Irregular_verbs__[].dereference( mixed ).duplicate
          else
            MutableInflectedVerb_REDUX___.new mixed
          end
        end
      end

      # ==

      Irregular_verbs__ = Lazy_.call do

        # just whatever:
        #
        #   - the only irregular verb we care about for now is "the copula"
        #     (to be: "am", "is", "are", "was", "were")
        #
        #   - in practive we never need to produce procecurally weird
        #     grammatical cases like subjunctive ("if it were") or
        #     infinitive ("to be")
        #
        #   - in practice we never need first person or second person, only 3rd
        #     (if we produce "I", "we" or "you", its count is not variable.)
        #
        #   - in practice the tense is never procedurally variable. (whether
        #     the expression is in present tense or past tense (preterite)
        #     is fixed in the code.)
        #
        #   - so which of the two tenses to start the mutable inflected verb
        #     off as is determined by which of two surface forms is used to
        #     reference the verb: `is` or `was`
        #
        #   - typically the only variable, then, is the count of the subject
        #     but our `to_string` implementation is broader than that (but
        #     only slightly).
        #
        #   - this amounts to a massive simplification of what the `POS`
        #     library attempts which, in turn, is a massive simplification
        #     of a robust EN natural language production system.

        class TheCopula___ < Common_::SimpleModel

          def to_string
            if @is_positive
              _to_string_before_polarity
            else
              "#{ _to_string_before_polarity }n't"  # see #cov2.2
            end
          end

          def _to_string_before_polarity
            if @is_preterite
              if @is_plural
                "were"
              else
                "was"
              end
            elsif @is_plural
              "are"
            else
              "is"
            end
          end
        end

        class TheCopula___  # re-open

          def initialize
            @is_positive = true
            @is_plural = false
            @is_preterite = false
            super
          end

          def to_negative
            redefine do |o|
              o.have_polarity false
            end
          end

          def redefine
            otr = dup
            yield otr
            otr.freeze
          end

          def duplicate
            dup
          end

          def have_polarity yes
            @is_positive = yes ; self
          end

          def have_count d
            @is_plural = 1 != d ; self
          end

          def be_preterite
            @is_preterite = true ; self
          end

          attr_reader(
            :is_preterite,
          )
        end

        the_copula = TheCopula___.define { }

        oo = {}

        oo[ :is ] = the_copula

        oo[ :was ] = the_copula.redefine do |o|
          o.be_preterite
        end

        irregs =  module IRREGULAR_VERBS___ ; self end
        irregs.send :define_singleton_method, :dereference do |sym|
          oo.fetch sym
        end
        irregs
      end

      # ==

      # ==

      class MutableInflectedVerb_REDUX___

        def initialize lemma_s
          @_to_string = :_to_string_when_infinitive_stem
          @_frozen_lemma_string = lemma_s.freeze  # meh
          @polarity = true
        end

        def have_count d
          if 1 == d
            be_singular
          else
            @_to_string = :_to_string_when_infinitive_stem
          end
          self
        end

        def be_singular
          @_to_string = :__to_string_when_singular
          self
        end

        def have_polarity yes
          @polarity = yes ; self
        end

        def to_string
          send @_to_string
        end

        def __to_string_when_singular

          # "singular" = "inflect the verb for a singular subject noun phrase".

          # SUPER hacky: conjugate verbs for count with the exact same
          # underlying logic as we use for the noun hack:
          # 0: "nothing floofs"  1: "it floofs"  2: "they floof"

          if @polarity
            MutableInflectedNoun_REDUX__.
              new( @_frozen_lemma_string ).
              have_count( 3 ).
              to_string
          else
            self._COVER_ME__xx__
          end
        end

        def _to_string_when_infinitive_stem
          if @polarity
            @_frozen_lemma_string  # ..
          else
            self._COVER_ME__xx__
          end
        end

        def is_preterite
          FALSE
        end
      end

      # ==

      class MutableInflectedNoun_REDUX__

        def initialize s
          @mixed_string = s
        end

        def have_count d
          @count = d ; self
        end

        def to_string

          # assume the argument noun is inflected for singular or plural,
          # and might be in all caps, and might have any number of modifier
          # words (e.g adjectives) before the final, "lemmatic"-ISH word.
          #
          # given the argument numberish, inflect the mixed string noun
          # appropriately (only if necessary) using a hack that uses some
          # rudimentary morphological rules of EN, both to interpret the
          # argument string and to produce the result. YEEHAH hacktown

          count = self.count || 3  # "i love elephants" not "i love elephant"
          is_negative = self.is_negative
          mixed_string = @mixed_string

          md = SING_PLUR_REGEX_HACK___.match mixed_string

          looks_plural = md.offset( :looks_plural ).first
          the_Y_category = md.offset( :the_Y_category ).first
          all_caps = md.offset( :all_caps ).first

          if is_negative
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

        attr_reader(
          :count,
          :is_negative,
        )
      end

      # ==

      module Methods  # re-open

        # -- write and read the exponents of grammatical categories

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

        _NP = [ :magnetic_idea, :syntactic_category, :noun_phrase ]
        o[ :noun_phrase ] = -> * x_a do
          x_a[ 0, 0 ] = _NP
          _fr = EN_::Sexp.interpret_ Scanner_[ x_a ]
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

        _SP = [ :magnetic_idea, :syntactic_category, :sentence_phrase ]

        o[ :sentence_phrase_via_mutable_iambic ] = -> x_a do

          x_a[ 0, 0 ] = _SP
          _fr = EN_::Sexp.interpret_ Scanner_[ x_a ]
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

#==BEGIN NEW (again)



#==END NEW (again)
    end
  end
end
