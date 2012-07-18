require 'optparse'

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
    def normalize_parameters desc, *rest, params, &b
      params = params.merge( block: b )
      ::Hash == rest.last.class and params[:tags] = rest.pop
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
      c = ContextClass[normalize_parameters(desc, *rest, indent: indent, parent: self,
                                            tag_filter: tag_filter, &b)]
      example_blocks.push c
    end
    def describe desc, *rest, &b
      c = ContextClass[normalize_parameters(desc, *rest, indent: indent, parent: self, stderr: stderr,
                                            tag_filter: tag_filter, &b)]
      o = c.new
      o.run
    end
    def example_blocks
      @example_blocks ||= []
    end
    def it d, *rest, &b
      example_blocks.push normalize_parameters(d, *rest, {}, &b)
    end
    attr_accessor :tag_filter
    attr_accessor :tags
  end
  module ContextInstanceMethods
    include CommonMethods
    attr_writer :block
    ORDER = [:include, :exclude]
    def describe_run_options
      a = @run_options_desc.sort_by{ |k, _| ORDER.index(k) || ORDER.length }.map do |k, v|
        "#{k} #{Hash[* v.flatten].inspect}"
      end
      1 == a.length ? " #{a.first}" : ([''] + a).join("\n  ")
    end
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
    def parse_opts argv
      @tag_filter = @tag_filter_desc = nil
      ors = descs = nil
      ::OptionParser.new do |o|
        o.on('-t', '--tag TAG[:VALUE]', '(tries to be like the option in rspec',
         'but only sees leaf- not branch-level tags at this time.)'
        ) do |v|
          md = /\A(?<not>~)?(?<tag>[^:]+)(?::(?<val>.+))?\z/.match(v) or
            raise ::OptionParser::InvalidArgument
          _not, tag, val = md.captures.zip([nil, nil, true]).map { |a, b| a || b }
          ors ||= [] ; descs ||= {} ; tag = tag.intern
          if _not
            (descs[:exclude] ||= []).push([tag, val])
            ors.push ->(tags) { ! (tags and val == tags[tag]) }
          else
            (descs[:include] ||= []).push([tag, val])
            ors.push ->(tags) { tags and val == tags[tag] }
          end
        end
      end.parse!(argv)
      if ors
        @run_options_desc = descs
        @tag_filter = ->(tags) { ors.detect { |l| l.call(tags) } }
      end
      true
    rescue ::OptionParser::ParseError => e
      stderr.puts "#{e}\ntry #{title "ruby #{$PROGRAM_NAME} -h"} for help"
      false
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
      parse_opts(ARGV) or return
      @tag_filter and stderr.puts("Run options:#{describe_run_options}\n\n")
      e = f = 0
      @exampled = ->() { e += 1 }
      @failed = -> { f += 1 }
      _run_children
      0 == e and stderr.puts("\nAll examples were filtered out")
      stderr.puts "\nFinished in #{Time.now - T1} seconds"
      stderr.puts send(f > 1 ? :faild : :passd, "#{e} example#{s e}, #{f} failure#{s f}")
    end
    def _run
      stderr.puts "#{indent}#{title descs.join(' ')}"
      instance_eval(&@block)
      nil
    end
    def _run_children
      stderr.puts "#{indent}#{descs.join(' ')}"
      _indent = "#{indent}  "
      _params = { exampled: @exampled, failed: @failed, indent: "#{indent}  ", stderr: stderr,
                  tag_filter: tag_filter }
      example_blocks.each do |eb|
        if ::Class == eb.class
          eb.new(_params)._run_children
        else
          ex = self.class.new(eb.merge(_params))
          if ! tag_filter or tag_filter.call(ex.tags)
            ex._run
            @exampled.call
          end
        end
      end
    end
    attr_accessor :tags
    def tag_filter
      @tag_filter ||= nil or self.class.tag_filter
    end
    attr_writer :tag_filter
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
