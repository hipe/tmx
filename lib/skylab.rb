module Skylab                     # Welcome! :D

  #    ~ the sole function of this file is to provide the facilities ~
  #     ~ for opt-in autoloading, facilities that every sub-product ~
  #      ~ in the skylab universe leverages for market synergies & ~
  #       ~ also there's a handful of universal-ish, constant-ish ~
  #        ~ functions that.. well just here have a look:

  require 'pathname'              # the only stdlib subproducts get for free

  here = ::Pathname.new __FILE__  # one of the three centers of the universe

  $:.include?( o = here.join('..').to_s ) or $:.unshift o # add to include path

  dir_pathname = here.sub_ext ''  # chop of extension and ..

  define_singleton_method :dir_pathname do  # expose it to rest of the system.
    dir_pathname
  end

  -> do  # `tmpdir_pathname` - hellof used in testing, but see below
    tmpdir_pathname = nil
    define_singleton_method :tmpdir_pathname do
      tmpdir_pathname ||= dir_pathname.join '../../tmp'
      # #todo why can't you be more like your brother `cache_pathname`?
      # because you need a deep audit and small redesign [#128]
    end
  end.call

  # `cache_pathname` - experimentally for caching things in production -
  # it should only be used with the utmost OCD-fueled hyper-extreme caution
  # and over-engineering you can muster, because nothing puts a turd in
  # your easter basket worse than an epic bughunt caused by a stale cache
  # save for actually doing that.

  -> do
    cache_pathname = nil
    define_singleton_method :cache_pathname do
      cache_pathname ||= begin
        require 'tmpdir'
        pn = ::Pathname.new( ::Dir.tmpdir ).join( 'sl.skylab' )
        if ! pn.exist?
          ::Dir.mkdir pn.to_s, 0766  # same perms as `TemporaryItems`
        end
        pn
      end
    end
  end.call

  module Autoloader
    # const_missing hax can suck - use this iff it's compelling. #experimental

    EXTNAME = '.rb'

    def self.extended mod
      mod.extend Autoloader::Methods
      mod.init_autoloader caller[ 0 ]
    end
  end

  module Autoloader::Inflection

    extend Methods = ::Module.new # sorry  #todo decide the correct interface

    o = { }

    o[:call_frame_path_rx] = /^(?<path>.+)(?=:\d+:in[ ]`)/x

    sanitize_path_rx = %r{ #{::Regexp.escape Autoloader::EXTNAME }\z |
      (?<=/)/+ | (?<=[-_ ])[-_ ]+ | [^-_ /a-z0-9]+ }ix

    o[:constantize] = -> path do
      path.to_s.gsub( sanitize_path_rx, '' ).    # remove some strings
        split( '/', -1 ).map do |const|          # each filename as const name
          const.gsub( /([^-_ ]+)([-_ ]+)?/ ).each do # each part at a separator
            const, sep = $~.captures
            const.gsub!( /(?<=[0-9]|\A)([a-z])/ ) { $1.upcase } # "99x" -> "99X"
            if sep
              if const.length > 1                # "foo_bar" --> "FooBar"
                sep = nil
              else
                sep = '_'                        # "c_style" --> "C_Style"
              end
            end
            "#{ const }#{ sep }"
          end
        end.join '::'
    end

    o[:methodize] = -> str do
      str.to_s.
        gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) { "_#{$1 || $2}" }.
        gsub(/[^a-z0-9]+/i, '_').downcase.intern # munge-in above underscores
    end

    o[:pathify] = -> const do
      const.to_s.gsub('::', '/').
        gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) { "-#{$1 || $2}" }.
        gsub('_', '-').downcase
    end

    Methods.module_exec do  # away at [#127]
      [ :constantize, :methodize, :pathify ].each do |m|
        define_method m, o.fetch( m )
      end
    end

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze
  end

  module Autoloader::Methods  # (né ModuleMethods)

    # (here is how the story starts:)

    #         ~ `init_autoloader` and friends in pre-order-ish ~

    #  a.l methods does not want to give you any methods you do not want.
    #  you get: init_autoloader, dir_pathname, const_missing[_tug]

    guess_dir = nil               # (below)

    -> do  # `init_autoloader`
      rx = Autoloader::Inflection::FUN.call_frame_path_rx

      define_method :init_autoloader do |caller_str|
        if dir_pathname.nil?
          pn = ::Pathname.new caller_str.match( rx )[ :path ]  # gigo
          if '/' != pn.instance_variable_get( :@path )[ 0 ]
            # pn.relative? looks dodgy (look at it!) how many ms #todo
            pn = pn.expand_path   # although this is a filesystme hit,
          end                     # you cannot reliable autoload with a relpath
          guess = guess_dir[ name, pn.sub_ext( '' ).to_s, -> e do
            raise ::LoadError, "Autoloader hack failed: #{ e }"
          end ]
          if guess  # sanity
            @dir_pathname = ::Pathname.new guess
          end
        end
        @tug_class ||= Autoloader::Tug
        nil
      end
    end.call

    attr_reader :dir_pathname     # people like this

    attr_reader :tug_class        # used internally in
                                  # derivative libraries (3x) but dbg too

    guess_dir = -> do

      tok_rx = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}

      pathify = Autoloader::Inflection::FUN.pathify

      tokenizer = -> s do         # "A::B::C" => "c", "b", "a", nil
        -> { m = tok_rx.match( s ) and ( s, x = m.captures ) and pathify[ x ] }
      end

      path_rx =
        %r{\A(?:(?:(?<rest>|.*[^/])/+)?(?<peek>[^/]*)/+)?(?<curr>[^/]*)/*\z}

      -> const, path, error do
        head, *look = path_rx.match( path ).values_at 1..3
        look.compact!
        t = found = nil ; tail = [] ; f = tokenizer[ const ]
        tail.push t while t = f.call and ! found = look.index( t )
        if found
          [ * [head].compact, * look[0..found], * tail.reverse ].join( '/' )
        else
          error[ "failed to infer path for #{ const.inspect } from #{ path }" ]
        end
      end
    end.call

    FUN = ::Struct.new( :guess_dir ).new guess_dir  # exposed for testing

    # -- that is what happens during init.

    #         ~ here is the `const_missing` hack (central thesis) ~

    def const_missing const
      const_tug( const ).load  # offload core implementation
      const_get const, false
    end
    private :const_missing  # #called-by ruby runtime only

    # `const_tug` - a Tug (né ConstMissing then "engine" then
    # "strategy" then "plan" then "policy") is the encapsulation of the core
    # logic for autoloading when a particular const is missing.
    #
    # Offloading it like this to an external instance of an external class
    # a) mitigates our crowding the method and ivar namespace of the particular
    # module object with volatile details of our implementation and
    # b) allows us to customize how we Tug for shenanigans (er, for various
    # autoloading experiments) by employing class inheritance, rather than
    # crowding said ivar, method name (and ancestor chain) inheritance of
    # the client module object.
    #
    # Exposing the construction of the tug like this below with 2 methods
    # is our sole implement-y hook into that precious namespace, to give the
    # particular module (or more likely modules in its own chain) a chance
    # to change how we "tug" when we hit a const missing.

    def const_tug const
      if @dir_pathname
        @tug_class.new const.intern, @dir_pathname, self
      else
        fail "Autoloader hack failed: attempt to autoload #{
          }#{ name }::#{ const } when dir_path of that anchor module not #{
          }yet known (do you need to extend an Autoloader explicitly on that #{
          }module?)" # could be pushed down if really need to
      end
    end

    def const_probably_loadable? const  # courtesy, used elsewhere
      const_tug( const ).probably_loadable?
    end

    def init_dir_pathname x       # goofy experiment on charging a graph
      dir_pathname and raise ::ArgumentError, "won't clobber existing pn"
      @dir_pathname = x
      if dir_pathname_waitlist_a
        @dir_pathname_waitlist_a.length.times do |i|
          const, mod = @dir_pathname_waitlist_a[ i ]
          mod.init_dir_pathname(
            x.join Autoloader::Inflection::FUN.pathify[ const ] )
          @dir_pathname_waitlist_a[ i ] = nil
        end
        @dir_pathname_waitlist_a.compact!
      end
      nil
    end

    attr_reader :dir_pathname_waitlist_a

    def dir_pathname_waitlist *a
      ( @dir_pathname_waitlist_a ||= [ ] ) << a
      nil
    end

    # `stowaway` - a hook for another goofy experiment [#mh-030].

    def stowaway *a
      @has_stowaways ||= true
      ( @stowaway_a ||= [ ] ) << a
    end

    attr_reader :has_stowaways, :stowaway_a
  end

  class Autoloader::Tug

    # (see lengthy justification at `const_tug`)

    def initialize const, mod_dir_pathname, mod
      @const, @mod_dir_pathname, @mod = const, mod_dir_pathname, mod
    end

    def load f=nil                # here is the main entrypoint, usu. why
      if leaf_pathname.exist?     # the tug was created.
        load_file f
      else
        raise ::LoadError, "no such file to load - #{ @leaf_pathname }"
      end
      # (result is result of callee)
    end

    def probably_loadable?
      leaf_pathname.exist?
    end

  private

    #         ~ support for public methods in pre-order ~

    pathify = Autoloader::Inflection::FUN.pathify

    ext = Autoloader::EXTNAME

    define_method :leaf_pathname do
      @leaf_pathname ||= @mod_dir_pathname.join "#{ pathify[@const] }#{ ext }"
    end

    def load_file after=nil
      # if ever you get to a point where you are requiring the same string
      # more than once, certainly something went wrong..
      if mutex
        bn = @leaf_pathname.basename
        fail "circular autoload dependency detected in #{ leaf_pathname } #{
          }while trying to autoload `#{ @const }` there - did you forget #{
          }actually to set `[..]::#{ @const }` in #{ bn }? You know, #{ bn }?#{
          } #{ @const }? #{ bn } <-> #{ @const }? eh? a little of that, eh?"
      else
        # $stderr.puts " >>> AL: #{ normalized_path }" # (2 reasons)
        require normalized_path
        after.call if after
        if @mod.const_defined?( @const, false ) then true else
          const_not_defined  # hackery might happen
        end
      end
    end

    -> do
      mutex_h = ::Hash.new { |h, k| h[k] = true ; nil }
      define_method :mutex do
        mutex_h[ normalized_path ]
      end
    end.call

    def normalized_path
      @normalized_path ||= leaf_pathname.sub_ext( '' ).to_s
    end

    def const_not_defined
      fail "#{@mod}::#{@const} was not defined, must be, in #{leaf_pathname}"
    end
  end
end
