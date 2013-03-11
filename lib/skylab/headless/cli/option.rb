module Skylab::Headless

  class CLI::Option

    #           ~ perfect, pure narrative with pre-order ~

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

    class << self
      alias_method :new_flyweight, :new
      protected :new
    end

  protected

    def initialize
      @long_sexp = nil  # the micro-lith. everything stems from this.
    end

    fun = MetaHell::Formal::Box::Open.new  # eponymous

    # `replace_with_long_rx_matchdata` - a scanner might want to use
    # `long_rx` to see if a string looks like a definition of a long option,
    # and then if it does replace the identity data of the flyweight
    # using the matchdata.

    -> do  # `replace_with_long_rx_matchdata`

      lease_long_sexp_from_matchdata = nil

      define_method :replace_with_long_rx_matchdata do |md|
        @norm_short_str = @norm_long_str = nil
        @long_sexp and release_long_sexp
        @long_sexp = lease_long_sexp_from_matchdata[ md ]
        nil
      end  # (public!)

      # `long_rx` this (or one like it) is one you should use in conjunction
      # with `replace_with_long_rx_matchdata` above.

      long_rx = /\A
        -- (?<no_part> \[no-\] )?
           (?<long_stem> [^\[\]=\s]{2,} )
           (?<long_rest> .+ )?
      \z/x

      #  (below was blind rewrite #todo)
      #  long_rx = /\A
      #    -- (?<no>\[no-\])? (?<stem>[a-z][-a-z0-9]+) (?<arg>.+)?
      # \z/ix

      def release_long_sexp  # assumes @long_sexp has leased Long instance
        Long.release @long_sexp
        @long_sexp = nil
      end

      Long = MetaHell::Formal::Box.const_get(:Struct, false).
        new :__, :no, :stem, :arg

      class << Long
        pool_a = [ ]  # pretend that making a new one is expensive, but NOTE
                      # be _sure_ to re-initialize after you lease!!
        define_method :lease do
          if pool_a.length.nonzero? then pool_a.pop else new( '--' ) end
        end

        define_method :release do |x|
          pool_a << x
          nil
        end
      end

      lease_long_sexp_from_matchdata = -> md do
        if ! md then false else
          ls = Long.lease
          ls[:no], ls[:stem], ls[:arg] = md.captures  # wow
          ls
        end
      end

      define_method :long_sexp do  # (here for proximity.)
        if @long_sexp.nil?
          @long_sexp = if ! @norm_long_str then false else
            lease_long_sexp_from_matchdata[ long_rx.match( @norm_long_str ) ]
          end
        end
        @long_sexp
      end

      fun[:long_rx] = long_rx     # people love it

      nil
    end.call

  public

    # `replace_with_switch` - an option parser scanner might want
    # to simply pass the strange object it for us to reflect from it.

    def replace_with_switch sw
      replace_with_args( ( sw.short.first if sw.short ),
        ( "#{ sw.long.first }#{ sw.arg }" if sw.long && sw.long.first ) )
      nil
    end

    # hi-level, decoupled replacer (flyweight setter).
    # e.g '-x', '--max-count <num>'

    def replace_with_args norm_short_str, norm_long_str
      @long_sexp and release_long_sexp
      @norm_short_str = norm_short_str
      @norm_long_str = norm_long_str
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

    -> do  # `normalized_parameter_name` - comply with `parameter reflection`)

      normize = nil

      define_method :normalized_parameter_name do
        if ! long_sexp then @long_sexp else  # (propagate particular falseishness)
          normize[ @long_sexp.stem ]
        end
      end

      normize = -> x do  # not to be confused with `normify` or `normulate`
        x.gsub( '-', '_' ).downcase.intern
      end

      fun[:normize] = normize  # a client library wants this

    end.call

    def as_parameter_signifier
      if ! long_sexp then false else
        @long_sexp.at( :__, :stem ) * ''  # neato
      end
    end

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

    def as_longest_nonfull_signifier
      if long_sexp
        @long_sexp.at( :__, :stem ).join ''
      else
        @norm_short_str
      end
    end

    def as_shortest_nonfull_signifier
      @norm_short_str
    end

    FUN = -> do

      fun[:short_rx] = /\A
        -  (?<short_stem> [^-\[= ] )
           (?<short_rest> [-\[= ].* )?
      \z/x

      fun[:simple_short_rx] = /\A-[^-]/

      fun.to_struct                 # people just love using `at`

    end.call
  end

  class CLI::Option::Enumerator < ::Enumerator  # here b.c of [#sl-124]

    # an adaptive layer around an optionparser for iterating over its options.
    # Iterate over a collection of option-ishes, be the from a stdlib o.p
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
