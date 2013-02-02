module Skylab                     # welcome :D

  require 'pathname'              # the only stdlib subproducts get for free

  here = ::Pathname.new( __FILE__ ).expand_path

  $:.include?( o = here.join('..').to_s ) or $:.unshift o # add to include path

  dir_pathname = here.sub_ext ''  # chop of extension and ..

  define_singleton_method( :dir_pathname ) { dir_pathname } # preferred way

  ROOT_PATHNAME = dir_pathname.join '../..' # #away at [#122]

  TMPDIR_PATHNAME = ROOT_PATHNAME.join 'tmp' # centralized here for testing

end


module Skylab
  module Autoloader
    # const_missing hax can suck - use this iff it's compelling. #experimental

    EXTNAME = '.rb'

    def self.extended mod
      mod.extend( Autoloader::ModuleMethods )._autoloader_init caller[0]
    end
  end


  module Autoloader::Inflection
    extend Methods = ::Module.new # sorry

    o = { }

    sanitize_path_rx = %r{ #{::Regexp.escape Autoloader::EXTNAME}\z |
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

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v }
  end


  module Autoloader::Inflection::Methods

    Autoloader::Inflection::FUN.members.each do |func|
      define_method func, & Autoloader::Inflection::FUN[func]
    end

  end


  module Autoloader::ModuleMethods
    include Autoloader::Inflection::Methods # courtesty
    extend Autoloader::Inflection::Methods # pathify

    -> do
      rx = /^(?<path>.+#{ ::Regexp.escape Autoloader::EXTNAME })(?=:\d+:in `)/

      define_method :_autoloader_init do |caller_str|
        # be sure to #trigger this *ONCE* when hacking autoloader

        if respond_to? :const_defined?         # #sl-106: we do *not* hack these
          class << self                        # methods, but other may
            alias_method :autoloader_original_const_defined?, :const_defined?
            alias_method :autoloader_original_constants, :constants
          end
        end

        if dir_path.nil?
          file = ::Pathname.new caller_str.match(rx)[:path]
          if ! file.absolute? # this takes a filesystem hit, but you cannot ..
            file = file.expand_path # reliably autoload with a relpath.
          end
          self.dir_path = _guess_dir to_s, file.sub_ext('').to_s do |e|
            fail "Autoloader hack failed: #{ e }"
          end
        end

        nil
      end
    end.call

    fun = Autoloader::Inflection::FUN

    methodize = fun.methodize

    define_method :alternative_casing_match do |x|
      scream_case = methodize[ x ].to_s.upcase.intern
      if autoloader_original_const_defined? scream_case, false
        scream_case
      end
    end

    def const_probably_loadable? const
      _const_missing(const).probably_loadable?
    end

    def const_missing const
      _const_missing(const).load
      const_get const, false
    end

    def _const_missing const
      dir_path or fail "Autoloader hack failed: attempt to autoload #{
        }#{ self.name }::#{ const } when dir_path of that anchor module not #{
        }yet known (do you need to extend an Autoloader explicitly on that #{
        }module?)" # could be pushed down if really need to
      _const_missing_class.new const.intern, dir_pathname, self
    end

    def _const_missing_class
      Autoloader::ConstMissing
    end

    attr_reader :dir_path

    def dir_path= str
      @dir_pathname = nil
      @dir_path = str
    end

    def dir_pathname
      @dir_pathname ||= begin
        dir_path or fail "sanity - dir_pathname requested but dir_path is not#{
          } set (on #{ name })"
        ::Pathname.new dir_path
      end
    end

    def dir_pathname= pn
      @dir_path = pn.to_s
      @dir_pathname = pn
    end

    -> do

      tok_rx = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}

      tokenizer_f_f = ->(s) do                 # "A::B::C" -> "C", "B", "A", nil
        -> { m = tok_rx.match(s) and (s, x = m.captures) and pathify(x) }
      end

      path_rx =
        %r{\A(?:(?:(?<rest>|.*[^/])/+)?(?<peek>[^/]*)/+)?(?<curr>[^/]*)/*\z}

      define_method :_guess_dir do |const, path, &error|
        head, *look = path_rx.match(path).values_at 1..3
        look.compact!
        t = found = nil ; tail = [] ; f = tokenizer_f_f[ const ]
        tail.push t while t = f.call and ! found = look.index(t)
        if found
          [ * [head].compact, * look[0..found], * tail.reverse ].join('/')
        else
          error[ "failed to infer path for #{const} from #{path}" ]
        end
      end
    end.call
  end


  class Autoloader::ConstMissing < ::Struct.new :const, :mod_dir_pathname, :mod
    include Autoloader # EXTNAME
    include Autoloader::Inflection::Methods # pathify

    def load f=nil
      if file_pathname.exist?
        load_file f
      else
        raise ::LoadError.new("no such file to load -- #{file_pathname}")
      end
      nil
    end

    def probably_loadable?
      file_pathname.exist?
    end

  protected

    def const_not_defined
      fail "#{ mod }::#{ const } was not defined, must be, in #{ file_pathname}"
    end

    def file_pathname
      @file_pathname ||= mod_dir_pathname.join("#{pathify const}#{EXTNAME}")
    end

    -> do
      mutex_h = ::Hash.new { |h, k| h[k] = true ; nil }
      define_method(:mutex) { mutex_h[normalized] }
    end.call

    def load_file after=nil
      mutex and fail("circular autoload dependency detected#{
        } in #{file_pathname} with #{const}")
      require normalized
      after and after.call
      mod.autoloader_original_const_defined? const, false or const_not_defined
      nil
    end

    def normalized
      @normalized ||= file_pathname.sub_ext('').to_s
    end
  end
end
