module Skylab::Headless

  module NLP::EN::Part_Of_Speech

    # Welcome to the deep, dark underbelly of Skylab hacked natural language
    # production. At its essence this node is about providing some publicly
    # visible classes and methods thereupon that let you make `productions`
    # of `phrases` (or just its contituent `lexemes`).
    #
    # The goal of this is simply to get things like subject-verb
    # agreement on-the-fly for a sentence with as much overhead
    # as humanly possible (just kidding, i think it's actually quite tight).
    #
    # There is a module named `POS` and another one named `Part_Of_Speech`.
    # `POS` is a pure, cordoned-off box module for containing modules that
    # correspond directly to parts of speech (more below). `Part_Of_Speech`,
    # then, is the support module that, well, supports POS modules.
    #
    # Constants ending in an underscore (e.g. `Lexeme_`) should
    # be considered API private an not used directly (probably b.c they
    # are very experimental and/or ad-hoc and/or and liable to change
    # or be removed entirely).

  end

  class NLP::EN::Part_Of_Speech::Lexeme_

    # the wikipedia explanation of `lexeme` is pretty much right on target
    # for our use cases here. (historical note - this class used to be a
    # hacked subclass of ::String!!)

    def self.grammatical_categories h

      @category_box ||= begin
        @exponent_box = MetaHell::Formal::Box::Open.new
        @category_box = MetaHell::Formal::Box::Open.new
      end

      h.each do |cat_sym, exponent_a|
        Category_.there_exists_a_category cat_sym
        cat = Category_.new exponent_a
        @category_box.add cat_sym, cat
        exponent_a.each do |exponent_sym|
          @exponent_box.add exponent_sym, ( Exponent_.new cat_sym )
        end
      end

      nil
    end

    class << self
      attr_reader :exponent_box, :category_box
    end

    # `combination_class` a simple struct suitable to be used as a record
    # of a form -  what you get depends on the state of the category box!

    def self.combination_class
      Exp_Comb_Struct_Factory_[ @category_box._order ]
    end

    Exp_Comb_Struct_Factory_ = ::Hash.new do |h, k|
      omg = k.join( '__' )
      omg[0] = omg[0].upcase
      strct = ::Struct.new( * k )
      Exponent_Combination_.const_set omg, strct
      h[ k ] = strct
    end

    module Exponent_Combination_
    end

    # the production class is produced lazily at time of first request -
    # whatever the state is of the *categories* (not exponents) is at that
    # time will get baked in to the class (and subsequent categories will
    # not make it into the class as setters).

    def self.production_class
      if const_defined? :Production, false
        const_get :Production, false
      else
        lex_cls = self
        cat_box = @category_box
        exp_box = @exponent_box
        kls = ::Class.new( Production_ ).class_exec do
          define_singleton_method :lexeme_class do lex_cls end
          define_method :lexeme_class do lex_cls end
          cat_box.each do |cat_sym, cat|
            define_method "#{ cat_sym }=" do |x|
              @exponent_ref_is_mutable or make_exponent_ref_mutable
              if x.nil? or cat.exponent_a.include? x
                @exponent_ref[ cat_sym ] = x
              else
                raise ::KeyError, "bad exponent for #{ cat_sym } - #{ x }"
              end
            end
            define_method cat_sym do
              @exponent_ref[ cat_sym ]
            end
          end
          self
        end
        const_set :Production, kls
        kls
      end
    end

    # if you are familiar, `as` is a lot like ::Rspec's `let`,
    # the main difference being it memoizes to an ivar named after
    # the property rather than writing to e.g. `@__memoized`.

    def self.as exponent_sym, &block
      @exponent_box.has? exponent_sym or raise ::KeyError, "undeclared #{
        } grammatical category exponent - #{ exponent_sym } for #{ self }"

      ivar = :"@#{ exponent_sym }"
      define_method exponent_sym do
        if instance_variable_defined? ivar
          instance_variable_get ivar
        else
          instance_variable_set ivar, instance_exec(& block )
        end
      end

      define_method "#{ exponent_sym }=" do |x|
        instance_variable_set ivar, x
      end
    end

    Category_ = ::Struct.new :exponent_a  # as it exists in one lexeme

    Category__ = ::Struct.new :extent_x # as it exists in the universe

    class Category_

      def self.there_exists_a_category cat_sym
        @box.if? cat_sym, -> cat do
          cat.extent_x += 1
        end, -> bx, k do
          bx.add k, Category__.new( 1 )
        end
        nil
      end

      @box = MetaHell::Formal::Box::Open.new

      class << self
        attr_reader :box
      end
    end

    Exponent_ = ::Struct.new :category_sym

    # define_singleton_method :as, & NLP::EN::Part_Of_Speech::FUN.as

    def self.produce x
      if has_lexicon and lexicon.has_monadic_form? x
        form = @lexicon.fetch_monadic_form x
        lexeme = @lexicon.fetch_monadic_lexeme form.lemma_ref
        ohai = production_class.new lexeme.lemma, form.exponent_ref
      else
        # we might want to add it to the lexicon!? why / why not (..[#065])
        ohai = production_class.new x, :lemma
      end
      ohai
    end

    def self.has_lexicon
      lexicon_ivar || lexicon_blocks
    end

    class << self
      attr_reader :lexicon
      alias_method :lexicon_ivar, :lexicon
    end

    # `lexicon` - either add to it with a block, or result in it.

    def self.lexicon &blk
      if blk
        if lexicon_ivar  # if you already started a lexicon, just process it
          blk.call @lexicon
        else
          ( @lexicon_blocks ||= [ ] ) << blk  # but if not, cache it
        end
        nil
      elsif lexicon_ivar
        @lexicon
      else
        @lexicon = Lexicon_.new self
        if lexicon_blocks
          i = 0  # (imagine that inside the block, it leads to more blocks..)
          while i < @lexicon_blocks.length
            @lexicon_blocks[ i ].call @lexicon
            i += 1
          end
          @lexicon_blocks.clear  # only after above loop
        end
        @lexicon
      end
    end

    class << self
      attr_reader :lexicon_blocks
    end

    alias_method :as, :send  # assumes that the argument is already validated
      # by the caller (presumably a production).

    def [] form_sym
      if ! self.class.exponent_box.has? form_sym
        raise ::KeyError, "form not found: #{ form_sym.inspect }"
      else
        send form_sym  # we don't access ivars to trip autovivifying blocks..
      end
    end

    def semicollapse exponent_ref
      if ::Symbol === exponent_ref  # is this ok?
        self[ exponent_ref ]
      else
        fail "wat - #{ exponent_ref.class }"
      end
    end

    attr_reader :lemma  # not `lemma_ref` for reasons..

  protected

    def initialize lemma, irregular_h=nil
      ::String === lemma or fail( 'please update your code' ) # #lemma
      @lemma = lemma.dup.freeze
      if irregular_h
        exp = self.class.exponent_box
        irregular_h.each do |k, frm|
          exp.has?( k ) or raise "bad form - #{ k }"
          instance_variable_set "@#{ k }", frm  # ick, meh
        end
      end
    end

    attr_reader :current_form_name

    class Production_  # hides inside Lexeme_ as long as it can..

      def render y
        str = string
        y << str if str  # #todo find a use-case where nil occurs
        nil
      end

      # (we used to hold the particular form in a @form ivar of the particular
      # lexeme, but this architecture fell apart when you got into lexicons.
      # this class satisfies [#061].)

      def string
        resolve_lexeme.semicollapse @exponent_ref
      end

      def resolve_lexeme
        if lexeme_class.has_lexicon
          if lexeme_class.lexicon.has_monadic_lexeme? @lemma_ref
            lexeme_class.lexicon.fetch_monadic_lexeme @lemma_ref
          else
            # i just can't bare the thought of needlessy creating on-the fly
            lex = lexeme_class.new @lemma_ref  # lexemes. they are words man.
            lexeme_class.lexicon[ @lemma_ref ] = lex
            lex
          end
        else
          @lexeme ||= lexeme_class.new( @lemma_ref )
        end
      end
      protected :resolve_lexeme

      attr_reader :lemma_ref, :exponent_ref

      def exponent= x  # strain of [#066]
        if ! lexeme_class.exponent_box.has? x
          raise ::KeyError, "no exponent \"#{ x }\" for #{ lexeme_class }"
        else
          @exponent_ref = x
        end
      end

      def []= cat_sym, exp_sym
        fail "do me"
      end

      def make_exponent_ref_mutable
        if ! ( @exponent_ref.frozen? && ! @exponent_ref_is_mutable )
          fail 'sanity'  # #todo this is for development only
        else
          @exponent_ref = @exponent_ref.dup  # if you get "can't dup Symbol"..
          @exponent_ref_is_mutable = true
        end
        nil
      end

      def trickle_down_exponent cat_sym, exp_sym
        cat = lexeme_class.category_box.fetch( cat_sym ) do end
        if cat
          if cat.exponent_a.include? exp_sym
            fail 'do me here'
            self[ cat_sym ] = exp_sym
            self
          end
        end
      end

    protected

      def initialize lemma_ref, exponent_ref
        @exponent_ref_is_mutable = false
        @lemma_ref, @exponent_ref = lemma_ref, exponent_ref
      end
    end
  end

  class Lexicon_

    def has_monadic_form? x
      @monadic_form_box.has? x
    end

    def fetch_monadic_form x
      @monadic_form_box.fetch x
    end

    def has_monadic_lexeme? x
      @monadic_lemma_box.has? x
    end

    def fetch_monadic_lexeme x
      @monadic_lemma_box.fetch x
    end

    def add_monadic_form frm_str, frm_sym, lemma_str
      @monadic_form_box.add frm_str, Form_.new( frm_str, lemma_str, frm_sym )
      nil
    end

    def []= lemma_str, lexeme
      # lexicon[ 'have' ] = new 'have', preterite: 'had', third_singular: 'has'

      # 1. You want to be able to look up the lemma and get the lemma
      # ( NOTE we hackisly assume lemma is always first! )
      add_monadic_form lemma_str, :lemma, lemma_str

      # 2. You want to be able to look up the different forms.
      lexeme.class.exponent_box._order[ 1 .. -1 ].each do |exponent_sym|
        form_str = lexeme[ exponent_sym ]
        if form_str
          add_monadic_form form_str, exponent_sym, lemma_str
        end
      end

      # 3. from a lemma you want to be able to look up the lexeme
      @monadic_lemma_box.add lemma_str, lexeme
      lexeme
    end

    def << h  # hackisly add a lemma-less lexeme (e.g The Pronoun)
      exp_box = @pos_class.exponent_box ; cat_box = @pos_class.category_box
      lemma_ref = ( @last_lemmaless_id += 1 )
      comb_kls = @pos_class.combination_class
      form_a = [ ]
      h.each do |exp_arr, form_str|
        comb = comb_kls.new
        exp_arr.each do |exp_sym|
          exp = exp_box.fetch exp_sym
          if comb[ exp.category_sym ]
            raise ::KeyError, "#{  exp.category_sym  } can't be both #{
              }#{ comb[ exp.category_sym ] } and #{ first }"
          end
          comb[ exp.category_sym ] = exp_sym
        end
        comb.freeze
        frm = Form_.new( form_str, lemma_ref, comb )
        form_a << frm
        @monadic_form_box.add form_str, frm
      end
      @monadic_lemma_box.add lemma_ref, NLP::EN::Part_Of_Speech::
        Lexeme_::Combinatorial_.new( @pos_class, lemma_ref, form_a )
      nil
    end

    def initialize pos_class
      @pos_class = pos_class
      @monadic_form_box = MetaHell::Formal::Box::Open.new
      @monadic_lemma_box = MetaHell::Formal::Box::Open.new
      @last_lemmaless_id = 0
    end

    Form_ = ::Struct.new :form_str, :lemma_ref, :exponent_ref
  end

  class NLP::EN::Part_Of_Speech::Lexeme_::Combinatorial_

    # `semicollapse` - given the `exponent_ref` (that is a structure-like
    # combination of grammatical category exponents), resolve some kind
    # of string expressing perhaps fuzzily the grammatical category
    # combination (e.g. "her or his")

    def semicollapse exponent_ref
      # ( numbr=sing case=subj person=nil ) -> [[:numbr, :sing], [:case, :subj]]
      and_query_a = exponent_ref.members.reduce [] do |arr, cat|
        v = exponent_ref[ cat ]
        arr << [ cat , v ] if v
        arr
      end
      ohai = @form_a.reduce [] do |arr, frm|
        exp_ref = frm.exponent_ref
        if ! ( and_query_a.detect do |category, exponent|
          # we disqualify this form from the running IFF it *both*
          # has an exponent for that grammatical category *and* that
          # exponent is not the same exponent as that in the query
          exp_ref[ category ] && exp_ref[ category ] != exponent
        end ) then
          arr << frm.form_str
        end
        arr
      end
      case ohai.length
      when 1 ; ohai[ 0 ]
      when 0 ; nil
      else
        ohai * ' or '  # hacked for now, it's just a meh fun p.o.c
      end
    end

    attr_reader :lemma_ref
    alias_method :lemma, :lemma_ref  # think how Verb#lemma works..

    def initialize pos_noun, lemma_ref, form_a
      @pos_noun, @lemma_ref, @form_a = pos_noun, lemma_ref, form_a
    end
  end

  module NLP::EN::POS

    # thi is strictly a parts of speech box module.  a parts of speech
    # box module may only contain parts of speech constants,
    # or other parts of speech box modules.

  end

  class NLP::EN::Part_Of_Speech::Phrase_

    class << self

      alias_method :pos_new, :new  # does the old switcheroo below

      def produce x
        new x  # for now, seems right, yeah?
      end

    end

    @each = [ ]

    def self.new part, *parts
      ea = @each
      ::Class.new( self ).class_exec do
        ea << self
        membership_st =
          parts.unshift(part).reduce MetaHell::Formal::Box::Open.new do |bx, x|
            bx.add x, Membership_.new( x, NLP::EN::POS.abbrev_box.fetch( x ) )
            bx
          end.to_struct

        singleton_class.class_exec do

          alias_method :new, :pos_new

          define_method :box do membership_st end

          -> do  # `members`  / `memberships`

            members = membership_st._order.dup.freeze
            define_method :members do members end

            memberships = membership_st.values.freeze
            define_method :memberships do memberships end
          end.call

          define_method :terminal_membership do
            @terminal_membership ||= begin
              membership_st.detect do |membership|
                membership.looks_terminal
              end or begin
                raise ::RuntimeError, "no terminal member - #{ self }"
              end
            end
          end
        end

        membership_st._order.each do |k|
          attr_accessor k  # for now
        end

        self
      end
    end

    class Membership_  # `Phrase_::Membership_`

      attr_reader :abbrev, :const, :ivar

      attr_reader :looks_terminal  # hacked for now

      def klass
        @klass ||= NLP::EN::POS.const_fetch const
      end

      def initialize abbrev, const
        @abbrev, @const = abbrev, const
        @ivar = :"@#{ abbrev }"
        @looks_terminal = 1 == abbrev.to_s.length
      end
    end

    def render y
      parts.reduce y do |parts, part|
        part.render parts
        parts
      end
      nil
    end

    def string
      y = [ ]
      render y
      y * ' '  # meh for now
    end

    def parts
      ::Enumerator.new do |y|
        self.class.memberships.each do |membership|
          if instance_variable_defined? membership.ivar
            part = instance_variable_get membership.ivar
            if part
              y << part
            end
          end
        end
        nil
      end
    end

    def modify x
      found = parts.detect do |part|
        part.modify_if_accepts x
      end
      if found then true else
        raise "unacceptable - #{ m } for #{ self.class }"
      end
    end

    def modify_if_accepts x
      found = parts.detect do |part|
        part.modify_if_accepts x
      end
      if found then true else false end
    end

    def self.define_category_writers
      if const_defined? :CategoryWriterInstanceMethods, false then
        fail 'sanity'
      else
        const_set :CategoryWriterInstanceMethods, (
        ::Module.new.module_exec do
          NLP::EN::Part_Of_Speech::
                Lexeme_::Category_.box._order.each do |cat_sym|
            define_method "#{ cat_sym }=" do |x|
              res = trickle_down_exponent cat_sym, x
              if ! res
                raise ::KeyError, "no: #{ cat_sym } - #{ x }"
              end
              x
            end
          end
          self
        end )
      end
      @each.each do |phrase_class|
        phrase_class.send :include, CategoryWriterInstanceMethods
      end
      nil
    end

    # result is nil or the winning part (e.g production)
    def trickle_down_exponent cat_sym, exp_sym
      parts.reduce nil do |_, part|
        x = part.trickle_down_exponent cat_sym, exp_sym
        x and break( x )
        nil
      end
    end

  protected

    def initialize h
      if h.respond_to? :each
        h.each do |k, v|
          membership = self.class.box.fetch k
          part = membership.klass.produce v
          instance_variable_set membership.ivar, part
        end
      else
        m = self.class.terminal_membership
        part = m.klass.produce h
        instance_variable_set m.ivar, part
      end
    end
  end

  module NLP::EN::POS

    extend MetaHell::Boxxy

    abbrev( v: :Verb, n: :Noun, vp: [ :Verb, :Phrase ], np: [ :Noun, :Phrase ] )

    abbrev( adjp: [ :Adjective, :Phrase ], nmodp: [ :NounModifier, :Phrase ] )

  end

  class NLP::EN::POS::Verb < NLP::EN::Part_Of_Speech::Lexeme_

    grammatical_categories(

      unmarked: [ :lemma ],

      tense: [ :preterite, :progressive ],  # else "unmarked" (lemma)

      person: [ :third_singular ]   # else "unmarked" (lemma)

    )

    #       ~ default production strategies for category exponents ~

    as :lemma
      # for now, `lemma` is a form you can produce. no block is provided
      # assuming that always the lemma is set as an ivar.

    ends_with_e_rx = /e\z/i  # 2x

    as :preterite do
      if ends_with_e_rx =~ @lemma
        "#{ $~.pre_match }ed"
      else
        "#{ @lemma }ed"
      end
    end

    as :progressive do
      if ends_with_e_rx =~ @lemma
        "#{ $~.pre_match }ing"
      else
        "#{ @lemma }ing"
      end
    end

    as :third_singular do
      "#{ @lemma }s"
    end

    # `Verb::Phrase`

    Phrase = NLP::EN::Part_Of_Speech::Phrase_.new :v, :np

    lexicon[ 'have' ] = new 'have', preterite: 'had', third_singular: 'has'

  end

  class NLP::EN::POS::Noun < NLP::EN::Part_Of_Speech::Lexeme_

    # (some) Grammatical Categories and their corresponding (some) Exponents,
    # as a directed graph.

    grammatical_categories(

      person: [ :first, :second, :third ],

      number: [ :singular, :plural ],

      case:   [ :subjective, :objective ],

      gender: [ :feminine, :masculine, :neuter ]
    )

    as :singular do
      @lemma.dup
    end

    as :plural do
      "#{ @lemma }s"
    end

    lexicon do |lx|

      lx << {

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

    # `Noun::Phrase`

    Phrase = NLP::EN::Part_Of_Speech::Phrase_.new :adjp, :n, :nmodp

  end

  module NLP::EN::POS

    module Sentence

      # `Sentence::Phrase`

      Phrase = NLP::EN::Part_Of_Speech::Phrase_.new :np, :vp

    end
  end

  NLP::EN::Part_Of_Speech::Phrase_.define_category_writers  # trickle down
end
