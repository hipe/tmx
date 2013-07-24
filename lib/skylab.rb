module Skylab                     # Welcome! :D

  # facilities for bootstrapping subsystems - mostly autoloading

  require 'pathname'              # this is the only stdlib loaded at this tier

  here = ::Pathname.new __FILE__  # one of the three centers of the universe

  $:.include?( o = here.join('..').to_s ) or $:.unshift o # add to include path

  dir_pathname = here.sub_ext ''

  define_singleton_method :dir_pathname do
    dir_pathname
  end

  module Autoloader                # const_missing hax can be dodgy - be careful

    EXTNAME = '.rb'.freeze

    Enhance_ = -> mod, callr=nil do
      autoloader = self
      mod.module_exec do
        @tug_class ||= autoloader::Tug
        extend autoloader::Methods
        init_autoloader callr.nil? ? caller[2] : callr
      end
      nil
    end

    define_singleton_method :[], & Enhance_

    FUN = o = ::Struct.new( :pathify, :methodize, :constantize ).new

    o[:pathify] = -> const do
      const.to_s.
        gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) { "-#{$1 || $2}" }.
        gsub('_', '-').downcase
    end

    o[:methodize] = -> str do
      str.to_s.
        gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) { "_#{$1 || $2}" }.
        gsub(/[^a-z0-9]+/i, '_').downcase.intern  # munge-in above underscores
    end

    o[:constantize] = -> do
      sanitize_path_rx = %r{ #{ ::Regexp.escape EXTNAME }\z |
        (?<=/)/+ | (?<=[-_ ])[-_ ]+ | [^-_ /a-z0-9]+ }ix

      -> path do
        path.to_s.gsub( sanitize_path_rx, '' ).  # remove some strings
          split( '/', -1 ).map( & Constantize_sanitized_file_ ) * '::'
        end
    end.call

    Constantize_sanitized_file_ = -> do
      rx = / (?<const>[^-_ ]+) (?<sep>[-_ ]+ (?<is_last>\z) ?)? /x
      -> part do
        part.gsub( rx ).each do  # for each part along with its separator,
          const, sep, is_last = $~.captures
          const.gsub!( /(?<=[0-9]|\A)([a-z])/ ) { $1.upcase } # "99x" -> "99X"
          sep &&= ( is_last || 2 > const.length ) ? '_' : nil
            # "c-style" --> "C_Style", "foo-bar" --> "FooBar", "x-" -> "X_"
          "#{ const }#{ sep }"
        end
      end
    end.call

    o.freeze ; o = nil

    module Methods

      def init_autoloader caller_string
        if dir_pathname.nil?
          pn = ::Pathname.new caller_string.match( CALLFRAME_PATH_RX )[:path ]
          # #todo pn.relative? is expensive and bloaty
          '/' == pn.instance_variable_get( :@path )[ 0 ] or
            pn = pn.expand_path # although this is a filesystme hit,
              # you cannot reliably autoload with a relpath
          guess = Guess_dir_[ name, pn.sub_ext( '' ).to_s, -> e do
            raise ::LoadError, "Autoloader hack failed: #{ e }"
          end ]
          guess and @dir_pathname = ::Pathname.new( guess )  # sanity
        end
        nil
      end

      attr_reader :dir_pathname, :tug_class

      def pathname
        @pathname ||= dir_pathname.sub_ext EXTNAME  # ymmv
      end
    end

    CALLFRAME_PATH_RX = /^(?<path>.+)(?=:\d+:in[ ]`)/x

    Guess_dir_ = -> do

      tok_rx = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}

      pathify = FUN.pathify

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

    module Methods

      def const_probably_loadable? const
        const_tug( const ).probably_loadable?
      end

    private

      def const_missing const
        const_tug( const ).load_and_get  # [#mh-040] result is value
      end

    public

      def const_tug const
        @dir_pathname or raise LoadError, "Autoloader hack failed: attempt #{
          }to autoload #{ name }::#{ const } when dir_path of that anchor #{
          }module not yet known (do you need to extend an Autoloader #{
          }explicitly on that module?)"
        @tug_class.new const.intern, @dir_pathname, self
      end

      #  ~ `add_dir_pathname_listener` - goofy experiment on charging a graph ~

      def add_dir_pathname_listener *a
        ( @dir_pathname_listener_a ||= [ ] ) << a
        nil
      end

      def init_dir_pathname x
        dir_pathname and raise ::ArgumentError, "won't clobber existing pn"
        @dir_pathname = x
        if instance_variable_defined? :@dir_pathname_listener_a
          ( a = @dir_pathname_listener_a ).length.times do |i|
            const, mod = a[ i ]
            mod.init_dir_pathname(
              x.join Autoloader::FUN.pathify[ const ] )
            a[ i ] = nil
          end
          a.compact!
        end
        nil
      end

      # `stowaway` - a hook for another goofy experiment [#mh-030].

    public

      attr_reader :has_stowaways, :stowaway_a

    private

      def stowaway *a
        @has_stowaways ||= true
        ( @stowaway_a ||= [ ] ) << a
      end
    end

    class Tug  # the embodiment of the `const_missing` resolution.

      def initialize const, mod_dir_pathname, mod
        @const, @mod_dir_pathname, @mod = const, mod_dir_pathname, mod
      end

      attr_reader :const, :mod

      def correction_notification const
        @const = const
        nil
      end

      def probably_loadable?
        leaf_pathname.exist?
      end

      def load_and_get correction=nil
        # requiring the same string more than once is never right -
        mutex normalized_path and raise "circular autoload dependency #{
          }detected - probably from within file node #{
          }`#{ leaf_pathname.basename }` an autoload was triggered for the #{
          }selfsame corresponding const node `#{ @const }` - make sure that #{
          }that constant is actually set there - #{ @leaf_pathname }."
        require normalized_path
        correction and correction[]
        if @mod.const_defined? @const, false
          @mod.const_get @const, false
        else
          const_not_defined  # hackery might happen
        end
      end

    private

      define_method :mutex, &
        ::Hash.new { | h, k| h[ k ] = true ; nil }.method( :[] )
      private :mutex

      def normalized_path
        @normalized_path ||= leaf_pathname.sub_ext( '' ).to_s
      end

      -> do
        ext, pathify = Autoloader::EXTNAME, Autoloader::FUN.pathify

        define_method :leaf_pathname do
          @leaf_pathname ||= @mod_dir_pathname.
            join "#{ pathify[@const] }#{ ext }"
        end
      end.call

      def const_not_defined
        raise ::LoadError, "#{ @mod }::#{ @const } was not defined, #{
          }must be, in #{ leaf_pathname }"
      end
    end
  end

  # below this line, "reachdowns" occur..

  module Subsystem

    Autoloader[ self ]

    def self.[] mod
      mod.module_exec do
        ( const_set :MAARS, const_get( :MetaHell, false )::MAARS )[
         self, caller[2] ]
        const_defined? :Services, false or
          stowaway :Services, -> do
            svcs = Subsystem::Services.new @dir_pathname
            const_set :Services, svcs
            load svcs.pathname
            nil
          end
      end
      nil
    end
  end

  module Subsystem
    Autoloader[ self ]
  end

  def self.cache_pathname
    Subsystem::Subsystems_::Headless::System.defaults.cache_pathname
  end
end
