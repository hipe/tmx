$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT = Pathname.new('../..').expand_path(__FILE__)
end


module Skylab
  module Autoloader
    # experimental.  const_missing hax can suck, so use this only if it's compelling.

    def self.extended mod
      here = %r{^(.+)\.rb:\d+:in `}.match(caller[0])[1] # the path of the module (no extension)
      here.sub!(%r{([^/]+)(/\1)\z}) { $1 } # allow for foo-bar/foo-bar style paths
      mod.singleton_class.send(:alias_method, :orig_const_missing, :const_missing)
      mod.singleton_class.send(:define_method, :const_missing) do |const|
        stem = const.to_s.gsub(/(?<=^|([a-z]))([A-Z])/) { "#{'-' if $1}#{$2.downcase}" }
        require "#{here}/#{stem}"
        const_get const
      end
    end
  end
end

