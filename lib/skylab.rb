$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT = Pathname.new('../..').expand_path(__FILE__)
end


module Skylab
  module Autoloader
    # experimental.  const_missing hax can suck, so use this only if it's compelling.
    #
  end
  class << Autoloader
    def extended mod
      dir = find_dir(mod, %r{^(.+)\.rb:\d+:in `}.match(caller[0])[1])
      mod.singleton_class.send(:alias_method, :orig_const_missing, :const_missing)
      mod.singleton_class.send(:define_method, :const_missing) do |const|
        stem = const.to_s.gsub(/(?<=^|([a-z]))([A-Z])/) { "#{'-' if $1}#{$2.downcase}" }
        require "#{dir}/#{stem}"
        const_get const
      end
    end
    def find_dir mod, caller_path
      split = ->(path) { md = %r{\A(.+)/([-a-z]+)\z}.match(path) and md.captures }
      slug = mod.to_s.match(%r{[^:]+\z})[0].match(/[^:]+\z/)[0].gsub(/([a-z])([A-Z])/){ "#{$1}-#{$2}" }.downcase
      curr = caller_path.dup
      dir = nil
      while a = split[curr]
        if slug == a.last
          aa = split[a.first] and aa.last == slug and a = aa # allow for foo-bar/foo-bar style paths
          dir = a.join('/')
          break
        else
          curr = a.first
        end
      end
      dir or fail("didn't find #{slug.inspect} in #{caller_path.inspect}")
    end
  end
end

