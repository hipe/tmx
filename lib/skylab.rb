$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT = Pathname.new('../..').expand_path(__FILE__)
end


module Skylab
  # experimental.  const_missing hax can suck, so use this only if it's compelling.
  # a bit of a mess now until things settle down
  module Autoloader
    def self.extended mod ; mod.autoloader_init!(caller[0]) end
    include module Inflection
      EXTNAME = '.rb'
      self
    end # reopened below
    CALLSTACK_RE = /^(?<path_stem>.+)(?=#{Regexp.escape(EXTNAME)}:\d+:in `)/
    def autoloader_init! caller
      self.dir_path ||= begin
        guess_dir(to_s, caller.match(CALLSTACK_RE)[:path_stem]) { |e| fail("Autoloader hack failed: #{e}") }
      end
      class << self
        alias_method :const_missing_before_autoloader, :const_missing
        alias_method :const_missing, :handle_const_missing
      end
    end
    def dir ; @dir ||= Pathname.new(dir_path) end
    attr_accessor :dir_path
    PATH_RE = %r{\A(?:(?:(?<rest>|.*[^/])/+)?(?<peek>[^/]*)/+)?(?<curr>[^/]*)/*\z}
    CONST_TOKENIZER = Object.new.tap do |o| o.singleton_class.class_eval do
      include Inflection
      attr_reader :curr, :rest, :past
      def initialize
        @re = %r{\A(?:(?<rest>(?:(?!=::).)+)::)?(?:::)?(?<curr>[^:]+)\z}
        @past = []
      end
      def next
        if md = @re.match(@rest)
          @curr and @past.push(@curr)
          @curr = pathify md[:curr]
          @rest = md[:rest]
          true
        else
          @rest = @curr = nil
          false
        end
      end
      def string! string
        @curr = nil
        @rest = string
        @past.clear
        self
      end
    end ; o.initialize end
    def guess_dir const, path, &error
      prest, ppeek, pcurr = PATH_RE.match(path ).values_at(1..3)
      c = CONST_TOKENIZER.string!(const)
      search = [ppeek, pcurr].compact ; found = nil
      nil while c.next && ! (found = search.index(c.curr))
      if found
        [ * [prest].compact, * search[0..found], * c.past.reverse].join('/')
      else
        error.call("failed to infer path for #{const} from #{path}")
      end
    end
    def handle_const_missing const
      path = "#{dir_path}/#{pathify const}"
      fail("circular autoload dependency detected in #{path}") if (@_autoloader_mutex ||= Hash.new{|h, k| h[k] = 1; nil})[path]
      File.exist?("#{path}#{EXTNAME}") ? require(path) : no_such_file(path, const)
      const_defined?(const) or fail("#{self}::#{const} was not defined, must be, in #{path}")
      const_get const
    end
    def no_such_file path, const
      raise LoadError.new("no such file to load -- #{path}")
    end
  end
  module Autoloader::Inflection
    SANITIZE_PATH_RE = %r{#{Regexp.escape(EXTNAME)}\z|(?<=/)/+|(?<=-)-+|[^-/a-z0-9]+}i
    def constantize path
      path.to_s.gsub(SANITIZE_PATH_RE, '').gsub(%r|/+|, '::').gsub(/(?:(?<=\d)|[_-]|\b)([a-z0-9])/) { $1.upcase }
    end
    def pathify const
      const.to_s.gsub('::', '/').gsub(/(?<=[a-z])([A-Z])|(?<=[A-Z])([A-Z][a-z])/) { "-#{$1 || $2}" }.downcase
    end
  end
end

