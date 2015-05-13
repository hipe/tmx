module Skylab::Human

  module NLP::EN::POS_Models_  # see [#002]. :+#stowaway

    class Lexeme  # see #introduction-to-the-lexeme

      class << self

        def grammatical_categories h

          # defines grammatical categories for e.g nouns and verbs

          @__did_init_boxes ||= __init_boxes

          h.each_pair do | cat_sym, exponent_a |

            Grammatical_Category.there_exists_a_category cat_sym

            cat = Grammatical_Category.new exponent_a

            @_category_box.add cat_sym, cat

            exponent_a.each do | exp_sym |

              @_exponent_box.add exp_sym,
                Exponent_Pair.new( exp_sym, cat_sym )
            end
          end

          NIL_
        end

        attr_reader :_category_box, :_exponent_box, :_form_box

        def __init_boxes

          cls = Callback_::Box
          @_form_box = cls.new
          @_exponent_box = cls.new
          @_category_box = cls.new
          ACHIEVED_
        end
      end  # >>

      def __init_ivars

        @_inflected_form_cache = {}
        NIL_
      end
    end

    class Grammatical_Category

      class << self

        def there_exists_a_category cat_sym

          @box_.algorithms.if_has_name cat_sym,
            -> cat do
              cat.__instance_count += 1
            end,
            -> bx, k do
              bx.add k, Exponent_Value.new( 1 )
            end

          NIL_
        end

        def box_
          @box_
        end
      end  # >>

      @box_ = Callback_::Box.new

      def initialize x

        @_exponent_array = x
      end

      attr_reader :_exponent_array

    end

    Exponent_Pair = ::Struct.new :exponent_sym, :category_sym

    Exponent_Value = ::Struct.new :__instance_count  # not used per se

    class Lexeme  # re-open 1 of N: #defining-production-strategies

      class << self

        def as combination_ID_x, & edit_p

          cmb = _build_immutable_combination combination_ID_x

          _FORM_KEY = cmb.form_key

          define_method _FORM_KEY do

            @_inflected_form_cache.fetch _FORM_KEY do

              surface_form_s = instance_exec( & edit_p )
              @_inflected_form_cache[ _FORM_KEY ] = surface_form_s  # nil oK!
              surface_form_s
            end
          end

          define_method cmb.form_writer_method_name do | x |

            @_inflected_form_cache[ _FORM_KEY ] = x  # might be ni
          end

          @_form_box.add(
            _FORM_KEY,
            Formal_Form.new( cmb, instance_method( _FORM_KEY ) )
          )

          NIL_
        end

        def _build_immutable_combination x

          cmb = _combination_class.new
          cmb.extend Exponent_Combination::Methods_for_Immutable_Combination

          combination_a = _normalize_combination_ID_x x
          combination_a.each do |exponent_sym|
            cmb[ @_exponent_box.fetch( exponent_sym ).category_sym ] = exponent_sym
          end

          cmb.freeze
        end

        def _normalize_combination_ID_x combo_x
          if ! combo_x.respond_to? :each_index
            combo_x = combo_x.to_s.split( UNDERSCORE_ ).map(& :intern )
          end
          combo_x
        end

        def _combination_class

          # a simple struct suitable to be used as a record of a form - what
          # you get depends on the state of the category box!

          Exponent_Combination.touch_struct @_category_box.a_
        end
      end  # >>
    end  # close lexeme class again

    module Exponent_Combination

      # we cache one struct for every exponent combination

      define_singleton_method :touch_struct, ( -> do

        cache_h = ::Hash.new do | h, ary |

          sct = ::Struct.new( * ary )

          s = ary.join DOUBLE_UNDERSCORE__
          s[ 0 ] = s[ 0 ].upcase

          Exponent_Combinations.const_set s, sct

          h[ ary ] = sct

          sct
        end

        -> ary do
          cache_h[ ary ]
        end
      end ).call
    end

    module Exponent_Combination::Methods_for_Immutable_Combination

      # enhance the struct we created appropriately

      def form_writer_method_name
        @_form_writer_method_name
      end

      def form_key
        @_form_key
      end

      def freeze

        exp_a = values.select( & IDENTITY_ )

        if exp_a.length.nonzero?

          @_form_key = ( exp_a * DOUBLE_UNDERSCORE__ ).intern # meh
          @_form_writer_method_name = :"#{ @_form_key }="
        end

        super
      end

      def dupe

        # NOTE duping does *not* transfer to the new object this selfsame
        # i.m module and that's exactly what we want! just a simple struct
        dup
      end
    end

    DOUBLE_UNDERSCORE__ = '__'.freeze

    Exponent_Combinations = ::Module.new

    # filled with dynamically produced structs (probably on the order of
    # as many as there are syntactic categories).

    class Formal_Form

      # a form associated with an unbound method,
      # and not any one particular lexeme. created above, used in `forms`

      def initialize combination, unbound_method

        @combination = combination
        @_unbound_method = unbound_method
      end

      attr_reader :combination

      def _bind_to_lexeme lexeme
        Inflection_Implementation.new @combination, @_unbound_method.bind( lexeme )
      end
    end

    class Inflection_Implementation

      # a form bound to a lexeme and its instance method for production

      def initialize combination, implementation_p

        @combination = combination
        @_implementation_p = implementation_p
      end

      attr_reader :combination

      def _produce_any_surface_form

        @_implementation_p.call
      end
    end

    class Lexeme  # re-open 2 of N: lexeme construction

      # To *construct* a lexeme finally, we take optionally a string for
      # the lemma form, and then optionally a hash of irregular forms.
      # the hash relates one exponent combination to one surface form.

      class << self

        def [] lemma_str
          new [ lemma_str ]
        end

        def _new_via * x_a
          new x_a
        end

        private :new
      end  # >>

      define_method :initialize, ( -> do

        _MATCH = [
          -> x { x.respond_to? :ascii_only? },
          -> x { x.respond_to? :each_pair },
          -> x { x.respond_to? :even? },
          -> x { x.respond_to? :call }
        ]

        _OPERATION = [
          -> str { _receive_unsanitized_lemma str },
          -> hash { __add_irregular_forms hash },
          -> fixnum { _accept_lemma fixnum },
          -> p { __accept_lemma_proc p }
        ]

        _POOL_PROTO_H = ::Hash[
          _MATCH.length.times.map { | d | [ d, true ] }
        ]

        -> x_a do

          __init_ivars

          st = Callback_::Polymorphic_Stream.via_array x_a

          if st.unparsed_exists

            pool_h = _POOL_PROTO_H.dup

            begin

              x = st.gets_one

              matched_d = pool_h.keys.detect do | d |
                _MATCH.fetch( d )[ x ]
              end

              if ! matched_d
                raise ::ArgumentError, __say_unable_to_process_as_lex( x )
              end

              pool_h.delete matched_d

              instance_exec x, & _OPERATION.fetch( matched_d )

            end while st.unparsed_exists
          end
        end
      end ).call

      def __say_unable_to_process_as_lex x

        "unable to process for lexeme a #{ x.class }"
      end

      def [] sym

        if self.class._form_box.has_name sym
          send sym
        else
          raise ::NameError, __say_has_no_such_form( sym )
        end
      end

      def __say_has_no_such_form sym

        "no such form '#{ sym }' - has (#{
          self.class._form_box.get_names * ', '
        })"
      end

      def _receive_unsanitized_lemma str

        _accept_lemma str.dup.freeze
        NIL_
      end

      def _accept_lemma x

        if x
          x.frozen? or self._ARGUMENT_ERRROR_trueish_lemma_must_be_frozen_at_this_point
        end

        did = nil
        @_lemma_x ||= begin
          did = true
          x
        end

        did or self._WILL_NOT_CLOBBER_OR_UNWRITE_EXISTING_LEMMA

        @_lemma_is_set = x ? true : false

        NIL_
      end

      def __accept_lemma_proc prc

        @_lemma_proc = prc
        NIL_
      end

      def __add_irregular_forms form_h

        # watch for similarities with `self.as`

        if form_h.length.nonzero?

          @_irregular_box ||= Callback_::Box.new

          form_h.each do | cmb_x, surface_form_x |

            __add_irregular_form cmb_x, surface_form_x
          end
        end
        NIL_
      end

      def __add_irregular_form cmb_x, surface_form_x

        cmb = self.class._build_immutable_combination cmb_x

        _FORM_KEY = cmb.form_key

        h = @_inflected_form_cache

        _surface_form_x_ = if surface_form_x
          surface_form_x.dup.freeze
        else
          surface_form_x
        end

        h[ _FORM_KEY ] = _surface_form_x_  # nil OK

        if ! respond_to? _FORM_KEY

          # (here is hopefully the *only* place we need special code
          # for combinatorial forms)

          define_singleton_method _FORM_KEY do
            @_inflected_form_cache.fetch _FORM_KEY
          end
        end

        @_irregular_box.add(
          _FORM_KEY,
          Inflection_Implementation.new( cmb, method( _FORM_KEY ) )
        )

        NIL_
      end

      # ~ #with-these-lexemes

      class << self

        def new_production_via x  # :+#public-API
          _new_production_via x
        end

        def _new_production_via x

          # note that with this method name a lexeme acts like a
          # formal phrase. `x` is e.g an inflected surface string

          lxc = _any_lexicon

          if lxc && lxc._has_monadic_form( x )

            lex_form = lxc._fetch_monadic_form x

            _lxm = lxc.fetch_monadic_lexeme lex_form.lemma_ID_x

            _production_class.new _lxm.lemma, lex_form.combination

          else

            # we might want to add it to the lexicon!? why / why not (..[#038])

            _production_class.new x, :lemma
          end
        end

        def lexicon  # :+#public-API
          _any_lexicon
        end

        def _any_lexicon

          if _lexicon_lockout

            @_lexicon

          elsif _lexicon_blocks

            _init_lexicon
            @_lexicon
          end
        end

        def _mutable_lexicon

          if ! _lexicon_lockout
            _init_lexicon
          end
          @_lexicon
        end

        def _init_lexicon

          @_lexicon_lockout = true

          lxcn = Lexicon.new self

          a = _lexicon_blocks
          if a
            d = 0  # inside the block may add more blocks!
            while d < a.length
              a.fetch( d ).call lxcn
              a[ d ] = nil  # sanity
              d += 1
            end
            a.clear
          end
          @_lexicon = lxcn
          ACHIEVED_
        end

        attr_reader :_lexicon_blocks

        def edit_lexicon & p  # see #irregular-production-strategies

          if _lexicon_lockout

            # if you already started a lexicon, just process it

            p[ @_lexicon ]

          else  # otherwise memoize the edit (in case not needed)

            ( @_lexicon_blocks ||= [] ).push p
          end
          NIL_
        end

        attr_reader :_lexicon, :_lexicon_lockout

        def _production_class  # see #the-production-class

          if const_defined? :Production, false
            const_get :Production, false
          else
            const_set :Production, __make_production_class
          end
        end

        def __make_production_class

          _LEX_CLS = self

          cat_box = @_category_box

          ::Class.new( Lexeme_Production ).class_exec do

            define_singleton_method :_lexeme_class do
              _LEX_CLS
            end

            define_method :_lexeme_class do
              _LEX_CLS
            end

            cat_box.to_name_stream.each do | cat_sym |

              define_method :"#{ cat_sym }=" do | x |
                mutate_against_exponent_name_and_value cat_sym, x
                x
              end

              define_method cat_sym do
                __lookup_exponent_via_category_symbol cat_sym
              end
            end

            self
          end
        end
      end  # >>

      def lemma
        @_lemma_x
      end
    end

    class Lexicon

      def initialize pos_class

        @_last_lemmaless_id = 0
        @_monadic_form_box = Callback_::Box.new
        @_monadic_lemma_box = Callback_::Box.new
        @_pos_class = pos_class
      end

      # ~ reading

      def _has_monadic_lexeme x
        @_monadic_lemma_box.has_name x
      end

      def _has_monadic_form x
        @_monadic_form_box.has_name x
      end

      def fetch_monadic_lexeme x, & p  # :+#public-API
        @_monadic_lemma_box.fetch x, & p
      end

      def _fetch_monadic_form x, & p
        @_monadic_form_box.fetch x, & p
      end

      # ~ writing

      def << form_h

        # :+#experimental DSL-ish to create a lemma-less lexeme and add into

        lexeme = @_pos_class._new_via( @_last_lemmaless_id += 1, form_h )

        self[ lexeme.lemma ] = lexeme
      end

      # `[]=` Add the lemma to the lexicon NOTE this is DSL-ish and it
      # mutates the lexeme by setting its lemma if it is not yet set!

      def []= lemma_x, lexeme

        if ! lexeme._lemma_is_set
          lexeme._receive_unsanitized_lemma lemma_x  # semi-constructor
        end

        # 1. You want to be able to look up the lemma and get the lemma

        _add_monadic_form lemma_x, lemma_x, :lemma

        # 2. You want to be able to look up the different irregular forms

        bx = lexeme._irregular_box

        if bx

          bx.each_value do | form |

            x = form._produce_any_surface_form   # some forms serve to nullify

            if x
              _add_monadic_form x, lemma_x, form.combination
            end
          end
        end

        # 3. you gotta be able to look up the lexeme itself, we use the lemma

        @_monadic_lemma_box.add lemma_x, lexeme

        lexeme
      end

      def _add_monadic_form surface_form, lemma_ID_x, combination

        @_monadic_form_box.add(
          surface_form,
          Lexicon_Form___.new( surface_form, lemma_ID_x, combination ) )
        NIL_
      end
    end

    Lexicon_Form___ = ::Struct.new :surface_form, :lemma_ID_x, :combination

    class Lexeme  # re-open 3 of N: lexicon-reading

      attr_reader :_irregular_box, :_lemma_is_set

      def __semicollapse cmb  # see #semicollapse, #we-can-optimize

        # (numb=sing case=subj person=nil) -> [[:nubm, :sing],[:case, :subj]]

        and_a = []
        cmb.members.each do | sym |
          x = cmb[ sym ]
          if x
            and_a.push [ sym, x ]
          end
        end

        max_score = 0
        nonzero_pair_a = []

        __to_surface_form_object_stream.each do | sfo |

          score = __score_this sfo.combination, and_a

          if score > max_score
            max_score = score
          end

          if score.nonzero?
            nonzero_pair_a.push [ score, sfo ]
          end
        end

        if max_score.nonzero?

          a = []
          nonzero_pair_a.each do | ( score, sfo ) |

            if max_score == score

              x = sfo._produce_any_surface_form

              if x
                a.push x
              end
            end
          end

          if 1 == a.length
            a.fetch 0
          else
            a * ' or '  # just saying hi. hacked for now
          end
        end
      end

      def __score_this form_comb, and_a

        # if in this form if the grammatical category exponent is falseish
        # then bump it only to one. otherwise if it's set and same as goal
        # then bump score to the ceiling. if this exponent is unequal then
        # short circuit fail.

        and_a.reduce 0 do |score, (category, exponent)|

          x = form_comb[ category ]

          if ! x
            if score.zero?
              score = 1
            end
          elsif exponent == x
            if score < 2
              score = 2
            end
          else
            break 0
          end

          score
        end
      end

      def __to_surface_form_object_stream

        if _irregular_box

          __to_surface_form_object_stream_via_irregulars
        else

          self.class._form_box.to_value_stream.map_by do | ffm |

            ffm._bind_to_lexeme self
          end
        end
      end

      def __to_surface_form_object_stream_via_irregulars

        # some irregulars replace existing regulars, some irregulars introduce
        # new combinations. for no good reason, we will do the latter group
        # first, and then the first group inline with the regulars in the
        # order of the regulars.

        next_p = nil
        p = -> do

          _special_a = @_irregular_box.a_ - self.class._form_box.a_

          st = Callback_::Stream.via_nonsparse_array _special_a do | sym |
            @_irregular_box.fetch sym
          end

          p = -> do
            x = st.gets
            if x
              x
            else
              p = next_p
              p[]
            end
          end
          p[]
        end

        next_p = -> do

          algos = @_irregular_box.algorithms

          st = self.class._form_box.to_value_stream.map_by do | frm |

            algos.if_has_name(

              frm.combination.form_key,

              IDENTITY_,

              -> do
                frm._bind_to_lexeme self
              end )
          end

          p = st.method( :gets )
          p[]
        end

        Callback_.stream do
          p[]
        end
      end
    end

    class Lexeme_Production

      def initialize lemma_ID_x, cmb_x

        @_lemma_ID_x = lemma_ID_x

        if cmb_x.respond_to? :members

          @_combination = cmb_x
          @_combination_is_mutable = false

        else

          @_combination = _lexeme_class._combination_class.new
          @_combination_is_mutable = true
          __mutate_against_exponent cmb_x
        end
      end

      def express_into y
        s = to_string
        if s
          y << s
        end
        y
      end

      def to_string
        _produce_some_lexeme.__semicollapse @_combination
      end

      def _produce_some_lexeme

        # (we used to hold the particular form in a @_form ivar of the
        # particular lexeme, but this architecture fell apart when you
        # got into lexicons. this class satisfies [#hl-061].)

        cls = _lexeme_class
        lxc = cls._any_lexicon
        if lxc

          lxm = lxc.fetch_monadic_lexeme @_lemma_ID_x do end

          if ! lxm

            # :+[#038] for now we cache all lexemes created on-the-fly

            lxm = cls[ @_lemma_ID_x ]

            lxc[ @_lemma_ID_x ] = lxm
          end

          lxm
        else

          @_lexeme ||= cls.new( @_lemma_ID_x )
        end
      end

      def _trickle_down_exponent_ k, v

        cat = _lexeme_class._category_box.fetch( k ) do end

        if cat
          if cat._exponent_array.include? v

            @_combination_is_mutable or _make_combination_mutable

            # (we used to clear the combination, now we just do this EEW):

            if v and :markedness != k
              @_combination[ :markedness ] = nil
            end

            _commit_exponent_change k, v

            ACHIEVED_
          end
        end
      end

      def __mutate_against_exponent x  # `x` is unsanitized

        comb_a = Lexeme._normalize_combination_ID_x x

        pair_a = comb_a.reduce [] do |pr_a, exponent_sym|

          exp = _lexeme_class._exponent_box.fetch exponent_sym do end

          if ! exp
            raise ::KeyError, __say_no_exponent( x )
          end

          pair = _normalize_pending_exponent_change exp.category_sym, exponent_sym
          if pair
            pr_a.push pair
            pr_a
          else
            break nil
          end
        end

        if pair_a
          _clear_combination
          pair_a.each do |k, v|
            _commit_exponent_change k, v
          end
        end
        NIL_
      end

      def mutate_against_exponent_name_and_value k, v  # :+#public-API

        pair_a = _normalize_pending_exponent_change k, v

        if pair_a

          if ! @_combination_is_mutable
            _make_combination_mutable
          end

          _commit_exponent_change( * pair_a )

          ACHIEVED_
        else
          a
        end
      end

      def __lookup_exponent_via_category_symbol cat_sym

        @_combination[ cat_sym ]
      end

      def __say_no_exponent x
        "no exponent \"#{ x }\" for #{ _lexeme_class }"
      end

      def _normalize_pending_exponent_change k, v

        if v

          cat = _lexeme_class._category_box.fetch k do end

          if ! cat
            raise ::KeyError, __say_bad_category( k )
          end

          _has = cat._exponent_array.include? v

          if ! _has
            raise ::KeyError, __say_bad_exponent( v, k )
          end
        end

        [ k, v ]
      end

      def __say_bad_category k

        _sym_a = _lexeme_class._category_box.get_names

        _ = NLP::EN.oxford_comma _sym_a, ' or '

        "unrecognized category '#{ k }' - known categories: #{ _ }"
      end

      def __say_bad_exponent v, k

        "bad exponent for #{ k } - #{ v } (#{ _lexeme_class })"
      end

      def _clear_combination

        if ! @_combination_is_mutable
          _make_combination_mutable
        end

        @_combination.members.each do | sym |
          @_combination[ sym ] =  nil
        end
        NIL_
      end

      def _make_combination_mutable

        if ! ( @_combination.frozen? && ! @_combination_is_mutable )
          self._SANITY
        end
        @_combination = @_combination.dupe
        @_combination_is_mutable = true
        NIL_
      end

      def _commit_exponent_change k, v
        @_combination[ k ] = v
        NIL_
      end
    end

    TO_STRING_METHOD__ = -> do
      y = []
      express_into y
      y * SPACE_
    end

    class Formal_Phrase

      class << self

        def make part, *parts

          add_to_me = @_extent
          me = self

          ::Class.new( self ).class_exec do

            if ::Hash.try_convert parts.last
              _AGREE_ARY = me.__agree_ary_via_options_hash parts.pop
            end

            add_to_me.push self

            parts.unshift part

            _BOX = Callback_::Box.new

            parts.each do | x |
              _BOX.add( x,
                Formal_Phrase_Membership___.new(
                  x, NLP::EN::POS._abbrev_box.fetch( x ) ) )
            end

            _DICT = _BOX.to_struct

            define_singleton_method :__membership_dictionary do
              _DICT
            end

            define_singleton_method :__to_membership_stream do
              _BOX.to_value_stream
            end

            define_singleton_method :__terminal_membership, ( Callback_.memoize do

              x = _DICT.detect do | membership |
                membership.looks_terminal
              end

              if ! x
                raise ::RuntimeError, "no terminal member - #{ self }"
              end

              x
            end )

            define_singleton_method :__agree_a do
              _AGREE_ARY
            end

            _BOX.a_.each do | sym |
              attr_accessor sym
            end

            self
          end  # end class exec
        end

        def __agree_ary_via_options_hash opt_h

          agre_a = nil
          opt_h_h = { agree: -> x { agre_a = x } }
          opt_h.each { |k, v| opt_h_h.fetch( k )[ v ] }
          agre_a
        end

        def __say_not_accepted x, cat_sym

          "no child node accepted this association: #{
            }#{ cat_sym.inspect } => #{ x.inspect }"
        end

        def __define_category_writers

          # once we know what all the syntactic categories are, we can write
          # the writers for them and distribute this module to phrase classes

          const = :Category_Writer_Instance_Methods____

          if const_defined? const, false
            self._SANITY
          end

          me = self
          _mod = ::Module.new.module_exec do

            Grammatical_Category.box_.to_name_stream.each do | cat_sym |

              define_method :"#{ cat_sym }=" do | x |

                _did = _trickle_down_exponent_ cat_sym, x
                if ! _did
                  raise ::KeyError, me.__say_not_accepted( x, cat_sym )
                end
                x
              end
            end
            self
          end

          const_set const, _mod

          @_extent.each do | phrase_class |
            phrase_class.send :include, _mod
          end

          NIL_
        end

        def _new_production_via x  # x is surface form or hash-as-tags
          new x
        end

        private :new
      end  # >>

      @_extent = []

      def initialize x

        go = -> x_, mship do

          _part = mship.phrase_class._new_production_via x_
          instance_variable_set mship.ivar, _part
        end

        if x.respond_to? :each_pair

          dict = self.class.__membership_dictionary

          x.each_pair do | k, v |

            go[ v, dict[ k ] ]
          end
        else

          go[ x, self.class.__terminal_membership ]
        end
      end

      define_method :to_string, TO_STRING_METHOD__

      def express_into y

        _to_existent_constituent_production_stream.each do | prd |
          prd.express_into y
        end
        y
      end

      def _trickle_down_exponent_ cat_sym, exponent_sym

        # result is nil or the winning part (e.g production)

        did = false

        _to_existent_constituent_production_stream.each do | prd |

          did_ = prd._trickle_down_exponent_ cat_sym, exponent_sym

          if did_

            did = true

            a = self.class.__agree_a

            if ! ( a && a.include?( cat_sym ) )
              break  # short circuit IFF you don't do agreement
            end
          end
        end

        did
      end

      def _to_existent_constituent_production_stream

        self.class.__to_membership_stream.map_reduce_by do | msp |

          ivar = msp.ivar

          if instance_variable_defined? ivar  # b.c we keep the ivar space clean

            instance_variable_get ivar  # note if it's falseish it is reduced out
          end
        end
      end

      def _____modify x
        found = parts.detect do |part|
          part.modify_if_accepts x
        end
        if found then true else
          raise "unacceptable - #{ m } for #{ self.class }"
        end
      end

      def ______modify_if_accepts x
        found = parts.detect do |part|
          part.modify_if_accepts x
        end
        if found then true else false end
      end
    end

    class Formal_Phrase_Membership___

      def initialize abbrev, pos_class_ID_x

        @abbrev = abbrev
        @ivar = ICK__.fetch abbrev do :"@#{ abbrev }" end
        @looks_terminal = 1 == abbrev.to_s.length
        @_POS_class_ID_x = pos_class_ID_x
      end

      ICK__ = {
        lemma: :"@_lemma_x"
      }

      attr_reader :abbrev, :ivar

      attr_reader :looks_terminal  # hacked for now

      def phrase_class

        @__cls ||= __lookup_class
      end

      def __lookup_class

        x = @_POS_class_ID_x
        a = ::Array.try_convert x
        a ||= [ x ]
        Autoloader_.const_reduce a, NLP::EN::POS
      end
    end

    # ~ adjunct feature: `bind_to_exponent`

    class Lexeme  # re-open 4 of N: this adjunct feature

      def bind_to_exponent sym
        Binding_of_Lexeme_to_Exponent.new self, sym
      end
    end

    class Binding_of_Lexeme_to_Exponent

      def initialize lexeme, sym
        @_exponent_symbol = sym
        @lexeme = lexeme
      end

      attr_reader :lexeme

      def to_string
        @lexeme[ @_exponent_symbol ]
      end
    end

    # ~ end

    POS_Support__ = self

    UNDERSCORE_ = '_'

    # *within the lexical scope* of the "library" module,
    # we create the subject (of this file) module

    module NLP::EN::POS

      # this is strictly a cordoned-off box module only for parts of speech
      # modules. a parts of speech box module may only contain parts of
      # speech constants, or other parts of speech box modules.

      class << self

        attr_reader :_abbrev_box

        def abbrev h
          @_abbrev_box.merge! h ; nil
        end

        def indefinite_noun
          Indefinite_noun__
        end

        def plural_noun
          Plural_noun__
        end

        def preterite_verb
          Preterite_verb___
        end

        def progressive_verb
          Progressive_verb___
        end

        def third_person
          Third_person___
        end
      end  # >>

      @_abbrev_box = {}

      abbrev v: :Verb, n: :Noun, vp: [ :Verb, :Phrase ], np: [ :Noun, :Phrase ]

      abbrev adjp: [ :Adjective, :Phrase ], nmodp: [ :NounModifier, :Phrase ]

      class Verb < Lexeme

        grammatical_categories(

          markedness: [ :lemma ],  # (just because we need `lemma` as an exponent)

          number: [ :singular, :plural ],

          person: [ :first, :second, :third ],

          tense: [ :present, :preterite, :progressive ]
        )

        #       ~ default production strategies for category exponents ~

        as :lemma do

          # for now `lemma` is a producible form, treated as if an exponent

          @_lemma_x
        end

        as :preterite do
          if ENDS_IN_E_RX__ =~ @_lemma_x
            "#{ $~.pre_match }ed"
          else
            "#{ @_lemma_x }ed"
          end
        end

        as :progressive do
          case @_lemma_x
          when ENDS_IN_E_RX__   ; "#{ $~.pre_match }ing"  # "mate" -> "mating"
          when DOUBLE_T__RX__   ; "#{ @_lemma_x }ting"       # "set" -> "setting"
          else                  ; "#{ @_lemma_x }ing"
          end
        end

        DOUBLE_T__RX__ = /[aeiou]t\z/  # #todo - bring the others up to convention
        ENDS_IN_E_RX__ = /e\z/i

        as :singular_third_present do
          Noun[ @_lemma_x ].plural  # wow
        end

        as :plural_third_present do
          @_lemma_x.dup  # meh
        end

        Phrase = Formal_Phrase.make :v, :np  # ( Verb::Phrase )

        lexicon = _mutable_lexicon

        lexicon[ 'have' ] = _new_via(
          preterite: 'had',
          singular_third_present: 'has' )

        lexicon[ 'be' ] = _new_via(
          preterite: 'was',
          singular_third_present: 'is',
          plural_third_present: 'are' ) # etc

      end

      class Noun < Lexeme

        # (some) Grammatical Categories and their corresponding (some) Exponents,
        # as a directed graph.

        grammatical_categories(

          markedness: [ :lemma ],  # (just becasue we need `lemma` as an exponent)

          case:   [ :subjective, :objective ],

          gender: [ :feminine, :masculine, :neuter ],

          number: [ :singular, :plural ],

          person: [ :first, :second, :third ]

        )

        def indefinite_singular  # hacked for now, not integrated
          "#{ NLP::EN.an @_lemma_x }#{ @_lemma_x }"
        end

        as :singular do
          @_lemma_x.dup
        end

        as :plural do
          case @_lemma_x
          when ENDS_IN_Y__      ; @_lemma_x.sub ENDS_IN_Y__, 'ies'
          when ENDS_IN_ETC__    ; "#{ @_lemma_x }es"
          else                  ; "#{ @_lemma_x }s"
          end
        end

        ENDS_IN_ETC__ = /sh?\z/i  # ick
        ENDS_IN_Y__ = /y\z/i

        edit_lexicon do | lexicn |

          lexicn << {  # (add a lexeme with the below irregulars and no lemma)

            [ :singular ] => nil,  # don't use default singular form

            [ :plural ] => nil,  # don't use default plural form

            [ :first, :singular, :subjective ] => 'I',

            [ :first, :singular, :objective ] => 'me',

            [ :first, :plural, :subjective ] => 'we',

            [ :first, :plural, :objective ] => 'us',

            [ :second ] => 'you',

            [ :third, :singular, :feminine, :subjective ] => 'she',

            [ :third, :singular, :masculine, :subjective ] => 'he',

            [ :third, :singular, :feminine, :objective ] => 'her',

            [ :third, :singular, :masculine, :objective ] => 'him',

            [ :third, :singular, :neuter ] => 'it',

            [ :third, :plural, :subjective ] => 'they',

            [ :third, :plural, :objective ] => 'them'
          }

          nil
        end

        Phrase = Formal_Phrase.make :adjp, :n, :nmodp  # Noun::Phrase

      end

      module Sentence

        # `Sentence::Phrase`

        Phrase = NLP::EN::POS_Models_::Formal_Phrase.make(
          :np, :vp,
          agree: [ :number, :person ] )

      end

      Formal_Phrase.__define_category_writers  # trickle down

      # NOTE the below is not only #experimental it is #exploratory - that is,
      # it is *guaranteed* to change. we just want to see how it feels to type.

      class Verb::Phrase

        # #exploratory - what if turning a single noun into a group were this
        # easy? (but note we define it on the parent of the `np`, which happens
        # to be a `vp` here.)

        def << noun_x
          noun = Noun::Production.new noun_x, :lemma
          noun.number = :plural
          if ! np.is_aggregator
            @_np = Conjunction__::Phrase.new @_np
          end
          @_np << noun
        end  # >>
      end

      class Noun::Phrase
        def is_aggregator
          false
        end
      end

      Conjunction__ = ::Module.new

      class Conjunction__::Phrase  # hack experiment!

        define_method :to_string, TO_STRING_METHOD__

        define_method :express_into, ( -> do

          no_s = 'or'.freeze
          yes_s = 'and'.freeze

          -> y do

            # :+[#036]:one_of_N

            st = Callback_::Polymorphic_Stream.via_array @_a
            if st.unparsed_exists

              st.gets_one.express_into y

              conj_s = @_polarity ? yes_s : no_s

              while st.unparsed_exists
                y << conj_s
                st.gets_one.express_into y
              end
            end
            y
          end
        end ).call

        def is_aggregator
          true
        end

        def << x
          @_a << x  # meh
        end

        def count
          @_a.count
        end

        def each &b
          @_a.each( &b )
        end

        def _a  # top secret
          @_a
        end

        attr_reader :polarity

        -> do  # `polarity=` ( hack )
          h = ::Hash[ [ :positive, :negative ].map { |x| [ x, x ] } ]
          define_method :polarity= do |x|
            @_polarity = h.fetch( x )
          end
        end.call

        def initialize *meh
          @_polarity = :positive
          @_a = meh
        end
      end

      o = POS_Support__

      class o::Indefinite_noun__

        Callback_::Actor.call self, :properties,
          :lemma_string

        def execute
          Noun[ @lemma_string ].indefinite_singular
        end
      end

      class o::Plural_noun__

        Callback_::Actor.call self, :properties,
          :lemma_string,
          :count

        def initialize
          @count = nil
          super
        end

        def execute
          if @count && 1 == @count
            @lemma_string
          else
            Noun[ @lemma_string ].plural
          end
        end
      end

      o::Preterite_verb___ = -> lemma_s do
        Verb[ lemma_s ].preterite
      end

      o::Progressive_verb___ = -> lemma_s do
        Verb[ lemma_s ].progressive
      end

      o::Third_person___ = -> lemma_s do
        Verb[ lemma_s ].singular__third__present
      end
    end  # POS
  end  # "lib"
end
