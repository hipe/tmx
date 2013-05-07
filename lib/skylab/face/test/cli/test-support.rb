require_relative '../../core'
require 'skylab/test-support/core'
require 'skylab/headless/test/test-support'

module Skylab::Face::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    Face = ::Skylab::Face
    Headless = ::Skylab::Headless
    Headless_TestSupport = ::Skylab::Headless::TestSupport
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end
end

module Skylab::Face::TestSupport::CLI

  ::Skylab::Face::TestSupport[ CLI_TestSupport = self ]

  include CONSTANTS

  module CONSTANTS
    CLI_TestSupport = CLI_TestSupport
  end

  extend TestSupport::Quickie

  module Sandbox
  end

  TestSupport::Sandbox.enhance( Sandbox ).produce_subclasses_of -> { Face::CLI }

  module ModuleMethods

    include CONSTANTS

    extend MetaHell::Let

    extend MetaHell::DSL_DSL

    dsl_dsl do
      block :with_body
      atom :ptrn
      list :argv
      atom :desc
      list :expt
      atom :expt_desc
    end

    -> do
      fmt = "%-6s %-35s %-12s %s"
      define_method :does do
        ptrn = get_ptrn
        ptrn &&= "#{ ptrn })"
        ptrn ||= '<<no pattern>>'

        dsc = get_desc
        dsc ||= '<<no desc>>'

        arv = get_argv
        arv &&= "`#{ arv * ' ' }`"
        arv ||= '<<no argv>>'

        exp = get_expt_desc
        exp ||= get_expt
        exp ||= '<<no expt>>'

        fmt % [ ptrn, dsc, arv, exp ]
      end
    end.call

    let :client_class do
      kls = Sandbox.produce_subclass
      get_with_body or raise "sanity - `with_body { .. }` expected"
      kls.class_exec(& get_with_body )
      kls
    end

    def as sym, rx, modifier, strm=:err
      as = Whereby.new( sym, rx, modifier, strm ).freeze
      define_method "__as_#{ sym }" do as end
    end

    def memoize_output_lines &block
      did = res = nil
      define_method :output_lines do
        did or begin
          did = true
          instance_exec(& block )
          res = convert_whole_err_string_to_unstylized_lines
        end
        res
      end
    end
  end

  Whereby = ::Struct.new :sym, :rx, :modifier, :stream_name

  module InstanceMethods

    include CONSTANTS

    def invoke *argv
      argv.flatten! 1
      argv = argv.dup  # a) cli parsing is always descructive on ARGV, for
      client.run argv  # agnostic progressive chaining [#hl-056]
      # (note that in our tests we don't actually test that the argv is
      # getting mutated, and we probably shouldn't)
    end

    let :client do
      g = io_spy_group
      self.class.client_class.new out: g.outstream, err: g.errstream,
        program_name: program_name
    end

    -> do  # `program_name` - just to be cute, test for freak accidents
      pn = 'wtvr'.freeze
      define_method :program_name do pn end
    end.call

    let :io_spy_group do
      sg = Headless_TestSupport::CLI::IO_Spy_Group.new nil
      if do_debug
        sg.debug!
      end
      sg
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def expect * exp_a
      exp_a.flatten! 1
      expect_partial exp_a and
        expect_no_more_output
    end

    def expect_partial sym_a
      passed = true
      sym_a.each do |sym|
        expect_next_line_to_be sym or break( passed = false )
      end
      passed
    end

    def expect_next_line_to_be as_sym
      expect_line_to_be as_sym, true
    end

    -> do  # `expect_line_to_be`
      which_h = {
        styled: :expect_styled_line,
        nonstyled: :expect_nonstyled_line
      }
      define_method :expect_line_to_be do |as_sym, idx_ref=true|
        as = fetch_as as_sym
        meth = which_h.fetch as.modifier
        send meth, as.rx, idx_ref, as.stream_name
      end
    end.call

    def fetch_as as_sym
      send "__as_#{ as_sym }"
    end

    def as
      @as ||= method( :fetch_as )  # le sucre
    end

    def expect_line_at_index_to_be idx, as_sym  # (just for readability)
      expect_line_to_be as_sym, idx
    end

    def expect_styled_line rx, idx_ref=true, stream_name=:err
      line = expect_line idx_ref, stream_name
      if ! line then line else  # future-proof
        text = expect_styled line
        if ! text then text else
          expect_match text, rx
        end
      end
    end

    -> do  # `expect_styled`, `convert_whole_err_string_to_unstylized_lines`

      unstylize_stylized = Headless::CLI::Pen::FUN.unstylize_stylized

      define_method :expect_styled do |line|
        text = unstylize_stylized[ line ]
        if text then text else
          fail "line wasn't styled - #{ line.inspect }"
        end
      end

      define_method :convert_whole_err_string_to_unstylized_lines do
        x = whole_err_string
        str = unstylize_stylized[ x ]
        str.split "\n"
      end

    end.call

    def expect_match text, rx
      did_match = rx =~ text
      text.should match( rx )
      did_match  # (sorry, we are waiting for [#ts-009] test-failure exceptions)
    end

    def expect_line idx_ref, stream_name=:err
      if true == idx_ref
        lines.fetch( stream_name ).shift or
          fail "there was no more \"#{ stream_name }\" line."
      else
        lins = lines.fetch stream_name
        begin
          lins.fetch idx_ref
        rescue ::IndexError => e
          raise ::IndexError, "can't fetch \"#{ stream_name }\" line - #{ e }"
        end
      end
    end

    def expect_line_at_index idx
      stderr_lines.fetch idx
    end

    def stderr_lines
      lines.fetch :err
    end

    def stdout_lines
      lines.fetch :out
    end

    def stderr_gets
      lines.fetch( :err ).shift
    end

    def stdout_gets
      lines.fetch( :out ).shift
    end

    let :lines do
      # (the below noize is simply grinding up the stream spy and turning
      # it into two arrrays of lines.)
      isg = @__memoized.fetch :io_spy_group
      @__memoized[:io_spy_group] = nil  # careful - we are 'digesting' it
      o, e = [ :outstream, :errstream ].map do |x|
        str = isg[x].string
        isg[ x ] = nil
        str.split "\n"
      end
      { out: o, err: e }
    end

    let :whole_string do
      isg = io_spy_group
      { out: isg[:outstream].string, err: isg[:errstream].string }
    end

    let :whole_err_string do
      whole_string.fetch :err
    end

    -> do  # `expect_nonstyled_line`

      simple_style_rx = Headless::CLI::Pen::FUN.simple_style_rx

      define_method :expect_nonstyled_line do |rx, idx_ref=true, sn=:err|
        line = expect_line idx_ref, sn
        if ! line then line else  # future-proof
          simple_style_rx !~ line or fail "expected line *not* to be styled -#{
            }#{ line }"
          expect_match line, rx
        end
      end
    end.call

    def expect_no_more_output
      stderr_lines.length.should be_zero
      stdout_lines.length.should be_zero
    end
  end
end
