module Skylab::MetaHell

  module Boxxy

    # Boxxy is an #experiment that turns an ordinary module into a "smart"
    # module with enhanced behavior. When we have a module that is used solely
    # to hold other constants (e.g sub-modules or arbitrary other values),
    # we can leverage the module's behavior as an ordered set and augment it
    # with things like inflection awareness, autoloading awareness, filesystem
    # peeking..
    #
    # the boxxy module can reflect on its sub-constants that are not yet
    # loaded but "probably" exist (given `isomorphic file location` [#029]).
    # the boxxy module can resolve a sub-constant given a name with a variety
    # of naming schemes to achieve what amounts to fuzzy matching.
    #
    # the comments in this document provide comprehensive documentation
    # for Boxxys's behavior.

    # your boxxy module gets `const_fetch`. you can get the value of a const:
    #
    # we create a module with a variety of constants assigned under it.
    # we can use `const_fetch` to get the value of a const
    # stored with a simple, conventional name via a lowercase symbol:
    #
    #     module Adapters
    #
    #       MetaHell::Boxxy[ self ]
    #
    #       module Foo
    #       end
    #
    #       module BarBaz
    #       end
    #
    #       BONGO_TONGO = :fiz
    #     end
    #
    #     Adapters.const_fetch( :foo ) # => Adapters::Foo
    #
    # the same effect is achieved
    # by passing it an array of (one) symbol name(s):
    #
    #     Adapters.const_fetch( [ :foo ] ) # => Adapters::Foo
    #
    # get a compound camel-case const via a `normalized`-looking symbol:
    #
    #     Adapters.const_fetch( :bar_baz )  # => Adapters::BarBaz
    #
    # you can use dashes in the name:
    #
    #     Adapters.const_fetch( 'bar-baz' )  # => Adapters::BarBaz
    #
    # or spaces:
    #
    #     Adapters.const_fetch( 'bar baz' )  # => Adapters::BarBaz
    #
    # wow amazing, it still reolves the name even if it is in all caps:
    #
    #     Adapters.const_fetch( :'bongo-tongo' ) # => :fiz
    #

    def self.enhance mod, &blk
      mod.module_exec do
        @boxxy ||= begin
          boxxy = Boxxy_.new self
          blk and boxxy._absorb_block blk
          boxxy._init_autoloader
          boxxy
        end
      end
      nil
    end

    class << self
      alias_method :[], :enhance
    end

    class Boxxy_
      def initialize mod
        @mod = mod
        mod.module_exec do
          class << self
            alias_method :boxxy_original_constants, :constants
          end
          extend ModuleMethods_
        end
        nil
      end
    end

    module ModuleMethods_
      def const_fetch path_x, otherwise=nil, &blk
        if blk
          otherwise and raise ::ArgumentError, "too much proc"
          otherwise = blk
        end
        Fuzzy_const_get_name_and_value_recursive_[
          self, path_x, otherwise ].last
      end
    end

    # `FUN.fuzzy_const_get` is supposed to work on any module:
    # here is one that has three layers of depth, and we use a whacky name:
    #
    #     module Foo
    #       module BarBaz
    #         module Biffo_Blammo
    #           WIZ_BANG = :wow
    #         end
    #       end
    #     end
    #
    #     MetaHell::Boxxy::FUN.fuzzy_const_get[ Foo,
    #       [ :'bar-baz', 'bIFFO bLAMMO', :wiz_bang ] ]  # => :wow
    #

    fun = { }

    distill = fun[:distill] = -> do  # #part-of-public-FUN-libary

      # different than `normify` and `normize`, this is a simple, lossy and
      # fast(er) operation that produces an internal distillation of a name
      # for use in e.g fuzzy (case-insensitive) matching.

      black_rx = /(?:[ _-](?=.))+/  # [#bm-002]
      -> x do
        s = x.to_s.gsub( black_rx, '' )
        DASH_ == s.getbyte( -1 ) and s.setbyte( -1, UNDR_ )
        s.downcase.intern
      end
    end.call

    UNDR_ = '_'.getbyte 0

    get_correction_during_tug = -> tug do
      res = nil ; mod = tug.mod ; const = tug.const
      is_boxxified = mod.respond_to? :boxxy_original_constants
      consts = is_boxxified ?
        -> { mod.boxxy_original_constants } : -> { mod.constants }
      befor = consts[ ]
      tug.load_and_get( -> do
        cnst = distill[ const ]
        ( consts[ ] - befor ).each do |correct_i|
          if cnst == distill[ correct_i ] && const != correct_i
            res = correct_i
            mod._boxxy.correction_notification const, correct_i if is_boxxified
            tug.correction_notification correct_i
            break
          end
        end
      end )
      res
    end

    Load_guess_ = -> box, guess do
      if ! box.const_defined? guess, false and box.respond_to? :const_tug
        c = box.tug_class
        tug = c.new guess.intern, box.dir_pathname, box
        correction = get_correction_during_tug[ tug ]
        correction and guess = correction
      end
      box.const_defined?( guess, false ) and guess
    end

    Get_inferred_constants_ = -> const_a, mod do
      res_a = nil
      -> do
        mod.respond_to? :dir_pathname or break
        dpn = mod.dir_pathname
        dpn && dpn.exist? or break
        seen_h = ::Hash[ const_a.map { |k| [ distill[ k ], true ] } ]
        guesser = mod.respond_to?( :_boxxy ) ? mod._boxxy.guesser :
          Guessers_::Default
        res_a = dpn.children( false ).reduce( [] ) do |memo, file_pn|
          stem = file_pn.sub_ext( '' ).to_s
          key = distill[ stem ]
          seen_h.fetch key do   # don't dupe 'tree/' and 'tree.rb'
            seen_h[ key ] = true
            memo << guesser[ stem ]
          end
          memo
        end
      end.call
      res_a || EMPTY_A_
    end

    get_constants_including_inferred_constants = -> mod do
      if mod.respond_to? :boxxy_original_constants
        mod.constants
      else
        a = mod.constants
        a.concat Get_inferred_constants_[ a, mod ]
        a
      end
    end

    Fuzzy_const_get_name_and_value_recursive_ =  # #part-of-public-FUN-library
      fun[:fuzzy_const_get_name_and_value_recursive] =
                                        -> mod, path_x, value_otherwise=nil do

      [ * path_x ].reduce( [ nil, mod ] ) do | (_constant, box), name_x |
        nam = distill[ name_x ]
        const_a = get_constants_including_inferred_constants[ box ]
        guess = const_a.reduce nil do |_, gues|
          nam == distill[ gues ] and break gues
        end
        guess and const = Load_guess_[ box, guess ]
        if const
          [ const, box.const_get( const, false ) ]
        else
          f = value_otherwise || method( :raise )
          v = if f.arity.zero? then f[] else
            f[ NameError.new name_x, box ]
          end
          [ nil, v ]
        end
      end
    end

    fun[:fuzzy_const_get] = -> mod, path_x do
      Fuzzy_const_get_name_and_value_recursive_[ mod, path_x ].fetch 1
    end

    # `const_fetch` deep names, defaults, errors in a nested moudule:
    #
    # with an arbitrarily deeply nested { module* constants },
    # `const_fetch` with an array of names can fetch one such value:
    #
    #     module Noodles
    #
    #       MetaHell::Boxxy[ self ]
    #
    #       module Ramen
    #         module Shin
    #           NAME = :ramyun
    #         end
    #       end
    #     end
    #
    #     Noodles.const_fetch( [ :ramen, :shin, :name ] ) # => :ramyun
    #
    # `const_fetch` out of the box, when not found will raise a ::NameError:
    #
    #     Noodles.const_fetch( :and_co ) # => NameError: uninitialized con..
    #
    # but since it has `fetch` in the name, it suggests (correctly) that
    # `const_fetch` can honor a default provided in a block:
    #
    #     Noodles.const_fetch( :not_there ) { :derp } # => :derp
    #
    # `const_fetch` can honr a default provided in a proc:
    #
    #     Noodles.const_fetch( :no_wai, -> { :zerp } ) # => :zerp
    #
    # `const_fetch` with both a proc and a block doesn't make sense:
    #
    #     Noodles.const_fetch( :ramen, -> { } ) { } # => ArgumentError: too..
    #
    # a `const_fetch` NameError has fun metadata:
    #
    #     name_error = Noodles.const_fetch( [ :ramen, :maru_chan ] ) { |x| x }
    #     name_error.const # => :maru_chan
    #     name_error.module # => Noodles::Ramen

    class NameError < ::NameError
      def initialize const, modul
        @module = modul
        super "uninitialized constant #{ modul }::( ~ #{ const } )", const
      end

      attr_reader :module
      alias_method :const, :name
    end

    # `names` and `const_fetch_all` are 2 kinds of constituent fetchers:
    # your boxxy module can see the `names` (name functions) of its consts:
    # `names` results in an enumerator of name functions:
    #
    #     module Fazzlebert
    #       MetaHell::Boxxy[ self ]
    #       module WizBang
    #       end
    #       FROB_BOB = :no_see
    #     end
    #
    #     Fazzlebert.names.map( & :as_slug )  # => [ 'wiz-bang', 'frob-bob' ]
    #
    # use caution! the `names` are actually 1 flyweight you might need to dupe
    #
    #     a = Fazzlebert.names.to_a
    #     a.length  # => 2
    #     a.first.object_id # => a.last.object_id
    #     a = Fazzlebert.names.map( & :dupe )
    #     a.length  # => 2
    #     a.first.as_natural  # => 'wiz bang'
    #     a.last.as_natural  # => 'frob bob'
    #
    # `const_fetch_all` fetches at once the values of a tuple that you specify
    #
    #     wb, fb = Fazzlebert.const_fetch_all :wiz_bang, :frob_bob
    #     wb  # => Fazzlebert::WizBang
    #     fb  # => Fazzlebert::FROB_BOB

    module ModuleMethods_
      def names
        Boxxy::Names_.load
        names
      end

      def const_fetch_all *a, &b
        a.map do |path_x|
          const_fetch path_x, &b
        end
      end
    end

    # `optimistic constant inference` is something crazy your boxxy module does
    # which is a social contract that stipulates that if you follow [#mh-029]
    # `isomorphic file locations` then you won't have to load a million files
    # to know that you have these million constants under this module. just
    # know that you won't know until load time what the correct casing is of
    # the constant, and until then, `constants` may contain guesses!
    #
    # here's a fantastic hack that has
    # `constants` demonstrating `optimisitic constant inference` in action:
    #
    #     Flowers = module MetaHell::TestSupport::Boxxy::Fixtures::Flowers
    #       self
    #     end
    #
    #     Flowers.constants.length # => 0
    #
    #     module Flowers
    #       MetaHell::Boxxy[ self ]  # now it gets super-charged..
    #     end
    #
    #     # ( NOTE - the 'flowers/' folder exists, has 'calla-lily.rb' )
    #
    #     Flowers.constants  # => [ :Calla_Lily ]
    #
    #     Flowers.const_fetch( :Calla_Lily ) # => :in_bloom_again
    #
    #     Flowers.constants # => [ :CALLA_LiLy ]
    #

    module ModuleMethods_
      def constants               # ("overwrites" ruby builtin, which should
        @boxxy.get_constants      # be in `boxxy_original_constants`)
      end

      def boxxy &blk
        @boxxy.dsl blk
      end

      def _boxxy  # #api-private
        @boxxy
      end
    end


    class Conduit_
      def initialize bxy
        @bxy = bxy
      end
    end

    class Boxxy_

      def _absorb_block blk
        Conduit_.new( self ).instance_exec( & blk )
        nil
      end

      def _init_autoloader
        @mod.respond_to? :dir_pathname or MetaHell::MAARS::Upwards[ @mod ]
        nil
      end

      def get_constants
        a = @mod.boxxy_original_constants
        if ( @known_constants_count ||= -1 ) < a.length
          @known_constants_count = a.length
          @inferred_a = Get_inferred_constants_[ a, @mod ]
        end
        a.concat @inferred_a
      end

      def correction_notification bad, _good
        idx = @inferred_a.index( bad ) or fail "sanity"
        @known_constants_count += 1
        @inferred_a[ idx ] = nil
        @inferred_a.compact!
        nil
      end
    end

    # `constants` caches the inferences derived form the filesystem once
    # but caches the ruby internal `constants` listing not at all.
    #
    #     Cafes = module MetaHell::TestSupport::Boxxy::Fixtures::Cafes
    #       Espresso_Royale_cafe = :erc
    #       MetaHell::Boxxy[ self ]  # there are 2 in the filesystem, too
    #       Espresso_bar = :eb
    #       self
    #     end
    #
    #     Cafes.constants # => [ :Espresso_Royale_cafe, :Espresso_bar, :Lab_Cafe ]
    #
    #     module Cafes
    #       Elixir_Vitae = :el
    #     end
    #
    #     Cafes.constants # => [ :Espresso_Royale_cafe, :Espresso_bar, :Elixir_Vitae, :Lab_Cafe ]

    # boxxy is not recursive.
    # a boxxy module does NOT make its loaded branch nodes themselves boxxy:
    #
    #     Mammals = module MetaHell::TestSupport::Boxxy::Fixtures::Mammals
    #       MetaHell::Boxxy[ self ]  # (there is a corresponding 'mammals/')
    #       self
    #     end
    #
    #     Mammals::Bats.constants.length # => 0
    #     Mammals::Bats::SomeBat.touch
    #     Mammals::Bats.constants.length # => 1
    #

    # your boxxy module gets `each` which loads all values while correcting
    # like so:
    #
    #     Spiders = module MetaHell::TestSupport::Boxxy::Fixtures::Spiders
    #
    #       MetaHell::Boxxy[ self ]  # (there is a corresponding 'spiders/')
    #
    #       Wolf = :wolf
    #       CAMEL = :camel
    #
    #       self
    #     end
    #
    #     a_i = [ ] ; a_x = [ ]
    #     Spiders.each do |i, x|
    #       a_i << i ; a_x << x
    #     end
    #
    #     a_i # => [ :Wolf, :CAMEL, :TaranTULA ]
    #     a_x # => [ :wolf, :camel, :nope ]
    #

    module ModuleMethods_
      def each &blk
        ea = MetaHell::Formal::Box::Enumerator.new( -> pair_y do
          mod_load_guess = Load_guess_.curry[ self ]
          constants.each do |guess_i|
            const = mod_load_guess[ guess_i ]
            const and pair_y.yield( const, const_get( const, false ) )
          end
        end )
        blk ? ea.each( & blk ) : ea
      end
    end

    # `abbrev` is b.y.o implementation
    # like so:
    #
    #     module Foo
    #       MetaHell::Boxxy[ self ]
    #       abbrev f: :Foo, b: [ :Bar, :Baz]
    #     end
    #
    #     Foo.abbrev_box.fetch( :f )  # => :Foo
    #     Foo.abbrev_box.fetch( :b )  # => [ :Bar, :Baz ]

    module ModuleMethods_
    private
      def abbrev h
        @abbrev_box ||= MetaHell::Formal::Box::Open.new
        h.each do |k, v|
          @abbrev_box.add k, v
        end
        nil  # or `h` but nothing else
      end
    public
      attr_reader :abbrev_box
    end

    # change your inference naming scheme if you really need to, in `enhance`
    # like so:
    #
    #     module Cafes       # (here we rob the same filesystem fixtures
    #       @dir_pathname =  # for this, a different module)
    #         MetaHell::TestSupport::Boxxy::Fixtures::Cafes.dir_pathname
    #       MetaHell::Boxxy.enhance self do
    #         inferred_name_scheme :CamelCase
    #       end
    #     end
    #
    #     Cafes.constants  # => [ :EspressoBar, :LabCafe ]
    #

    class Conduit_
      def inferred_name_scheme i
        @bxy.set_inferred_name_scheme i
        nil
      end
    end

    class Boxxy_
      def set_inferred_name_scheme i
        @guesser = Guessers_.const_get i, false
      end

      def guesser
        @guesser ||= Guessers_::Default
      end
    end

    module Guessers_

      Camel_Case_With_Underscore = -> do   # "-ki-ki-" => :_Ki_Ki_
        rx = /(?:\A|([-_]))(?:([a-z])|\z)/
        -> x do
          x.to_s.gsub( rx ) do
            "#{ '_' if $~[1] }#{ $~[2].upcase if $~[2] }"
          end.intern
        end
      end.call

      CamelCase = -> do                    # => "-ki-ki-" => :KiKi_
        rx = /(?:(?:-|\A)([a-z]))|(-)/
        -> x do
          x.to_s.gsub( rx ) do
            "#{ $~[1].upcase if $~[1] }#{ '_' if $~[2] }"
          end.intern
        end
      end.call

      Default = Camel_Case_With_Underscore

    end

    # `your_module.boxxy.dsl do .. end` - an experimental runtime DSL block
    # `original_constants`:
    #
    #     DSL_ = module Foo
    #       MetaHell::Boxxy[ self ]
    #       ZIP = :zap
    #       r = nil
    #       boxxy { r = self }
    #       r
    #     end
    #
    #     DSL_.original_constants # => [ :ZIP ]
    #
    # `dir_pathname`:
    #
    #     ( !! DSL_.dir_pathname.to_s.match( %r{/foo\z} ) )  # => true
    #
    # `pathify`:
    #
    #     DSL_.pathify( :'FooBar_' )  # => 'foo-bar-'
    #
    # `extname`:
    #
    #     DSL_.extname  # => MetaHell::Autoloader::EXTNAME
    #
    # `upwards`:
    #
    #     DSL_.upwards( module Fiz ; self end )
    #     ( !! Fiz.dir_pathname.to_s.match( /fiz\z/ ) )  # => true
    #
    # `get_const`
    #
    #     DSL_.get_const( :ZIP )  # => :zap
    #
    #     module Zangief ; end
    #     DSL_.get_const( :Zangief )  # => ::LoadError: uninitialized consta..

    class Boxxy_
      def dsl blk
        Boxxy::DSL_.load
        dsl blk
      end
    end

    FUN = ::Struct.new( * fun.keys ).new( * fun.values ).freeze
  end
end
