$:.include?(o = File.expand_path('..', __FILE__)) or $:.unshift(o)

require 'pathname'

module Skylab
  ROOT = Pathname.new('../..').expand_path(__FILE__)
end


require 'strscan'

module Skylab::Autoloader
  # experimental.  const_missing hax can suck, so use this only if it's compelling.
  # a bit of a mess now until things settle down
  class << self
    def extended mod
      dir = mod.dir_path = guess_dir(mod, %r{^(.+)\.rb:\d+:in `}.match(caller[0])[1])
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
    def guess_dir cons, path
      no = catch(:parse_failure) do
        p = BackwardsTokenizer.new(path.reverse, %r{[^/]+}, %r{/} )
        c = BackwardsTokenizer.new(cons.reverse, /[^:]+/, /::/) { |s| s.gsub(/([A-Z](?=[a-z]))/){"#{$1}-"}.downcase }
        if p.next == c.next
          c.curr == p.peek and return p.rest                              # a/b/b a::b
          return "#{p.rest}/#{c.current}"                                 # a/b   a::b
        end
        p.peek == c.curr and return p.rest                                # a/b/c a::b
        p.curr == c.peek and return "#{p.rest}/#{p.current}/#{c.current}" # a/b   a::b::c
        p.peek == c.peek and return "#{p.rest}/#{c.current}"              # a/b/p a::b::q
        throw(:parse_failure, "failed to infer path for #{cons} from #{path}")
        nil
      end
      no and raise(no)
    end
  end
  attr_accessor :dir_path
  def dir
    @dir ||= Pathname.new(dir_path)
  end
  class ThrowingStringScanner < StringScanner
    %w(scan skip).each do |meth|
      alias_method("soft_#{meth}", meth)
      define_method(meth) do |pat|
        x = super(pat) or
          throw(:parse_failure, "failed to match #{pat.inspect} near #{(rest[0..10] << '(..)').inspect}")
      end
    end
    alias_method :strscan_peek, :peek
    def snoop re ; idx = match?(re) and strscan_peek(idx) end
  end
  class SimpleTokenizer < ThrowingStringScanner
    attr_reader :curr
    def initialize str, *a, &b
      super(str)
      @token_pattern, @separator_pattern = a
      @filter = b || ->(s){s}
    end
    def next
      @curr = @filter.call(scan @token_pattern)
      soft_skip @separator_pattern
      @curr
    end
    def peek ; s = snoop(@token_pattern) and @filter.call(s) end
    alias_method :strscan_rest, :rest
  end
  class BackwardsTokenizer < SimpleTokenizer
    def current ; @curr.reverse  end
    def rest    ; super.reverse  end
  end
end

