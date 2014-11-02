module Skylab::Headless

  module NLP::EN::Part_Of_Speech

    # Welcome to the deep, dark underbelly of Skylab hacked natural language
    # production. At its essence this node is about providing some publicly
    # visible classes and methods thereupon that let you make `productions`
    # of `phrases` (or just its constituent `lexemes`).
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

    # the wikipedia explanation of `lexeme` is pretty much spot on with
    # our intention here (good job, wikpedia!). (The last word of the
    # first sentence the wikipedia article is the third word of this
    # one, and the only word that occurs three times in this sentence.)
    #
    # familiarity with the following terms from the above source is recommended
    # and will be assumed in comments & code (in fact the whole architecture is
    # based on:) `lexicon`, `lexeme`, `grammatical category`, `exponent`,
    # `form`. more loosely we will dance around with ideas of
    # `syntactic categories` and `phrase structure grammars` but attotw
    # we know less what we are doing there.
    #
    # more specifically, a Lexeme_ subclass will generally represent one
    # syntactic category and one inflection paradigm. we don't expect to
    # make too many of these, possibly just two.
    #
    # (historical note - this class used to be a hacked subclass of ::String!!)
    #
    # We document our journey as a narrative and riveting story.
    # we start from the beginning (one of them, anyway): with your new
    # lexeme class (we won't make that many of them), you define its
    # grammatical categories, at its essence a two dimensional structure:
    # a simple hash with simple array values, each array containing symbols.
    # see you at next storypoint! (storypoints have leading capital letters).

    def self.grammatical_categories h

      @category_box ||= begin
        cls = Headless_::Lib_::Old_box_lib[].open_box
        @form_box = cls.new
        @exponent_box = cls.new
        cls.new  # eew
      end

      h.each do |cat_sym, exponent_a|
        Category_.there_exists_a_category cat_sym
        cat = Category_.new exponent_a
        @category_box.add cat_sym, cat
        exponent_a.each do |exp_sym|
          @exponent_box.add exp_sym, ( Exponent_.new exp_sym, cat_sym )
        end
      end

      nil
    end

    Category_ = ::Struct.new :exponent_a  # as it exists in one lexeme

    class Category_

      def self.there_exists_a_category cat_sym
        @box.if? cat_sym, -> cat do
          cat.extent_x += 1
        end, -> bx, k do
          bx.add k, Category__.new( 1 )
        end
        nil
      end

      @box = Headless_::Lib_::Old_box_lib[].open_box.new

      class << self
        attr_reader :box
      end

      Category__ = ::Struct.new :extent_x  # as it exists in the universe
    end

    Exponent_ = ::Struct.new :exponent_sym, :category_sym

    # Then with the lexeme class we want to define default production
    # strategies (regular forms). we are simply associating a combination
    # of (often 1) exponent (like :preterite) with one hacky rendering
    # strategy (like "add -'ed' to the lemma")
    #
    # (if you are familiar, `as` is a lot like ::Rspec's `let`,
    # the main difference being it memoizes to an ivar named after
    # the property rather than writing to e.g. `@__memoized`.)

    def self.as combination_ref, &block
      c = build_immutable_combination combination_ref
      ivar = c.ivar
      define_method c.form_reader_method_name do
        if instance_variable_defined? ivar
          instance_variable_get ivar  # nil must be ok
        else
          instance_variable_set ivar, instance_exec(& block )
        end
      end
      define_method c.form_writer_method_name do |x|
        instance_variable_set ivar, x
      end
      @form_box.add c.form_key,
        Form_::Unbound_.new( c, instance_method( c.form_reader_method_name ) )
      nil
    end

    def self.build_immutable_combination combination_ref
      c = combination_class.new
      c.extend Exponent_::Combination_::Immutable_InstanceMethods
      combination_a = normalize_combination_ref combination_ref
      combination_a.each do |exponent_sym|
        c[ @exponent_box.fetch( exponent_sym ).category_sym ] = exponent_sym
      end
      c.freeze
    end

    def self.normalize_combination_ref combination_ref
      if ! combination_ref.respond_to? :each
        combination_ref = combination_ref.to_s.split( '_' ).map(& :intern )
      end
      combination_ref
    end

    # `combination_class` a simple struct suitable to be used as a record
    # of a form - what you get depends on the state of the category box!

    def self.combination_class
      Exponent_::Combination_::Struct_Factory_[ @category_box._order ]
    end

    module Exponent_::Combination_
    end

    Exponent_::Combination_::Struct_Factory_ = ::Hash.new do |h, k|
      strct = ::Struct.new( * k )
      omg = k * '__'
      omg[0] = omg[0].upcase
      Exponent_::Combinations_.const_set omg, strct
      h[ k ] = strct
    end

    module Exponent_::Combination_::Immutable_InstanceMethods
      def form_reader_method_name
        @form_key  # trigger warnings (and those below)
      end
      def form_writer_method_name
        @form_writer_method_name
      end
      def form_key
        @form_key
      end
      def ivar
        @ivar
      end
      def freeze
        exponent_a = values.select { |x| x }
        if exponent_a.length.nonzero?
          @form_key = ( exponent_a * '__' ).intern # meh
          @form_writer_method_name = ( "#{ @form_key }=" ).intern
          @ivar = "@#{ @form_key }".intern
        end
        super
      end
      def dupe
        otr = dup  # NOTE it does *not* dupe-over this selfsame i.m module
        otr  # and that's exactly what we want! it's just as simple struct
      end
    end

    module Exponent_::Combinations_
      # filled with dynamically produced structs (probably on the order of
      # as many as there are syntactic categories).
    end

    module Form_
    end

    # `Form_::Unbound_` - a form associated with an unbound method,
    # and not any one particular lexeme. created above, used in `forms`

    class Form_::Unbound_  # #todo
      attr_reader :combination
      attr_reader :unbound_method
      def bind lexeme
        Form_::Bound_.new @combination, @unbound_method.bind( lexeme )
      end
      def initialize combination, unbound_method
        @combination = combination
        @unbound_method = unbound_method
      end
    end

    # `Form_::Bound_` - a form bound to a lexeme and its instance method
    # for producing the form. created above, used in `semicollapse`

    class Form_::Bound_
      attr_reader :combination
      def surface_form
        @bound_method.call
      end
      def initialize combination, bound_method
        @combination = combination
        @bound_method = bound_method
      end
    end

    attr_reader :has_lemma_proc, :lemma_proc

    def bind_to_exponent i
      Bound__.new self, i
    end
    #
    class Bound__
      def initialize lexeme, i
        @lexeme = lexeme ; @exponent_i = i
      end
      attr_reader :lexeme
      attr_accessor :exponent_i
      def string
        @lexeme[ @exponent_i ]
      end
    end

    def [] i
      self.class.form_box.has?( i ) or raise ::NameError, "no such form '#{ i }' - has (#{ self.class.form_box.names * ', ' })"
      send i
    end

  private

    # To *construct* a lexeme finally, we take optionally a string for
    # the lemma form, and then optionally a hash of irregular forms.
    # the hash relates one exponent combination to one surface form.

    -> do

      match_h = {
        string: -> x { x.respond_to? :ascii_only? },
        hash:   -> x { x.respond_to? :each },
        fixnum: -> x { x.respond_to? :even? },
        proc:   -> x { x.respond_to? :call }
      }

      op_h = {
        string: -> str { set_lemma str },
        hash:   -> hash { add_irregular_forms hash },
        fixnum: -> fix { accept_lemma fix },
        proc:   -> prc { accept_lemma_proc prc }
      }

      tick_h = ::Hash[ match_h.keys.map { |k| [ k, true ] } ]

      define_method :initialize do |*x_a|
        h = tick_h.dup
        while x_a.length.nonzero?
          x = x_a.pop
          key = h.keys.detect do |k|
            match_h[k][ x ]
          end
          if key
            h.delete key
            instance_exec x, & op_h.fetch( key )
          else
            raise ::ArgumentError, "unable to process for lexeme a #{ x.class }"
          end
        end
      end
    end.call

    def self.[] lemma_str
      new lemma_str
    end

    def set_lemma str
      accept_lemma str.dup.freeze
      str
    end
    public :set_lemma

    def accept_lemma x
      did = nil
      @lemma ||= ( did = true and x )
      did or raise ::ArgumentError, "won't clobber existing lemma - #{ @lemma }"
      nil
    end

    def accept_lemma_proc prc
      @has_lemma_proc = true
      @lemma_proc = prc
      nil
    end

    def determine_pos_for x
      if has_lemma_proc
        self.class[ x.instance_exec( & @lemma_proc ).to_s ]
      else
        self
      end
    end ; public :determine_pos_for

    # (watch for similarities with `self.as`)
    def add_irregular_forms form_h
      @irregular_box ||= Headless_::Lib_::Old_box_lib[].open_box.new if form_h.any?
      form_h.each do |combination_x, surface_form|
        c = self.class.build_immutable_combination combination_x
        instance_variable_set c.ivar,  # allow nils
          ( surface_form ? surface_form.dup.freeze : surface_form )
        if ! respond_to? c.form_reader_method_name  # (here is hopefully the
          # *only* place we need special code for combinatorial forms)
          ivar = c.ivar
          define_singleton_method c.form_reader_method_name do
            instance_variable_get ivar
          end
        end
        @irregular_box.add c.form_key,
          Form_::Bound_.new( c, method( c.form_reader_method_name ) )
      end
      nil
    end

    class << self  # here, have some readers for above.
      attr_reader :exponent_box, :category_box
      attr_reader :lexicon  # necessary before it's redefined below
      alias_method :lexicon_ivar, :lexicon
      attr_reader :lexicon_blocks  # used below
    end

    # When we make a lexeme with irregular production strategies (which
    # we will need to do for the most common verbs, because the most common
    # verbs are in fact irregular because of some linguistic phenomenon
    # with some name that more broadly exhibits one of natural language's
    # anti-optimalities from a computational perspective. yes i'm arguing
    # that we should all speak Lojban.), when we make such a lexeme we
    # need some place to put it so that it Just Works when we later go
    # to use it, e.g in a sentence. That place is called a...

    def self.lexicon &blk

      # (note that for now too a lexicon is associated with a lexeme class
      # (syntactic category!?) as zero-or-one lexicon *per* *lexeme* *class*
      # so e.g there will be one lexicon with nouns and *another* with e.g
      # verbs. this is for ease of implementation because we take tagged
      # input, and are only doing crude NL production and not (yet) NL
      # processing; but keep in mind we might flip it, reverse it, or
      # aggregate syntactic cateogry lexioncs into a more bigger one.)

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

    class Lexicon_  # hehe Lexeme_::Lexicon_

      def initialize pos_class
        @pos_class = pos_class
        @monadic_form_box = Headless_::Lib_::Old_box_lib[].open_box.new
        @monadic_lemma_box = Headless_::Lib_::Old_box_lib[].open_box.new
        @last_lemmaless_id = 0
      end
      private :initialize

      # `[]=` Add the lemma to the lexicon NOTE this is DSL-ish and it
      # mutates the lexeme by setting its lemma if it is not yet set!

      def []= lemma_x, lexeme
        lexeme.set_lemma lemma_x if ! lexeme.lemma_ivar  # semi-constructor

        # 1. You want to be able to look up the lemma and get the lemma
        add_monadic_form lemma_x, lemma_x, :lemma

        # 2. You want to be able to look up the different irregular forms.
        if lexeme.irregular_box
          lexeme.irregular_box.each do |form|
            x = form.surface_form   # some forms serve to nullify
            if x
              add_monadic_form form.surface_form, lemma_x, form.combination
            end
          end
        end

        # 3. you gotta be able to look up the lexeme itself, we use the lemma
        @monadic_lemma_box.add lemma_x, lexeme

        lexeme
      end

      def add_monadic_form surface_form, lemma_ref, combination
        @monadic_form_box.add surface_form,
          Form_.new( surface_form, lemma_ref, combination )
        nil
      end
      private :add_monadic_form

        # `Lexeme_::Lexicon_::Form_` -
      Form_ = ::Struct.new :surface_form, :lemma_ref, :combination

      # `<<` DSL-ish to create a lemma-less lexeme and add ito
      # NOTE experimental!

      def << form_h
        lexeme = @pos_class.new( @last_lemmaless_id += 1, form_h )
        self[ lexeme.lemma ] = lexeme
      end
    end

  public

    attr_reader :lemma
    alias_method :lemma_ivar, :lemma

    def irregular_form_exponents
      ::Enumerator.new do |y|
        if irregular_box
          @irregular_box._order.each do |exponent_sym|
            y << self.class.exponent_box.fetch( exponent_sym )
          end
        end
        nil
      end
    end

    attr_reader :irregular_box  # public

    def as exponent_sym  # assumes not combinatorial
      if ! self.class.exponent_box.has? exponent_sym
        raise ::KeyError, "form not found: #{ exponent_sym.inspect }"
      else
        send exponent_sym  # we don't access ivars to trip autovivifying blocks.
      end
    end

    # Now that we have some lexemes, with grammatical categories and exponents,
    # and those lexems are stored in a lexicon related to syntactic categories
    # which are themselves lexeme subclasses (whew!), we might want to actually
    # make a "production" of a lexeme. we do that with:

    def self.produce x
      if has_lexicon and lexicon.has_monadic_form? x
        lex_form = @lexicon.fetch_monadic_form x
        lexeme = @lexicon.fetch_monadic_lexeme lex_form.lemma_ref
        p = production_class.new lexeme.lemma, lex_form.combination
      else
        # we might want to add it to the lexicon!? why / why not (..[#065])
        p = production_class.new x, :lemma
      end
      p
    end

    def self.has_lexicon
      lexicon_ivar || lexicon_blocks
    end

    class Lexicon_  # (re-open)

      def has_monadic_form? x
        @monadic_form_box.has? x
      end

      def fetch_monadic_form x
        @monadic_form_box.fetch x
      end
    end

    # (the production class is produced lazily at time of first request -
    # whatever the state is of the *categories* (not exponents) is at that
    # time will get baked in to the class (and subsequent categories will
    # not make it into the class as setters).)

    def self.production_class
      if const_defined? :Production, false
        const_get :Production, false
      else
        lex_cls = self
        cat_box = @category_box
        kls = ::Class.new( Production_ ).class_exec do
          define_singleton_method :lexeme_class do lex_cls end
          define_method :lexeme_class do lex_cls end
          cat_box.each do |cat_sym, cat|
            define_method "#{ cat_sym }=" do |x|
              change_exponent cat_sym, x
              x
            end
            define_method cat_sym do
              get_exponent cat_sym
            end
          end
          self
        end
        const_set :Production, kls
        kls
      end
    end

    Lexeme_ = self  # your children are looking for you

    class Production_  # `Lexeme_::Production_`

      #                         ~ write ~

      def change_exponent k, v
        a = prepare_change_exponent k, v
        if ! a then a else
          @combination_is_mutable or make_combination_mutable
          commit_change_exponent( *a )
          true
        end
      end

      def prepare_change_exponent k, v
        if v and ! lexeme_class.category_box.fetch( k ).
            exponent_a.include?( v ) then raise ::KeyError, "bad #{
          }exponent for #{ k } - #{ v } (#{ lexeme_class })"
        else
          [ k, v ]
        end
      end

      def exponent= x  # strain of [#066]
        comb_a = Lexeme_.normalize_combination_ref x
        pair_a = comb_a.reduce [] do |pr_a, exponent_sym|
          exp = lexeme_class.exponent_box.fetch exponent_sym do end
          if ! exp then raise ::KeyError,
            "no exponent \"#{ x }\" for #{ lexeme_class }"
          else
            pair = prepare_change_exponent exp.category_sym, exponent_sym
            if pair then pr_a << pair else break( nil ) end
            pr_a
          end
        end
        if pair_a then
          clear_combination
          pair_a.each { |k, v| commit_change_exponent k, v }
        end
        x
      end

      def clear_combination
        @combination_is_mutable or make_combination_mutable
        @combination.members.each do |m|
          @combination[m] = nil
        end
        nil
      end
      private :clear_combination

      def commit_change_exponent k, v
        @combination[ k ] = v
        nil
      end
      private :commit_change_exponent

      def trickle_down_exponent k, v
        cat = lexeme_class.category_box.fetch( k ) do end
        if cat
          if cat.exponent_a.include? v
            @combination_is_mutable or make_combination_mutable
            # (we used to clear the combination, now we just do this EEW):
            if v and :markedness != k
              @combination[:markedness] = nil
            end
            commit_change_exponent k, v
            self
          end
        end
      end

      #                         ~ read ~

      def get_exponent category_sym
        @combination[ category_sym ]
      end
      private :get_exponent

      def render y
        str = string
        y << str if str  # #todo find a use-case where nil occurs
        nil
      end

      def string
        resolve_lexeme.semicollapse @combination
      end

    private

      def initialize lemma_ref, combination
        @lemma_ref = lemma_ref
        if combination.respond_to? :members
          @combination = combination
          @combination_is_mutable = false
        else
          @combination = lexeme_class.combination_class.new
          @combination_is_mutable = true
          self.exponent = combination
        end
      end

      # (we used to hold the particular form in a @form ivar of the particular
      # lexeme, but this architecture fell apart when you got into lexicons.
      # this class satisfies [#061].)

      def resolve_lexeme
        if lexeme_class.has_lexicon
          if lexeme_class.lexicon.has_monadic_lexeme? @lemma_ref
            lexeme_class.lexicon.fetch_monadic_lexeme @lemma_ref
          else
            # i just can't bare the thought of needlessy creating on-the fly
            lex = lexeme_class.new @lemma_ref  # lexemes. they are words man.
            lexeme_class.lexicon[ @lemma_ref ] = lex  # they are words. [#065]
            lex
          end
        else
          @lexeme ||= lexeme_class.new( @lemma_ref )
        end
      end

      def make_combination_mutable
        if ! ( @combination.frozen? && ! @combination_is_mutable )
          fail 'sanity'  # #todo this is for development only
        else
          @combination = @combination.dupe  # if you get "can't dup Symbol"..
          @combination_is_mutable = true
        end
        nil
      end
    end

    class Lexicon_

      def has_monadic_lexeme? x
        @monadic_lemma_box.has? x
      end

      def fetch_monadic_lexeme x
        @monadic_lemma_box.fetch x
      end
    end

    # `semicollapse` - this is a goof
    # given the `combination` (that is a structure-like
    # combination of grammatical category exponents), resolve some kind
    # of string expressing perhaps fuzzily the grammatical category / exponent
    # combination (e.g. "her or his") based on the set of regular and
    # any irregular forms or this lexeme. (this nerk happens to be the
    # centerpiece of this whole endeavor. it was the novelty algorithm that
    # became the raison d'etre of this whole nerkiss around you now)

    def semicollapse combination
      and_a = combination.members.reduce [] do |arr, cat|  # basically a crude
        v = combination[ cat ]                 # SELECT statement
        arr << [ cat , v ] if v
        arr
      end  # (numb=sing case=subj person=nil) -> [[:nubm, :sing],[:case, :subj]]
      max = 0
      reslt_a = forms.reduce [] do |res_a, frm|
        form_comb = frm.combination
        score = and_a.reduce 0 do |scor, (category, exponent)| # if
          v = form_comb[ category ]            # in this form if the gram.
          if ! v                               # cat. exponent is falseish
            scor = 1 if scor.zero?             # then bump it only to one
          elsif v == exponent                  # elsif it's set and same as goal
            scor = 2 if scor < 2  # hm..       # then bump score to ceiling
          else                                 # if this exponent is unequal
            break 0                            # then short circuit fail.
          end
          scor
        end
        max = score if score > max
        res_a << [ score, frm ] if score.nonzero?
        res_a
      end
      if max.nonzero?
        result_a = reslt_a.reduce [] do |res_a, (score, frm)|
          if score == max
            x = frm.surface_form
            res_a << x if x  # uh-0h
          end
          res_a
        end
        if 1 == result_a.length then result_a[ 0 ] else
          result_a * ' or ' # hacked for now
        end
      end
    end

    # (we can either optimize this for speed or for memory: because slow
    # language production is a good problem to have, and not one we *do*
    # yet have, *and* because it's nice having readable dumps of the
    # object graph, we opt for the latter, possibly re-creating the bound
    # method for regular forms each time the lexeme is collapsed: meh.)

    def forms
      if irregular_box
        forms_with_irregulars
      else
        ::Enumerator.new do |y|
          self.class.form_box.each do |frm|
            y << frm.bind( self )
          end
        end
      end
    end
    private :forms

    class << self
      attr_reader :form_box
    end

    # #todo both above *and* below can be tightened
    def forms_with_irregulars
      ::Enumerator.new do |y|
        # some irregulars replace existing regulars, some irregulars introduce
        # new combinations. for no good reason, we will do the latter group
        # first, and then the first group inline with the regulars in the
        # order of the regulars.
        special_a = @irregular_box._order - self.class.form_box._order
        special_a.each do |k|
          y << @irregular_box.fetch( k )
        end
        self.class.form_box.each do |frm|
          bound = nil
          @irregular_box.if? frm.combination.form_key, -> frm_bnd do
            bound = frm_bnd
          end, -> bx, k do
            bound = frm.bind( self )
          end
          y << bound
        end
        nil
      end
    end
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
        agree_a = -> do
          ::Hash === parts.last or break
          opt_h = parts.pop
          agre_a = nil
          opt_h_h = { agree: -> x { agre_a = x } }
          opt_h.each { |k, v| opt_h_h.fetch( k )[ v ] }
          agre_a
        end.call
        ea << self
        membership_st =
          parts.unshift(part).reduce Headless_::Lib_::Old_box_lib[].open_box.new do |bx, x|
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

          define_method :agree_a do agree_a end
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
        @klass ||= rslv_some_class
      end
    private
      def rslv_some_class
        const = @const
        const.respond_to?( :each_with_index ) or const = [ const ]
        Autoloader_.const_reduce const, NLP::EN::POS
      end
      def initialize abbrev, const
        @abbrev = abbrev ; @const = const
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
      y * SPACE_  # meh for now, 2x [#068]
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
              if ! res then raise ::KeyError, "no child node accepted - #{
                }#{ cat_sym.inspect } => #{ x.inspect }" end
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
    def trickle_down_exponent cat_sym, exponent_sym
      parts.reduce nil do |res, part|
        x = part.trickle_down_exponent cat_sym, exponent_sym
        if x
          if self.class.agree_a and self.class.agree_a.include? cat_sym
            res ||= true  # bump result up from nil, but stay
          else
            break true  # short circuit iff you don't do agreement
          end
        end
        res
      end
    end

  private

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

    # this is strictly a cordoned-off box module only for parts of speech
    # modules. a parts of speech box module may only contain parts of
    # speech constants, or other parts of speech box modules.

    class << self
      def abbrev h
        @abbrev_box.merge! h ; nil
      end
      attr_reader :abbrev_box

      def indefinite_noun
        NLP::EN::Part_Of_Speech::Indefinite_noun__
      end

      def plural_noun
        NLP::EN::Part_Of_Speech::Plural_noun__
      end

      def preterite_verb
        NLP::EN::Part_Of_Speech::Preterite_verb__
      end

      def progressive_verb
        NLP::EN::Part_Of_Speech::Progreessive_verb__
      end
    end

    @abbrev_box = {}

    abbrev v: :Verb, n: :Noun, vp: [ :Verb, :Phrase ], np: [ :Noun, :Phrase ]

    abbrev adjp: [ :Adjective, :Phrase ], nmodp: [ :NounModifier, :Phrase ]

  end

  class NLP::EN::POS::Verb < NLP::EN::Part_Of_Speech::Lexeme_

    grammatical_categories(

      markedness: [ :lemma ],  # (just because we need `lemma` as an exponent)

      number: [ :singular, :plural ],

      person: [ :first, :second, :third ],

      tense: [ :present, :preterite, :progressive ]

    )

    #       ~ default production strategies for category exponents ~

    as :lemma
    # for now `lemma` is a producible form, treated as any other
    # exponent (might change!). no block is provided here, assuming
    # that always the lemma is set as an ivar.

    ends_with_e_rx = /e\z/i  # 2x

    as :preterite do
      if ends_with_e_rx =~ @lemma
        "#{ $~.pre_match }ed"
      else
        "#{ @lemma }ed"
      end
    end

    as :progressive do
      case @lemma
      when ends_with_e_rx ; "#{ $~.pre_match }ing"  # "mate" -> "mating"
      when TEE_TEE_RX__   ; "#{ @lemma }ting"       # "set" -> "setting"
      else                ; "#{ @lemma }ing"
      end
    end
    #
    TEE_TEE_RX__ = /[aeiou]t\z/  # #todo - bring the others up to convention

    as :singular_third_present do
      "#{ @lemma }s"
    end

    # `Verb::Phrase`

    Phrase = NLP::EN::Part_Of_Speech::Phrase_.new :v, :np

    lexicon[ 'have' ] = new preterite: 'had', singular_third_present: 'has'

  end

  class NLP::EN::POS::Noun < NLP::EN::Part_Of_Speech::Lexeme_

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
      "#{ NLP::EN.an @lemma }#{ @lemma }"
    end

    as :singular do
      @lemma.dup
    end

    as :plural do
      if ENDS_IN_Y__ =~ @lemma
        @lemma.sub ENDS_IN_Y__, 'ies'
      else
        "#{ @lemma }s"
      end
    end
    ENDS_IN_Y__ = /y\z/i

    lexicon do |lexicn|

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

    # `Noun::Phrase`

    Phrase = NLP::EN::Part_Of_Speech::Phrase_.new :adjp, :n, :nmodp

  end

  module NLP::EN::POS

    module Sentence

      # `Sentence::Phrase`

      Phrase = NLP::EN::Part_Of_Speech::Phrase_.new :np, :vp,
        agree: [ :number, :person ]

    end
  end

  NLP::EN::Part_Of_Speech::Phrase_.define_category_writers  # trickle down

  # BEGIN
  # NOTE the below is not only #experimental it is #exploratory - that is,
  # it is *guaranteed* to change. we just want to see how it feels to type.

  class NLP::EN::POS::Verb::Phrase

    # #exploratory - what if turning a single noun into a group were this
    # easy? (but note we define it on the parent of the `np`, which happens
    # to be a `vp` here.)

    def << noun_x
      noun = NLP::EN::POS::Noun::Production.new noun_x, :lemma
      noun.number = :plural
      if ! np.is_aggregator
        @np = NLP::EN::POS::Conjunction_::Phrase_.new @np
      end
      @np << noun
    end
  end

  class NLP::EN::POS::Noun::Phrase
    def is_aggregator
      false
    end
  end

  module NLP::EN::POS::Conjunction_  # (i guess this is what we are here for)
  end

  class NLP::EN::POS::Conjunction_::Phrase_  # hack experiment!

    def string  # 2x [#068] (sort of)
      y = [ ]
      render y
      y * TERM_SEPARATOR_STRING_ if y.length.nonzero?
    end

    -> do  # `render` (le hack)
      yes, no = 'and', 'or'
      define_method :render do |y|
        if @a.length.nonzero?
          @a[0].render y
          conj = @polarity ? yes : no
          @a[ 1 .. -1 ].each do |x|
            y << conj
            x.render y
          end
        end
        nil
      end
    end.call

    def is_aggregator
      true
    end

    def << x
      @a << x  # meh
    end

    def count
      @a.count
    end

    def each &b
      @a.each( &b )
    end

    def _a  # top secret
      @a
    end

    attr_reader :polarity

    -> do  # `polarity=` ( hack )
      h = ::Hash[ [ :positive, :negative ].map { |x| [ x, x ] } ]
      define_method :polarity= do |x|
        @polarity = h.fetch( x )
      end
    end.call

    def initialize *meh
      @polarity = :positive
      @a = meh
    end
  end
  # END

  module NLP::EN

    module Part_Of_Speech

      class Indefinite_noun__

        Callback_::Actor[ self, :properties,
          :lemma ]

        def execute
          POS::Noun[ @lemma ].indefinite_singular
        end
      end

      class Plural_noun__

        Callback_::Actor[ self, :properties,
          :lemma, :count ]

        def initialize
          @count = nil
          super
        end

        def execute
          if @count && 1 == @count
            @lemma
          else
            POS::Noun[ @lemma ].plural
          end
        end
      end

      Preterite_verb__ = -> lemma_i do
        POS::Verb[ lemma_i ].preterite
      end

      Progreessive_verb__ = -> lemma_i do
        POS::Verb[ lemma_i ].progressive
      end
    end
  end
end
