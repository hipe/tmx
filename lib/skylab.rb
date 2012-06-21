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
      dir = mod.dir_path = find_dir(mod, %r{^(.+)\.rb:\d+:in `}.match(caller[0])[1])
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
    POP = %r{\A(?<dirname>.+)/(?<basename>[-a-z]+)\z}
    def find_dir mod, caller_path
      slug = mod.to_s.match(/[^:]+\z/)[0].gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.downcase
      File.directory?(p = "#{caller_path}/#{slug}") and return p
      curr = caller_path
      while o = POP.match(curr)
        if o[:basename] == slug
          oo = POP.match(o[:dirname]) and oo[:basename] == slug and o = oo # allow for foo-bar/foo-bar style paths
          return o.captures.join('/')
        end
        "#{o[:dirname]}/#{slug}".tap { |path| File.directory?(path) and return path }
        curr = o[:dirname]
      end
      fail("didn't find #{slug.inspect} in #{caller_path.inspect}")
    end
  end
  attr_accessor :dir_path
  def dir ;  @dir ||= begin ; require 'pathname' ; Pathname.new(dir_path) ; end
  end
end

