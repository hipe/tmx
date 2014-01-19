module Skylab::MetaHell

  module Boxxy  # :[#019]

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

    def self.enhance mod, * al_i_a, &blk  # autloader intern array
      mod.module_exec do
        @boxxy ||= begin
          boxxy = Boxxy__.new self
          blk and boxxy._absorb_block blk
          boxxy._init_autoloader al_i_a
          boxxy
        end
      end
      nil
    end

    class << self
      alias_method :[], :enhance
    end

    class Boxxy__
      def initialize mod
        @mod = mod
        mod.module_exec do
          class << self
            alias_method :boxxy_original_constants, :constants
          end
          extend MM__
        end
        nil
      end
    end

    module MM__
      def const_fetch path_x, *a, &p
        ( p ? a << p : a ).length.nonzero? and p = a.fetch( a.length - 1 << 1 )
        P__[ nil, false, p, self, path_x ].last
      end
    end

    Resolve_name_and_value = ::Struct.
      new :core_basename, :do_peeking_hack, :else_p, :from_module, :path_x
    class Resolve_name_and_value
      class << self
        remove_method :[]
      end
      def self.[] * x_a
        st = new
        OP_H__.fetch( x_a.shift )[ st, x_a ] while x_a.length.nonzero?
        st[ :from_module ] or fail "from module?"
        P__[ * st.to_a ]
      end
      OP_H__ = -> do
        h = ::Hash[ members.map { |i| [ i, -> st, x_a do
          st[ i ] = x_a.shift
        end ] } ]
        h[ :use_deep_paths_peeking_hack ] = -> st, x_a do
          st[ :do_peeking_hack ] = true
        end
        h.freeze
      end.call
    end

    P__ = -> cbn, do_peek_hack, else_value_p, mod, path_x do  # #curry-friendly
      [ * path_x ].reduce( [ nil, mod ] ) do | (_constant, box), name_x |
        const_a = Get_constants_including_inferred_constants__[ box ]
        nam = Distill[ name_x ]
        guess = const_a.reduce nil do |_, gues|
          nam == Distill[ gues ] and break gues
        end
        if guess
          const = Resolve_name__[ cbn, do_peek_hack, box, guess ]
        end
        if const
          [ const, box.const_get( const, false ) ]
        else
          p = else_value_p || method( :raise )
          v = if p.arity.zero? then p[] else
            p[ NameError.new name_x, box ]
          end
          break [ nil, v ]
        end
      end
    end

    # Fuzzy_const_get is supposed to work on any module:
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
    #     MetaHell::Boxxy::Fuzzy_const_get[ Foo,
    #       [ :'bar-baz', 'bIFFO bLAMMO', :wiz_bang ] ]  # => :wow
    #

    Fuzzy_const_get_name_and_value__ = P__.curry[ nil, nil, nil ]

    Fuzzy_const_get = -> mod, path_x do
      Fuzzy_const_get_name_and_value__[ mod, path_x ].fetch 1
    end

    Get_constants_including_inferred_constants__ = -> mod do
      if mod.respond_to? :boxxy_original_constants
        mod.constants
      else
        a = mod.constants
        a.concat Get_inferred_constants_[ a, mod ]
        a
      end
    end

    Get_inferred_constants_ = -> const_a, mod do
      res_a = -> do
        mod.respond_to? :dir_pathname or break
        dpn = mod.dir_pathname
        dpn && dpn.exist? or break
        seen_h = ::Hash[ const_a.map { |k| [ Distill[ k ], true ] } ]
        guesser = mod.respond_to?( :_boxxy ) ? mod._boxxy.guesser :
          Guessers__::Default
        dpn.children( false ).reduce( [] ) do |memo, file_pn|
          stem = file_pn.sub_ext( '' ).to_s
          key = Distill[ stem ]
          seen_h.fetch key do   # don't dupe 'tree/' and 'tree.rb'
            seen_h[ key ] = true
            const_candidate = guesser[ stem ]
            VALID_CONST_RX__ =~ const_candidate or next memo
            memo << guesser[ stem ]
          end
          memo
        end
      end.call
      res_a || EMPTY_A_
    end

    VALID_CONST_RX__ = /\A[A-Z][A-Za-z0-9_]*\z/

    Distill = -> do  # #part-of-public-FUN-libary
      # different than `Normify` and `normize` this is a lossy operation
      # that produces an internal distillation of a name for use in e.g
      # fuzzy (case-insensitive) matching, while preserving meaningful
      # trailing dashes or underscores from e.g a filename or constant
      # note it is not always suitable as a const name

      black_rx = /[-_ ]+(?=[^-_])/  # preserve final trailing underscores & dashes ; [#bm-002]
      -> x do
        s = x.to_s.gsub black_rx, ''
        d = 0 ; s.setbyte d, UNDR__ while DASH_ == s.getbyte( d -= 1 )
        s.downcase.intern
      end
    end.call
    UNDR__ = '_'.getbyte 0

    Resolve_name__ = -> cbn, do_peek_hack, box, guess do
      if box.const_defined? guess, false
        guess
      elsif box.respond_to? :const_tug
        Resolve_name_with_tug__[ do_peek_hack, box, guess ]
      elsif cbn
        Resolve_name_with_core_file__[ cbn, box, guess ]
      end
    end

    Resolve_name_with_tug__ = -> do_peek_hack, box, guess do
      tug = box.const_missing_class.new guess.intern, box.dir_pathname, box
      correction = if do_peek_hack
        Boxxy::Peeker_::Tug[ tug ]
      else
        Tug_and_get_any_correction_[ tug ]
      end
      correction and guess = correction
      box.const_defined?( guess, false ) and guess
    end

    Resolve_name_with_core_file__ = -> basename, box, guess do  # #edge-hack
      _dir = Autoloader::FUN::Pathify[ guess ]
      pn = box.dir_pathname.join "#{ _dir }/#{ basename }"
      if pn.exist?
        require pn.sub_ext ''
        [ -> { guess }, -> { guess.to_s.gsub( '_', '' ).intern } ].
            reduce nil do |_, p|
          i_ = p[]
          box.const_defined?( i_, false ) and break i_
        end
      end
    end

    Tug_and_get_any_correction_ = -> tug do
      mod = tug.mod ; const = tug.const
      is_boxxified = mod.respond_to? :boxxy_original_constants
      consts = is_boxxified ?
        -> { mod.boxxy_original_constants } : -> { mod.constants }
      befor = consts[ ]
      any_correction = nil
      tug.load_and_get( -> do
        cnst = Distill[ const ]
        ( consts[ ] - befor ).each do |correct_i|
          if cnst == Distill[ correct_i ] && const != correct_i
            any_correction = correct_i
            mod._boxxy.correction_notification const, correct_i if is_boxxified
            tug.correction_notification correct_i
            break
          end
        end
      end )
      any_correction
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
    #     Noodles.const_fetch( :ramen, -> { } ) { } # => IndexError: index 2..
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
      def members
        self.class.members
      end
      def self.members
        %i( const module )
      end
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

    module MM__
      def names
        Boxxy::Names_.class
        names
      end

      def const_fetch_all *a, &b
        a.map do |path_x|
          const_fetch path_x, &b
        end
      end
    end

    # `optimistic constant inference` is something crazy your boxxy module does
    # which is a social contract that stipulates that if you follow [#029]
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

    module MM__
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

    class Conduit__
      def initialize bxy
        @bxy = bxy
      end
    end

    class Boxxy__

      def _absorb_block blk
        Conduit__.new( self ).instance_exec( & blk )
        nil
      end

      def _init_autoloader al_i_a
        @mod.respond_to? :dir_pathname or begin
          if al_i_a.length.zero?
            MetaHell::MAARS::Upwards[ @mod ]
          else
            MetaHell::MAARS[ @mod, * al_i_a ]
          end
        end
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

    module MM__
      def each &blk
        ea = MetaHell::Formal::Box::Enumerator.new( -> pair_y do
          mod_load_guess = Resolve_name__.curry[ nil, false, self ]
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

    module MM__
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

    class Conduit__
      def inferred_name_scheme i
        @bxy.set_inferred_name_scheme i
        nil
      end
    end

    class Boxxy__
      def set_inferred_name_scheme i
        @guesser = Guessers__.const_get i, false
      end

      def guesser
        @guesser ||= Guessers__::Default
      end
    end

    module Guessers__

      Camel_Case_With_Underscore = -> do   # "-ki-ki-" => :_Ki_Ki_
        rx = /(?:\A|([-_]+))(?:([a-z])|\z)/
        -> x do
          x.to_s.gsub rx do
            "#{ $~[ 1 ] and UNDRSCR__ * $~[ 1 ].length }#{
              }#{ $~[ 2 ] and $~[ 2 ].upcase }"
          end.intern
        end
      end.call

      CamelCase = -> do                    # => "-ki-ki-" => :KiKi_
        rx = /(?:(?:-|\A)([a-z]))|(-+)/
        -> x do
          x.to_s.gsub( rx ) do
            "#{ $~[ 1 ] and $~[ 1 ].upcase }#{
              }#{ $~[ 2 ] and UNDRSCR__ * $~[ 2 ].length }"
          end.intern
        end
      end.call

      Default = Camel_Case_With_Underscore

    end

    UNDRSCR__ = '_'.freeze

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
    #     DSL_.get_const( :Zangief )  # => LoadError: uninitialized consta..

    class Boxxy__
      def dsl blk
        Boxxy::DSL_.load
        dsl blk
      end
    end
  end
end
