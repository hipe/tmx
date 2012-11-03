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
      mod.extend(Autoloader::ModuleMethods)._autoloader_extended! caller[0]
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

  module Autoloader::ModuleMethodsModuleMethods
    def extended mod
      class << mod # #sl-106: we do *not* hack const_defined?, but other may
        alias_method :const_defined_without_autoloader?, :const_defined?
      end
    end
  end

  module Autoloader::ModuleMethods
    extend Autoloader::ModuleMethodsModuleMethods
    extend Autoloader::Inflection::Methods # pathify

    -> do
      rx = /^(?<stem>.+)(?=#{::Regexp.escape(Autoloader::EXTNAME)}:\d+:in `)/
      define_method :_autoloader_extended! do |caller_str|
        @dir_path ||= _guess_dir(to_s, caller_str.match(rx)[:stem]) do |e|
          fail "Autoloader hack failed: #{e.class}"
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
      Autoloader::ConstMissing.new const, dir_pathname, self
    end

    attr_reader :dir_path

    def dir_path= str
      @dir_pathname = nil
      @dir_path = str
    end

    def dir_pathname
      @dir_pathname ||= begin
        dir_path or fail("sanity - dir_path not known")
        ::Pathname.new dir_path
      end
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
      mod.const_defined_without_autoloader? const, false or
        fail("#{mod}::#{const} was not defined, must be, in #{file_pathname}")
      nil
    end

    def normalized
      @normalized ||= file_pathname.sub_ext('').to_s
    end
  end
end
