$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT = Pathname.new('../..').expand_path(__FILE__)
end


require 'strscan'

module Skylab::Autoloader
  # experimental.  const_missing hax can suck, so use this only if it's compelling.
  # a bit of a mess now until things settle down
  class ThrowingStringScanner < StringScanner
    %w(scan skip).each do |meth|
      alias_method("soft_#{meth}", meth)
      define_method(meth) do |pat|
        x = super(pat) or throw(:parse_failure, "failed to match #{pat.inspect} near #{(rest[0..10] << '(..)').inspect}")
      end
    end
    # like match? but return what was matched
    def snoop re
      idx = match?(re) and peek(idx)
    end
  end
  class << self
    def guess_dir path, cons
      htap = ThrowingStringScanner.new(path.reverse)
      snoc = ThrowingStringScanner.new(cons.reverse)
      p0 = c0 = nil
      no = catch(:parse_failure) do
        p0 = htap.soft_skip(%r|br\.|)
        p0 = htap.scan(%r|[^/]+|)
        c0 = snoc.scan(%r|[^:]+|).gsub( /([A-Z](?=[a-z]))/ ) { "#{$1}-" }.downcase
        if p0 == c0
          if htap.soft_skip(%r|/|) and c0 == htap.snoop(%r|[^/]+|)
            dir = htap.rest.reverse
            return dir
          end
          dir = "#{htap.rest.reverse}/#{c0.reverse}"
          return dir
        end

        snoc.skip(/::/)
        c1 = snoc.scan(%r|[^:]+|).gsub( /([A-Z](?=[a-z]))/ ) { "#{$1}-" }.downcase
        if p0 == c1
           dir = "#{htap.unscan.rest.reverse}/#{c0.reverse}"
           return dir
        end

        htap.skip(%r|/|) ; p0 = htap.scan(%r|[^/]+|)
        if p0 == c0
          dir = htap.unscan.rest.reverse
          return dir
        end

        if p0 == c1
          dir = "#{htap.unscan.rest.reverse}/#{c0.reverse}"
          return dir
        end

      end
      if no
        raise(no)
      end
    end
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

