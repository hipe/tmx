module Skylab  # Welcome! :D

  # ~ facilities for bootstrapping subsystems - mostly autoloading

  require 'pathname'

  here = ::Pathname.new __FILE__

  $:.include?( _ = here.join('..').to_s ) or $:.unshift _

  dir_pathname = here.sub_ext ''

  define_singleton_method :dir_pathname do dir_pathname end

  module Autoloader

    Enhance_ = -> mod, loc_x=:auto do
      case loc_x
      when :auto ; loc_x = caller_locations( 2, 1 )[ 0 ]
      when :none; loc_x = false end
      autoloader = self
      mod.module_exec do
        @tug_class ||= autoloader::Tug
        extend autoloader::Methods
        loc_x and init_autoloader loc_x
      end ; nil
    end

    define_singleton_method :[], & Enhance_

    EXTNAME = '.rb'.freeze

    module FUN

      module Constantize

        p = -> path_x do
          path_x.to_s.gsub( BLACK_RX__, EMPTY_STRING__ ).
            split( FILE_SEP_, -1 ).
              map( & Sanitized_file ) * CONST_SEP__
        end ; define_singleton_method :to_proc do p end
        define_singleton_method :[], p

        BLACK_RX__ = %r{ #{ ::Regexp.escape EXTNAME }\z |
          (?<=/)/+ | (?<=[-_ ])[-_ ]+ | [^-_ /a-z0-9]+ }ix

        EMPTY_STRING__ = ''.freeze
        CONST_SEP__ = '::'.freeze

        Sanitized_file = -> part_s do
          part_s.gsub( PART_RX__ ).each do
            # for each parts (still being attached to any separator)
            const, sep, is_last = $~.captures
            const.gsub!( LETTER_AFTER_DIGIT_RX__ ) { $1.upcase }  # "99x"->"99X"
            sep and _sep = Resolve_any_term_separator__[ const, sep, is_last ]
            "#{ const }#{ _sep }"
          end
        end
        PART_RX__ = / (?<const>[^-_ ]+) (?<sep>[-_ ]+ (?<is_last>\z) ?)? /x
        LETTER_AFTER_DIGIT_RX__ = /(?<=[0-9]|\A)([a-z])/

        Resolve_any_term_separator__ = -> const, sep, is_last do
          if is_last
            CONST_PART_SEP_ * sep.length  # foo-- => Foo__
          elsif 2 > const.length
            CONST_PART_SEP_  # c-style => C_Style, foo-bar => FooBar, x- => X_
          end
        end
      end

      CONST_PART_SEP_ = '_'.freeze
      FILE_SEP_ = '/'.freeze

      module Methodize
        p = -> str do
          str.to_s.gsub( PART_RX__ ) { "#{ SEP__ }#{ $1 || $2 }" }.
            gsub( BLACK_RX__, SEP__ ).downcase.intern
        end ; define_singleton_method :to_proc do p end
        define_singleton_method :[], p
        PART_RX__ = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/
        SEP__ = '_'.freeze
        BLACK_RX__ = /[^a-z0-9]+/i
      end

      module Pathify
        p = -> const_x do
          const_x.to_s.gsub( PART_RX__ ) { "-#{ $1 || $2 }" }.
            gsub( CONST_PART_SEP_, PART_SEP__ ).downcase
        end ; define_singleton_method :to_proc do p end
        define_singleton_method :[], p
        PART_RX__ = /(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-rt-z])/
        PART_SEP__ = '-'.freeze
      end
    end

    module Methods
      def init_autoloader caller_x  # takes multiform args until [#mh-044]
        dir_pathname.nil? and init_atldr_when_dir_pn_nil caller_x ; nil
      end
      def pathname
        @pathname ||= dir_pathname.sub_ext EXTNAME  # ymmv
      end
      attr_reader :dir_pathname, :tug_class
    private
      def init_atldr_when_dir_pn_nil caller_x
        _path_s = nrmlz_caller_x_for_autoloading caller_x
        guess = Guess_dir_[ name, _path_s, -> e do
          raise ::LoadError, "Autoloader hack failed: #{ e }"
        end ]
        guess and @dir_pathname = ::Pathname.new( guess ) ; nil
      end
      def nrmlz_caller_x_for_autoloading caller_x
        _path = caller_x.respond_to?( :absolute_path ) ?
          caller_x.absolute_path :
          caller_x.match( CALLFRAME_PATH_RX )[ :path ]
        pn = ::Pathname.new _path
        SLASH__ == pn.instance_variable_get( :@path ).getbyte( 0 ) or
          pn = pn.expand_path # although this is a filesystme hit,
            # you cannot reliably autoload with a relpath
        pn.sub_ext( '' ).to_s
      end
      SLASH__ = '/'.getbyte 0  # [#bm-009] (open)
    end

    CALLFRAME_PATH_RX = /^(?<path>.+)(?=:\d+:in[ ]`)/x  # everywhere this is used [#mh-044]

    Guess_dir_ = -> do

      tok_rx = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}

      pathify = FUN::Pathify

      tokenizer = -> s do  # "A::B::C" => "c", "b", "a", nil
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

      def const_missing const
        const_tug( const ).load_and_get  # [#mh-040] result is value
      end

      def const_probably_loadable? const
        const_tug( const ).probably_loadable?
      end

      def const_tug const
        dir_pathname or raise LoadError, say_autoloader_hack_failed( const )
        @tug_class.new const.intern, @dir_pathname, self
      end
    private
      def say_autoloader_hack_failed const
        "Autoloader hack failed: attempt to autoload #{ name }::#{ const } #{
          }when dir_path of that anchor module not yet known (do you need #{
           }to enhance that module explicitly with Autoloader?)"
      end
    public
      def add_dir_pathname_listener *a  # goofy experiment on charging a graph
        ( @dir_pathname_listener_a ||= [ ] ) << a ; nil
      end

      def init_dir_pathname x
        dir_pathname and raise ::ArgumentError, "won't clobber existing pn"
        @dir_pathname = x
        a = dir_pathname_listener_a and Notify_d_pn_listrs__[ x, a ] ; nil
      end

      attr_reader :dir_pathname_listener_a

      Notify_d_pn_listrs__ = -> pn, a do
        a.length.times do |d|
          const_i, mod = a[ d ]
          mod.init_dir_pathname pn.join Autoloader::FUN::Pathify[ const_i ]
          a[ d ] = nil
        end
        a.compact! ; nil
      end

    private
      def stowaway *a  # [#mh-030] another goofy experiment
        @has_stowaways ||= true
        ( @stowaway_a_a ||= [] ) << a ; nil
      end
    public
      attr_reader :has_stowaways, :stowaway_a_a
    end

    class Tug  # the implementation of the `const_missing` hack

      def initialize const, mod_dir_pathname, mod
        @const = const ; @mod = mod ; @mod_dir_pathname = mod_dir_pathname
      end

      attr_reader :const, :mod

      def probably_loadable?
        leaf_pathname.exist?
      end

      def leaf_pathname
        @leaf_pathname ||= bld_leaf_pathname
      end

      -> do
        _EXTNAME = Autoloader::EXTNAME
        pathify_p = Autoloader::FUN::Pathify
        define_method :bld_leaf_pathname do
          @mod_dir_pathname.join "#{ pathify_p[ @const ] }#{ _EXTNAME  }"
        end
      end.call

      def load_and_get any_correction_p=nil
        # requiring the same string more than once is never right -
        mutex normalized_path and raise say_circular
        require @normalized_path
        any_correction_p and any_correction_p[]
        if @mod.const_defined? @const, false
          @mod.const_get @const, false
        else
          const_not_defined  # hackery might happen
        end
      end
    private
      def normalized_path
        @normalized_path ||= leaf_pathname.sub_ext( '' ).to_s
      end

      define_method :mutex, &
        ::Hash.new { | h, k| h[ k ] = true ; nil }.method( :[] )

      def say_circular
        "circular autoload dependency detected - probably from within file #{
          }node `#{ leaf_pathname.basename }` an autoload was triggered for #{
           }the selfsame corresponding const node `#{ @const }` - make sure #{
            }that that constant is actually set there - #{ @leaf_pathname }."
      end

      def const_not_defined
        raise ::LoadError, say_const_not_defined
      end

      def say_const_not_defined
        "#{ @mod }::#{ @const } was not defined, #{
          }must be, in #{ leaf_pathname }"
      end
   public
      def correction_notification const
        @const = const ; nil
      end
    end
  end

  def self.cache_pathname
    Subsystem::Subsystems_::Headless::System.defaults.cache_pathname
  end

  module Subsystem

    Autoloader[ self ]

    def self.[] subsystem_mod
      loc = caller_locations( 1, 1 )[ 0 ]
      subsystem_mod.module_exec loc, & Enhance_subsystem_module__ ; nil
    end

    Enhance_subsystem_module__ = -> loc do
      _mh = const_get :MetaHell, false
      const_set( :MAARS, _mh::MAARS )[ self, loc ]
      const_defined? :Library_, false or module_exec( & Make_lib_stowaway__ )
      nil
    end

    Make_lib_stowaway__ = -> do
      stowaway :Library_, -> do
        lib_mod = Subsystem::Library.new @dir_pathname
        const_set :Library_, lib_mod
        load lib_mod.pathname.to_path ; nil
      end
    end
  end
end
