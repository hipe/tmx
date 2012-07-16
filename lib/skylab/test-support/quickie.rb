module Skylab
  module TestSupport
  end
end

module Skylab::TestSupport::Quickie
  module TiteStyle
    _ = [nil, :strong, * Array.new(29), :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    MAP = Hash[ * _.each_with_index.map { |sym, idx| [sym, idx] if sym }.compact.flatten ]
    def stylize str, *styles ; "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m" end
    def title(s) ; stylize(s, :green           ) end
    def faild(s) ; stylize(s, :red             ) end
  end
  module ModuleMethods
    def self.extended mod
      unless defined?(::RSpec)
        mod.send(:extend, ModuleMethodsForQuickie)
        KERNEL_EXTENSION.call
      end
    end
  end
  module ModuleMethodsForQuickie
    def describe desc, *rest, &b
      RUNTIME.describe(desc, *rest, &b)
    end
  end
  class Context < Struct.new(:block, :descs, :indent)
    include TiteStyle
    def describe desc, *descs, &b
      self.class.new(
        (::Hash == descs.last.class ? descs.pop.dup : {}).merge(descs: descs.unshift(desc), block: b)
      ).run
    end
    def eql mxd
      EqualsPredicate.new(mxd, self)
    end
    def fail! msg
      @stderr.puts "#{indent}    #{faild msg}"
    end
    def initialize p=nil
      @stderr = $stderr
      super(nil, nil, '')
      @t1 = Time.now
      p and p.each { |k, v| send("#{k}=", v) }
    end
    def it desc, *descs, &b
      _ = ::Hash == descs.last.class ? descs.pop : nil
      descs.unshift(desc)
      @stderr.puts "#{indent}  #{title descs.join(' ')}"
      self.class.new(block: b, descs: descs).test
    end
    def pass! msg
      @stderr.puts "#{indent}    #{msg}"
    end
    def run
      @stderr.puts "#{indent}#{descs.join(' ')}"
      instance_exec(&block)
      @stderr.puts "\nFinished in #{Time.now - @t1} seconds"
    end
    attr_reader :stderr
    def test
      instance_exec(&block)
    end
  end
  class EqualsPredicate < Struct.new(:expected, :context)
    def match actual
      if expected == actual
        context.pass!("equals #{expected}")
      else
        context.fail!("expected #{expected}, got #{actual}")
      end
    end
  end
  RUNTIME = Context.new
  KERNEL_EXTENSION = -> do
    ::Kernel.send(:define_method, :should) do |predicate|
      predicate.match(self)
    end
  end
end
