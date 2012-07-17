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
    def passd(s) ; stylize(s, :green           ) end
    def s(num)   ; 's' unless 1 == num           end
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
  module CommonMethods
    include TiteStyle
    attr_accessor :descs
    def initialize p
      p.each { |k, v| send("#{k}=", v) }
    end
    def normalize_parameters desc, *rest, &b
      params = { block: b }
      params.merge!(rest.pop) while ::Hash == rest.last.class
      params[:descs] = rest.unshift(desc)
      params
    end
    attr_accessor :stderr
  end
  class ContextModule < ::Module
    include CommonMethods
    def block= b
      module_eval(&b)
    end
    _desc_num = 0
    NEXT_DESC_NUM = ->{ _desc_num += 1 }
    def describe desc, *rest, &b
      cmod = self.class.new(normalize_parameters(desc, *rest, stderr: stderr, &b))
      parent.const_set("Describe#{NEXT_DESC_NUM.call}", cmod)
      Context.new(context_module: cmod).run
    end
    def example_blocks
      @example_blocks ||= []
    end
    def it d, *rest, &b
      example_blocks.push normalize_parameters(d, *rest, &b)
    end
    attr_accessor :parent
  end
  class Context
    include CommonMethods
    attr_reader :descs
    def context_module= mod
      @context_module = mod
      @descs = mod.descs
      @example_blocks = mod.example_blocks
      @stderr = mod.stderr or fail('no')
    end
    attr_reader :context_module
    def fail! ; @f += 1 end
    def indent
      @indent ||= ''
    end
    def pass! ; @p += 1 end
    def run
      @p = @f = f = e = 0
      @stderr.puts "#{indent}#{descs.join(' ')}"
      @example_blocks.each do |tb|
        before = @f
        Example.new(tb.merge(parent: self)).run
        f+= 1 if @f > before
        e += 1
      end
      @stderr.puts "\nFinished in #{Time.now - T1} seconds"
      @stderr.puts send(f > 0 ? :faild : :passd, "#{e} example#{s e}, #{f} failure#{s f}")
    end
  end
  class Example < Context
    attr_accessor :block
    def eql expected
      EqualsPredicate.new(expected, self)
    end
    def fail! msg
      @stderr.puts "#{indent}  #{faild msg}"
      @failed.call
    end
    def parent= tc
      extend tc.context_module
      @failed = -> { tc.fail! }
      @passed = -> { tc.pass! }
      @indent = "#{tc.indent}  "
      @stderr = tc.stderr
    end
    def pass! msg
      # @stderr.puts "#{indent}  #{msg}"
      @passed.call
    end
    def run
      @stderr.puts "#{indent}#{title descs.join(' ')}"
      instance_eval(&@block)
    end
  end
  class EqualsPredicate < Struct.new(:expected, :context)
    def match actual
      if expected == actual
        context.pass!("equals #{expected.inspect}")
      else
        context.fail!("expected #{expected.inspect}, got #{actual.inspect}")
      end
    end
  end
  RUNTIME = ContextModule.new(parent: self, stderr: $stderr)
  KERNEL_EXTENSION = -> do
    ::Kernel.send(:define_method, :should) do |predicate|
      predicate.match(self)
    end
  end
  T1 = Time.now
end
