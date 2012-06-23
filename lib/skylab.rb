$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT = Pathname.new('../..').expand_path(__FILE__)
end


module Skylab::Autoloader
  # experimental.  const_missing hax can suck, so use this only if it's compelling.
  # a bit of a mess now until things settle down
  class << self
    def extended mod
      dir = mod.dir_path = guess_dir(mod.to_s, %r{^(.+)\.rb:\d+:in `}.match(caller[0])[1]) { |e| fail(e) }
      mod.singleton_class.send(:alias_method, :orig_const_missing, :const_missing)
      mod.singleton_class.send(:define_method, :const_missing) do |const|
        path = "#{dir}/#{const.to_s.gsub(/(?<=^|([a-z]))([A-Z])/) { "#{'-' if $1}#{$2}" }.downcase}"
        (@_autoloader_mutex ||= {})[path] and fail("fix circular autoload dependency in #{path}")
        @_autoloader_mutex[path] = true
        require path
        const_defined?(const) or fail("#{self}::#{const} was not defined, must be, in #{path}")
        const_get const
      end
    end
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
  end
  attr_accessor :dir_path
  def dir
    @dir ||= Pathname.new(dir_path)
  end
end

