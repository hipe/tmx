module Skylab::Headless

  class CLI::Option

    #     ~ (was once a perfect, pure narrative with pre-order) ~

    # (as a fun #experiment this is a blind rewrite of whatever is in
    # tr - in the future we may do a perfect abstraction #todo)
    #
    #   `CLI::Option` provides a high-level, auxiliary, view-model-like
    # reflection service for the options of option parsers.
    #
    # It may help client libraries that want to render help screens
    # or syntax strings and want an abstract (and agnostic) representation
    # of an option.
    #
    # It may also be used for hacks that scan, search, or aggregate data
    # from option parsers for nefarious reasons.
    #
    # It is built from the ground-up for both flyweigting across a collection
    # of options *and* as an immutable-ish representation of a single
    # option; so it can hopefully be used for either without pain.
    #
    # At this time this class is *not* related to the parsing of ARGV,
    # and will probably continue to avoid this scope-creep (::O_P is fine).
    #

    # You must chose one of two ways to construct it, you don't get
    # to use `new` (the constructors here have stemmed out of how we actually
    # use the class):

    class << self
      protected :new
    end

    # 1) allocate one that you will use as a flyweight (whose release you will
    # manage yourself)

    def self.new_flyweight
      allocate.instance_exec do
        @long_sexp = nil  # the micro-lith. everything stems from this.
        @args = nil  # ignore this here, used for compat. with other form
        self
      end
    end

    # 2) construct a non-flyweighty one with `on` (looks like the ::O_P args)

    def self.on *a, &b
      allocate.instance_exec do
        @norm_short_str = @long_sexp = @sexp = nil
        @args = a
        @block = b
        self
      end
    end

    # (about the styles below - for a life-affirming change of pace, we
    # descend from public-ish to private-ish, utilizing the usual functional
    # nonsense, but *not* wrapping each i.m in its own scope, because so
    # many things are shared..)

    # `replace_with_long_rx_matchdata` - a scanner might want to use
    # `long_rx` to see if a string looks like a definition of a long option,
    # and then if it does replace the identity data of the flyweight
    # using the matchdata.
    #
    # WARNING - this form is for a particular form of flyweighting and
    # is ignorant of any `args` / `block` ivars!

    lease_long_sexp_from_matchdata = release_long_sexp = nil
    define_method :replace_with_long_rx_matchdata do |md|
      @norm_short_str = @norm_long_str = nil
      @long_sexp && release_long_sexp[ @long_sexp ]  # LOOK ivar still set!
      @long_sexp = lease_long_sexp_from_matchdata[ md ]
      nil
    end

    # `replace_with_switch` - an option parser scanner might want
    # to simply pass the strange object it for us to reflect from it.
    # WARNING - until necessary this is ignorant of any `args` / `block`

    def replace_with_switch sw
      replace_with_normal_args( ( sw.short.first if sw.short ),
        ( "#{ sw.long.first }#{ sw.arg }" if sw.long && sw.long.first ) )
      nil
    end

    # hi-level, decoupled replacer (flyweight setter).
    # e.g '-x', '--max-count <num>'
    # WARNING - until necessary this is ignorant of `args` / `block`

    define_method :replace_with_normal_args do |norm_short_str, norm_long_str|
      @long_sexp &&= release_long_sexp[ @long_sexp ]
      @norm_short_str = norm_short_str || false
      @norm_long_str = norm_long_str || false
      nil
    end

    #    ~ that ends the story of replacing the identity of the fly. ~

    #    ~ readers (both direct & lazy / derived) & *minimal* rendering ~
    #             (any crazy rendering does not belong here)
    #         (ordered as a complexity pyramid - simplest at top)


    def is_option                 # (comply with `parameter reflection` api)
      true
    end

    def is_argument               # (see `is_option`)
      false
    end

    def args                      # ( not available in all areas )
      @args.dup
    end

    attr_reader :block

    def normal_short_string   # see `_parse_args`
      if @norm_short_str.nil? && @args
        _parse_args
      end
      @norm_short_str
    end

    def normal_long_string    # see `_parse_args`
      if @long_sexp.nil? && @args
         _parse_args
      end
      if ! @long_sexp then @long_sexp else  # we want false not nil
        ( @long_sexp.at :__, :no, :stem, :arg ) * ''
      end
    end

    # `normalized_parameter_name` - comply with `parameter reflection`

    normize = nil
    define_method :normalized_parameter_name do
      if long_sexp
        normize[ @long_sexp.stem ]
      else
        @long_sexp                # ( progpagate particular falseishness )
      end
    end

    # `long_sexp`

    long_rx = nil
    define_method :long_sexp do
      if @long_sexp.nil?
        if @args
          _parse_args
        else
          @long_sexp = if @norm_long_str
            lease_long_sexp_from_matchdata[ long_rx.match( @norm_long_str ) ]
          else
            false
          end
        end
      end
      @long_sexp
    end

    def as_parameter_signifier
      if ! long_sexp then false else
        ( @long_sexp.at :__, :stem ) * ''  # neato
      end
    end

    # `as_shortest_full_parameter_signifier` - usu. for syntax rendering,
    # present the shortest string you can that expresses important features
    # of the element, like whether it takes arguments.

    def as_shortest_full_parameter_signifier
      y = [ ]
      if @norm_short_str
        y << @norm_short_str
        if long_sexp && @long_sexp.arg
          y << @long_sexp.arg
        end
      elsif long_sexp
        # (sure why not, have the entire monty)
        y << @long_sexp.at( :__, :no, :stem, :arg ).join( '' )
      end
      y.length.nonzero? and y.join ''
    end

    # `as_longest_nonfull_signifier` - sometimes when rendering an error
    # message we want to refer to a long, pretty form of the option without
    # presenting features of it like its argument arity or no- form.

    def as_longest_nonfull_signifier
      if long_sexp
        ( @long_sexp.at :__, :stem ) * ''
      else
        @norm_short_str
      end
    end

    def as_shortest_nonfull_signifier
      @norm_short_str
    end

    # `_parse_args` - assume @args. no matter what, set to non-nil
    # both @norm_short_str, @long_sexp. result undefined.
    # for each of the things, the parse results in non-false IFF the parse
    # can resolve exactly one such thing (this is party the meaning of
    # `normal_{ short | long }_switch` - that they can be used in part
    # to identify uniquely the "identity" of the option, for particular
    # definitins of identity).

    simple_short_rx = nil
    define_method :_parse_args do
      sexp = Headless::Services::CodeMolester::Sexp[ :opt ]
      h = { }
      o = -> k, v do
        ( h[ k ] ||= [ ] ) << sexp.length
        sexp << [ k, v ]
      end
      @args.each do |x|
        if x.respond_to? :ascii_only?
          if simple_short_rx =~ x
            o[ :short_full, x ]
          elsif long_rx =~ x
            o[ :long_sexp, lease_long_sexp_from_matchdata[ $~ ] ]
          else
            o[ :desc, x ]
          end
        else
          o[ :other, x ]
        end
      end
      @norm_short_str, @long_sexp = [ :short_full, :long_sexp ].map do |i|
        if h[ i ] && 1 == h.fetch( i ).length
        then sexp.fetch( h.fetch( i ).fetch( 0 ) ).fetch( 1 )
        else false
        end
      end
      @sexp = sexp
      nil
    end
    protected :_parse_args  # hehe the only one here

    def sexp                      # sexperts only HA
      if @sexp.nil?
        _parse_args
      end
      @sexp
    end

    # this is kind of wonktastic how we do this - for this library (this file)
    # we follow our usual functional scopey nonsense. but also we 'export'
    # some nerks for others to use. in those cases we use:

    fun = MetaHell::Formal::Box::Open.new  # eponymous

    # `normize` - not to be confused with `normify` or `normulate`,
    # this complex function is utilized both in this file and by
    # a client library.

    normize = fun[:normize] = -> x do
      x.gsub( '-', '_' ).downcase.intern
    end

    lease_long_sexp_from_matchdata = fun[:lease_long_sexp_from_matchdata] =
        -> md do

      if ! md then false else
        ls = Long.lease
        ls[:no], ls[:stem], ls[:arg] = md.captures  # wow
        ls
      end
    end

    Long = MetaHell::Formal::Box.const_get( :Struct, false ).
        new( :__, :no, :stem, :arg ).class_exec do

      MetaHell::Pool.enhance( self ).with_lease_and_release -> do
        # this is a the constructor called only when a new such object
        # is actually created, not when it is leased from the pool.
        new '--' # (for these objects first member is always and forever this)
      end

      self
    end

    # `release_long_sexp` - the compliment of leasing it

    release_long_sexp = -> x do
      Long.release x
      nil  # important
    end

    # `long_rx` - this (or one like it) is one you should use in conjunction
    # with `replace_with_long_rx_matchdata` above. ( clients like it too )

    long_rx = fun[:long_rx] = /\A
      -- (?<no_part> \[no-\] )?
         (?<long_stem> [^\[\]=\s]{2,} )
         (?<long_rest> .+ )?
    \z/x

    #  (below was blind rewrite #todo)
    #  long_rx = /\A
    #    -- (?<no>\[no-\])? (?<stem>[a-z][-a-z0-9]+) (?<arg>.+)?
    # \z/ix

    # `short_rx` - here for sematic taxonomic proximity, maybe not used here.

    fun[:short_rx] =  /\A

      -  (?<short_stem> [^-\[= ] )
         (?<short_rest> [-\[= ].* )?
    \z/x

    simple_short_rx = fun[:simple_short_rx] = /\A-[^-]/

    FUN = fun.to_struct           # people just love using `at`
  end

  class CLI::Option::Enumerator < ::Enumerator  # here b.c of [#sl-124]

    # an adaptive layer around an optionparser for iterating over its options.
    # Iterate over a collection of option-ishes, be they from a stdlib o.p
    # or somewhere else; given either another iterator of arbitrary objects
    # that might be switches, or an o.p-ish.
    #
    # yields each of the strange switches of the option-parser-ish
    # it gets. The sole argument to the constructor
    # must either respond_to `each` and yield successive switch-ish'es
    # or quack like an ::OptionParser in that it respond to
    # `visit` and work like stdlib o.p does w/ regards to a stack
    # that responds to `each_option`.
    #
    # This is useful because it's far too hacky to do the below thing
    # to a stdlib o.p in more than one place, in the universe.

    attr_writer :filter  # this is a pass-filter, like ::Array#map

  protected

    -> do

      default_criteria = nil

      define_method :initialize do |x|
        super(& method( :visit ) )
        @criteria ||= default_criteria

        inner = if x.respond_to? :each then x else
          ::Enumerator.new do |y|
            x.send :visit, :each_option do |sw|
              y << sw
            end
            nil
          end
        end

        outer = ::Enumerator.new do |y|
          inner.each do |sw|
            if @criteria[ sw ]  # NOTE you run critera against the strange
              y << @filter[ sw ]  # and then pass the strange to the filter
            end
          end
          nil
        end

        @visit ||= -> y { outer.each(& y.method( :yield ) ) }

        @filter ||= -> o { o }  # this is a pass filter (like `map`)!
      end

      short_long = nil

      default_criteria = -> sw do
        ok = ! short_long.detect { |m| ! sw.respond_to? m }
        ok && short_long.detect { |m| x = sw.send( m ) and x.length.nonzero? }
      end
        # our out-of-the-box criteria for what we mean by "switch" is:
        # it is a nerk that responds to *both* `short` and `long`,
        # and one or more of them is a true-ish of nonzero length.
        # ( There exist in our universe hacks that produce o.p's that have
        # switches that don't meet this criteria!, sometimes by accident
        # [#snag-030] )

      short_long = [ :short, :long ].freeze  # ocd

    end.call

    def visit y
      @visit[ y ]
    end
  end
end
