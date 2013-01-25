# [#bs-010] poster child

module Skylab::TestSupport::Quickie

  TestSupport = ::Skylab::TestSupport # exemption from [#sl-123]

  hack_the_kernel_once = -> do
    ::Kernel.send( :define_method, :should ) do |predicate|
      predicate.match self
    end
    hack_the_kernel_once = nil
  end

  define_singleton_method :extended do |mod| # #pattern [#sl-111] (sort of)
    if ! defined? ::RSpec
      mod.send :extend, ModuleMethods
      hack_the_kernel_once[ ] if hack_the_kernel_once # kinda janky here but
                                  # this *must* be counter-conditional on
    end                           # rspec being loaded!
  end

  module TiteStyle
    _ = [nil, :strong, * Array.new(29), :red, :green, :yellow, :blue, :magenta, :cyan, :white]
    MAP = Hash[ * _.each_with_index.map { |sym, idx| [sym, idx] if sym }.compact.flatten ]
    def stylize str, *styles ; "\e[#{styles.map{ |s| MAP[s] }.compact.join(';')}m#{str}\e[0m" end # [#ts-005]
    def title(s) ; stylize(s, :green           ) end
    def faild(s) ; stylize(s, :red             ) end
    def passd(s) ; stylize(s, :green           ) end
    def pendng s ; stylize s, :yellow            end
    def s(num)   ; 's' unless 1 == num           end
  end

  module ModuleMethods
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
    attr_accessor :infostream
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
    include ::Skylab::MetaHell::Let::ModuleMethods

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
      # #todo something is broken here - try substituting a 'desc' for a 'ctx'
      c = ContextClass[normalize_parameters(desc, *rest, indent: indent, parent: self, infostream: infostream,
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
    include ::Skylab::MetaHell::Let::InstanceMethods

    def self.ivar_or_class prop
      attr_reader prop
      ivar_reader = "#{ prop }_ivar"
      alias_method ivar_reader, prop
      define_method prop do
        send ivar_reader or self.class.send prop
      end
    end

    attr_writer :block

    order = [ :include, :exclude ].freeze

    define_method :describe_run_options do
      a = @run_options_desc.sort_by do |k, v|
        order.index( k ) || order.length
      end
      a.map! { |k, v| "#{ k } #{ Hash[* v.flatten].inspect }" }
      1 == a.length ? " #{a.first}" : ([''] + a).join("\n  ")
    end

    ivar_or_class :descs

    attr_accessor :exampled

    def example_blocks
      self.class.example_blocks
    end

    def fail msg
      infostream.puts "#{indent}  #{faild msg}"
      @failed.call
    end

    attr_writer :failed

    ivar_or_class :indent

    def initialize p=nil
      p and update_attributes!(p)
    end

    def parse_opts argv
      @tag_filter = @tag_filter_desc = nil
      ors = descs = nil
      TestSupport::Services::OptionParser.new do |o|
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
    rescue TestSupport::Services::OptionParser::ParseError => e
      infostream.puts "#{e}\ntry #{title "ruby #{$PROGRAM_NAME} -h"} for help"
      false
    end

    def pass msg_func
      # infostream.puts "#{indent}  #{msg}"
      passed && passed.call
    end

    attr_accessor :passed

    attr_accessor :pended

    ivar_or_class :infostream

    def run
      parse_opts(ARGV) or return
      @tag_filter and infostream.puts("Run options:#{describe_run_options}\n\n")
      e = f = p = 0
      @exampled = -> { e += 1 }
      @failed = -> { f += 1 }
      @pended = -> { p += 1 }
      _run_children
      0 == e and infostream.puts("\nAll examples were filtered out")
      infostream.puts "\nFinished in #{Time.now - T1} seconds"
      pnd = ", #{ p } pending" if p > 0
      infostream.puts send( f > 0 ? :faild : ( p > 0 ? :pendng : :passd),
                      "#{ e } example#{ s e }, #{ f } failure#{ s f }#{ pnd }" )
    end

    attr_accessor :tags

    ivar_or_class :tag_filter

    attr_writer :tag_filter

  protected

    def _run
      if @block
        @exampled.call
        infostream.puts "#{indent}#{title descs.join(' ')}"
        instance_eval(& @block)
      else
        @pended.call
        infostream.puts "#{indent}#{pendng descs.join(' ')}"
      end
      nil
    end

    def _run_children
      infostream.puts "#{indent}#{descs.join(' ')}"
      _indent = "#{indent}  "
      _params = { exampled: @exampled, failed: @failed, pended: @pended,
                  indent: "#{indent}  ", infostream: infostream,
                  tag_filter: tag_filter }
      example_blocks.each do |eb|
        if ::Class == eb.class
          eb.new(_params)._run_children
        else
          ex = self.class.new(eb.merge(_params))
          if ! tag_filter or tag_filter.call(ex.tags)
            ex._run
          end
        end
      end
    end
  end

  class EqualsPredicate < Struct.new :context, :expected
    def match actual
      if expected == actual
        context.pass -> { "equals #{ expected.inspect }" }
      else
        context.fail "expected #{ expected.inspect }, got #{ actual.inspect }"
      end
      nil
    end
  end

  class IncludePredicate < ::Struct.new :context, :expected # yeah about that..
    def match actual
      if actual.include? expected
        context.pass -> { "includes #{ expected.inspect }" }
      else
        context.fail "expected #{ actual.inspect } to include #{
          }#{ expected.inspect }"
      end
      nil
    end
  end

  class KindOfPredicate < ::Struct.new :context, :expected
    def match actual
      if actual.kind_of? expected
        context.pass -> { "is kind of #{ expected.inspect }" }
      else
        context.fail "expected #{ actual.inspect } to include #{
        }#{ expected.inspect }"
      end
      nil
    end
  end

  class MatchPredicate < ::Struct.new :context, :expected
    def match actual
      if expected =~ actual
        context.pass -> { "matches #{ expected.inspect }" }
      else
        context.fail "expected #{ expected.inspect }, had #{ actual.inspect } "
      end
      nil
    end
  end

  class RaiseErrorPredicate < ::Struct.new :context, :expected_class, :message_rx
    def match actual
      begin
        actual.call
      rescue ::StandardError => e
      end
      if ! e
        context.fail "expected lambda to raise, didn't raise anything."
      elsif ! e.kind_of?( expected_class )
        context.fail "expected #{ expected_class }, had #{ e.class }"
      elsif message_rx !~ e.message
        context.fail "expected #{ e.message } to match #{ message_rx }"
      else
        context.pass -> do
          "raises #{ expected_class } matching #{ message_rx }"
        end
      end
      nil
    end
  end

  module ContextInstanceMethods # re-opened
    # egads this feels wrong sorry, borrow against the future i guess
    [
      :be_include , IncludePredicate,
      :be_kind_of , KindOfPredicate,
      :match      , MatchPredicate,
      :eql        , EqualsPredicate,
      :raise_error, RaiseErrorPredicate
    ].
      each_slice 2 do |meth, const|
      define_method meth do |expected, *rest|
        const.new self, expected, *rest
      end
    end
  end

  RUNTIME = ContextClass[ infostream: $stderr, indent:'' ]
  T1 = Time.now
end
