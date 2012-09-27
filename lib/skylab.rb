$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT_PATHNAME = ::Pathname.new('../..').expand_path(__FILE__)
  TMPDIR_PATHNAME = ROOT_PATHNAME.join('tmp')
end

module Skylab
  # experimental.  const_missing hax can suck, so use this only if it's
  # compelling.  a bit of a mess now until things settle down
  module Autoloader end
  module Autoloader::Inflection
    extend self
    InstanceMethods = self # future-proof
    EXTNAME = '.rb'
    SANITIZE_PATH_RE =
      %r{#{Regexp.escape(EXTNAME)}\z|(?<=/)/+|(?<=[-_ ])[-_ ]+|[^-_ /a-z0-9]+}i
    def constantize path
      path.to_s.gsub(SANITIZE_PATH_RE, '').gsub(%r|/+|, '::').
        gsub(/(?<=[-_ ])([A-Z])/){ $1.downcase }.
        gsub(/(?:(?<=\d)|[-_ ]|\b)([a-z09])/) { $1.upcase }
    end
    def pathify const
      const.to_s.gsub('::', '/').
        gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) { "-#{$1 || $2}" }.
        gsub('_', '-').downcase
    end
  end
  module Autoloader
    def self.extended mod
      mod.autoloader_init! caller[0]
    end
    include Autoloader::Inflection::InstanceMethods
    CALLSTACK_RE = /^(?<path_stem>.+)(?=#{::Regexp.escape(EXTNAME)}:\d+:in `)/
    def autoloader_init! caller
      self.dir_path ||= begin
        guess_dir(to_s, caller.match(CALLSTACK_RE)[:path_stem],
          &->(e) { fail("Autoloader hack failed: #{e}") } )
      end
      class << self
        alias_method :const_missing_before_autoloader, :const_missing
        alias_method :const_missing, :handle_const_missing
      end
    end
    def dir_pathname ; @dir_pathname ||= ::Pathname.new(dir_path) end
    attr_accessor :dir_path
    CONST_RE = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}
    CONST_TOKENIZER = ->(str) do # returns a lambda that makes a closure around
      ->() do # 'str' which returns successive next tokens with each call()
        if md = CONST_RE.match(str)
          str = md[:rest]
          Inflection.pathify(md[:curr])
        end
      end
    end

    PATH_RE =
      %r{\A(?:(?:(?<rest>|.*[^/])/+)?(?<peek>[^/]*)/+)?(?<curr>[^/]*)/*\z}
    def guess_dir const, path, &error
      head, *search = PATH_RE.match(path ).values_at(1..3)
      search.compact!
      c = CONST_TOKENIZER.call(const) ; t = found = nil ; past = []
      past.push(t) while t = c.call and ! found = search.index(t)
      if found
        [ * [head].compact, * search[0..found], * past.reverse ].join('/')
      else
        error.call("failed to infer path for #{const} from #{path}")
      end
    end
    def handle_const_missing const
      path = "#{dir_path}/#{pathify const}"
      fail("circular autoload dependency detected in #{path} with #{const}") if
        (@_autoloader_mutex ||= Hash.new{|h, k| h[k] = 1; nil})[path]
      if File.exist?("#{path}#{EXTNAME}")
        require(path)
      else
        no_such_file(path, const)
      end
      const_defined?(const) or
        fail("#{self}::#{const} was not defined, must be, in #{path}")
      const_get const
    end
    def no_such_file(path, const)
      raise LoadError.new("no such file to load -- #{path}")
    end
  end
end
