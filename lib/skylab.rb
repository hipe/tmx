$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT_PATHNAME = ::Pathname.new('../..').expand_path(__FILE__)
  TMPDIR_PATHNAME = ROOT_PATHNAME.join 'tmp'
end


module Skylab
  module Autoloader
    # const_missing hax can suck - use this iff it's compelling. #experimental

    EXTNAME = '.rb'

    def self.extended mod
      mod.extend(Autoloader::ModuleMethods)._autoloader_init! caller[0]
    end
  end


  module Autoloader::Inflection
    extend Methods = ::Module.new # sorry
  end


  module Autoloader::Inflection::Methods

    -> do
      sanitize_path_rx = %r{ #{::Regexp.escape Autoloader::EXTNAME}\z |
        (?<=/)/+ | (?<=[-_ ])[-_ ]+ | [^-_ /a-z0-9]+ }ix

      define_method :constantize do |path|
        path.to_s.gsub(sanitize_path_rx, '').gsub(%r|/+|, '::').
          gsub(/(?<=[-_ ])([A-Z])/){ $1.downcase }.
          gsub(/(?:(?<=\d)|[-_ ]|\b)([a-z09])/) { $1.upcase }
      end
    end.call

    def pathify const
      const.to_s.gsub('::', '/').
        gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) { "-#{$1 || $2}" }.
        gsub('_', '-').downcase
    end
  end


  module Autoloader::ModuleMethods
    include Autoloader::Inflection::Methods # courtesty
    extend Autoloader::Inflection::Methods # pathify

    -> do
      rx = /^(?<path>.+#{ ::Regexp.escape Autoloader::EXTNAME })(?=:\d+:in `)/

      define_method :_autoloader_init! do |caller_str|

        # be sure to #trigger this *ONCE* when hacking autoloader
        class << self # #sl-106: we do *not* hack these methods, but other may
          alias_method :autoloader_original_const_defined?, :const_defined?
          alias_method :autoloader_original_constants, :constants
        end

        if ! dir_path
          file = ::Pathname.new caller_str.match(rx)[:path]
          if ! file.absolute? # this takes a filesystem hit, but you cannot ..
            file = file.expand_path # reliably autoload with a relpath.
          end
          self.dir_path = _guess_dir to_s, file.sub_ext('').to_s do |e|
            fail "Autoloader hack failed: #{e}"
          end
        end
      end
    end.call

    def const_probably_loadable? const
      _const_missing(const).probably_loadable?
    end

    def const_missing const
      _const_missing(const).load
      const_get const, false
    end

    def _const_missing const
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


  class Autoloader::ConstMissing < ::Struct.new(:const, :mod_dir_pathname, :mod)
    include Autoloader # EXTNAME
    include Autoloader::Inflection::Methods # pathify

    def load
      if file_pathname.exist?
        load_file
      else
        raise ::LoadError.new("no such file to load -- #{file_pathname}")
      end
      nil
    end

    def probably_loadable?
      file_pathname.exist?
    end

  protected
    attr_accessor :after_require_f

    def file_pathname
      @file_pathname ||= mod_dir_pathname.join("#{pathify const}#{EXTNAME}")
    end

    -> do
      mutex_h = ::Hash.new { |h, k| h[k] = true ; nil }
      define_method(:mutex) { mutex_h[normalized] }
    end.call

    def load_file
      mutex and fail("circular autoload dependency detected#{
        } in #{file_pathname} with #{const}")
      require normalized
      after_require_f and after_require_f.call
      mod.autoloader_original_const_defined? const, false or
        fail("#{mod}::#{const} was not defined, must be, in #{file_pathname}")
      nil
    end

    def normalized
      @normalized ||= file_pathname.sub_ext('').to_s
    end
  end
end
