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
    include module Constants
      EXTNAME = '.rb'
      self
    end
    CALLSTACK_RE = /^(?<path_stem>.+)(?=#{Regexp.escape(EXTNAME)}:\d+:in `)/
    def autoloader_init! caller
      self.dir_path ||= begin
        guess_dir(to_s,  _p = caller.match(CALLSTACK_RE)[:path_stem]) { |e| fail("Autoloader hack failed: #{e}") }
      end
      class << self
        alias_method :const_missing_before_autoloader, :const_missing
        alias_method :const_missing, :handle_const_missing
      end
    end
    def dir ; @dir ||= Pathname.new(dir_path) end
    attr_accessor :dir_path
    PATH_RE = %r{\A(?:(?:(?<rest>|.*[^/])/+)?(?<peek>[^/]*)/+)?(?<curr>[^/]*)/*\z}
    CONS_RE = %r{\A(?:::)?(?:(?:(?<rest>[^:]+(?:::[^:]+)*)::)?(?<peek>[^:]+)::)?(?<curr>[^:]+)\z}
    def guess_dir const, path, &error
      prest, ppeek, pcurr = PATH_RE.match(path ).values_at(1..3)
      cpeek, ccurr = CONS_RE.match(const).values_at(2..3).map { |s| s.gsub(/(?<=[a-z])([A-Z])/){"-#{$1}"}.downcase if s }
      parts = if ppeek == ccurr       ; [prest, ppeek]                  # a::b     a/b/c   # a/b/b a::b
      elsif pcurr == ccurr            ; [prest, ppeek, pcurr]           # a::b     a/b     # a     a
      elsif pcurr == cpeek            ; [prest, ppeek, pcurr, ccurr]    # a::b::c  a/b
      elsif ppeek && ppeek == cpeek   ; [prest, ppeek, ccurr]           # a::b::d  a/b/f
      end
      parts ? parts.compact.join('/') : error.call("failed to infer path for #{const} from #{path}")
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
    include module Inflection ; self end # defined below
  end
  module Autoloader::Inflection
    include Autoloader::Constants
    SANITIZE_PATH_RE = %r{#{Regexp.escape(EXTNAME)}\z|(?<=/)/+|(?<=-)-+|[^-/a-z0-9]+}i
    def constantize path
      path.to_s.gsub(SANITIZE_PATH_RE, '').gsub(%r|/+|, '::').gsub(/(?:(?<=\d)|[_-]|\b)([a-z0-9])/) { $1.upcase }
    end
    def pathify const
      const.to_s.gsub('::', '/').gsub(/(?<=^|([a-z]))([A-Z])/) { "#{'-' if $1}#{$2}" }.downcase
    end
  end
end

