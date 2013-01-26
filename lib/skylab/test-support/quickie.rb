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
      # infostream.puts "#{indent}  #{msg_func[]}"  # maybe verbose ..
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

    def initialize p=nil
      p and update_attributes!(p)
    end

    no_method = -> actual, context do
      context.fail "expected #{ actual.inspect } to have a #{
        }`#{ context.expected_method_name }` method"
      nil
    end

    omfg_h = {
      kind_of: [ "is kind of", "to be kind of" ],
      include: [ "includes", "to include" ],
      nil:     [ "is nil", "to be nil" ]
    }

    insp = -> x do # this is just a placeholder becuase we know
      x.inspect # we might end up needing to fix all these file wide ..
    end

    msgs = -> be_what, takes_args do
      pos, neg = omfg_h.fetch be_what.intern do |k|
        stem = be_what.gsub '_', ' '
        [ "is #{ stem }", "to be #{ stem }" ]
      end
      if takes_args
        pass_msg = -> a, p { "#{ pos } #{ insp[ p.expected ] }" }
        fail_msg = -> a, p { "expected #{ insp[a] } #{ neg } #{ insp[ p.expected ] }" }
      else
        pass_msg = -> a, p { pos.dup }
        fail_msg = -> a, p { "expected #{ insp[a] } #{ neg }" }
      end
      [pass_msg, fail_msg]
    end

    define_method :_be_the_prediate_you_wish_to_see do |md, args, b|
      const = FUN.constantize_meth[ md.string ]
      if Predicates.const_defined? const, false
        klass = Predicates.const_get const, false
      else
        struct_a = [ :context ]
        takes_args = args.length.nonzero?
        struct_a << :expected if takes_args
        klass = ::Class.new( ::Struct.new( * struct_a ) )
        klass.singleton_class.send :public, :define_method
        Predicates.const_set const, klass
        frozen_a = [].freeze
        klass.define_method :args, & ( takes_args ?
          -> { [ expected ] } : -> { frozen_a } )
        meth = "#{ md[:be_what] }?".intern
        klass.define_method :expected_method_name do meth end
        pass_msg, fail_msg = msgs[ md[:be_what], takes_args ]
        klass.define_method :match do |actual|
          if actual.respond_to? meth
            if actual.send meth, *args
              context.pass -> { pass_msg[ actual, self ] }
            else
              context.fail fail_msg[ actual, self ]
            end
          else
            no_method[ actual, self ]
          end
        end
      end
      klass.new self, * args
    end

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

    be_rx = /\Abe_(?<be_what>[a-z][_a-z0-9]*)\z/

    define_method :method_missing do |meth, *args, &b|
      md = be_rx.match meth.to_s
      if md
        _be_the_prediate_you_wish_to_see md, args, b
      else
        super meth, *args, &b
      end
    end
  end

  module Predicates
    # fill it with joy, fill it with sadness
  end

  class Predicates::Eql < Struct.new :context, :expected
    def match actual
      if expected == actual
        context.pass -> { "equals #{ expected.inspect }" }
      else
        context.fail "expected #{ expected.inspect }, got #{ actual.inspect }"
      end
      nil
    end
  end

  class Predicates::Match < ::Struct.new :context, :expected
    def match actual
      if expected =~ actual
        context.pass -> { "matches #{ expected.inspect }" }
      else
        context.fail "expected #{ expected.inspect }, had #{ actual.inspect } "
      end
      nil
    end
  end

  class Predicates::RaiseError < ::Struct.new :context, :expected_class, :message_rx
    def match actual
      begin
        actual.call
      rescue ::StandardError => e
      end
      if ! e
        context.fail "expected lambda to raise, didn't raise anything."
      else
        ok = true
        if expected_class
          if ! e.kind_of?( expected_class )
            ok = false
            context.fail "expected #{ expected_class }, had #{ e.class }"
          end
        end
        if ok && message_rx
          if message_rx !~ e.message
            ok = false
            context.fail "expected #{ e.message } to match #{ message_rx }"
          end
        end
        if ok
          context.pass -> do
            "raises #{ expected_class } matching #{ message_rx }"
          end
        end
      end
      nil
    end

  protected

    def initialize context, *a # #todo we should actually remove some of this
      use_a = []
      use_a << ( ( ::Class === a.first ) ? a.shift : nil )
      if ::Regexp === a.first
        use_a << a.shift
      elsif ::String === a.first
        use_a << %r{\A#{ ::Regexp.escape a.shift }\z}
      else
        use_a << nil
      end
      if a.length.nonzero? || use_a.length.zero?
        raise ::ArgumetnError, "expecting [class], ( regexp | string ), #{
          }near: #{ a.first.inspect }"
      end
      super context, * use_a
    end
  end

  o = { }

  o[:constantize_meth] = -> meth do # foo_bar !ncsa_spy !crack_ncsa_code foo
    meth.to_s.gsub( /(?:^|_)([a-z])/ ) { $1.upcase }.intern
  end

  o[:methify_const] = -> const do # FooBar NCSASpy CrackNCSACode FOO
    const.to_s.gsub( /
     (    (?<= [a-z] )[A-Z] |
          (?<= . ) [A-Z] (?=[a-z]))
     /x ) { "_#{ $1 }" }.downcase.intern
  end

  FUN = ::Struct.new(* o.keys ).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  module ContextInstanceMethods # re-opened
    Predicates.constants.each do |const| # just goofing around
      meth = FUN.methify_const[ const ]
      klass = Predicates.const_get const, false
      define_method meth do |expected, *rest|
        klass.new self, expected, *rest
      end
    end
  end

  RUNTIME = ContextClass[ infostream: $stderr, indent:'' ]

  T1 = Time.now
end
