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
    attr_accessor :indent
    def normalize_parameters desc, *rest, &b
      params = { block: b }
      params.merge!(rest.pop) while ::Hash == rest.last.class
      params[:descs] = rest.unshift(desc) if desc
      params
    end
    attr_accessor :stderr
    def update_attributes! p
      p.each { |k, v| send("#{k}=", v) }
    end
  end
  module ContextClass
    def self.[] params
      p = params.delete(:parent)
      c = ::Class.new(* [p].compact)
      c.send(:extend, ContextClassMethods)
      c.send(:include, ContextInstanceMethods)
      c.update_attributes! params
      c
    end
  end
  module ContextClassMethods
    include CommonMethods
    def block= b
      class_eval(&b)
    end
    def context *rest, &b
      desc = rest.shift
      c = ContextClass[normalize_parameters(desc, *rest, indent: indent, parent: self, &b)]
      example_blocks.push c
    end
    def describe desc, *rest, &b
      c = ContextClass[normalize_parameters(desc, *rest, indent: indent, parent: self, stderr: stderr, &b)]
      o = c.new
      o.run
    end
    def example_blocks
      @example_blocks ||= []
    end
    def it d, *rest, &b
      example_blocks.push normalize_parameters(d, *rest, &b)
    end
  end
  module ContextInstanceMethods
    include CommonMethods
    attr_writer :block
    def descs
      (@descs ||= nil) or self.class.descs
    end
    def eql expected
      EqualsPredicate.new(expected, self)
    end
    attr_accessor :exampled
    def example_blocks ; self.class.example_blocks end
    def fail! msg
      stderr.puts "#{indent}  #{faild msg}"
      @failed.call
    end
    attr_writer :failed
    def indent ; (@indent ||= nil) or self.class.indent end
    def initialize p=nil
      p and update_attributes!(p)
    end
    def pass! msg
      # stderr.puts "#{indent}  #{msg}"
      (@passed ||= nil) and @passed.call
    end
    attr_writer :passed
    def stderr
      (@stderr ||= nil) or self.class.stderr
    end
    def run
      e = f = 0
      @exampled = ->() { e += 1 }
      @failed = -> { f += 1 }
      _run_children
      stderr.puts "\nFinished in #{Time.now - T1} seconds"
      stderr.puts send(f > 0 ? :faild : :passd, "#{e} example#{s e}, #{f} failure#{s f}")
    end
    def _run
      stderr.puts "#{indent}#{title descs.join(' ')}"
      instance_eval(&@block)
      nil
    end
    def _run_children
      stderr.puts "#{indent}#{descs.join(' ')}"
      _indent = "#{indent}  "
      _params = { exampled: @exampled, failed: @failed, indent: "#{indent}  ", stderr: stderr }
      example_blocks.each do |eb|
        if ::Class == eb.class
          eb.new(_params)._run_children
        else
          self.class.new(eb.merge(_params))._run
          @exampled.call
        end
      end
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
  RUNTIME = ContextClass[stderr: $stderr, indent:'']
  KERNEL_EXTENSION = -> do
    ::Kernel.send(:define_method, :should) do |predicate|
      predicate.match(self)
    end
  end
  T1 = Time.now
end
