require_relative '../test-support'

module Skylab::Face::TestSupport::CLI::Client

  ::Skylab::Face::TestSupport::CLI[ TS__ = self, :flight_of_stairs ]

  TestLib_ = ::Module.new

  module Constants
    CLI_Client_TS_ = TS__
    TestLib_.include self::TestLib_
    TestLib_ = TestLib_
  end

  include Constants

  Sandbox = ::Module.new

  TestSupport_ = TestSupport_

  TestSupport_::Sandbox.enhance( Sandbox ).
    produce_subclasses_of -> { Face_::CLI::Client }

  Face_ = Face_

  extend TestSupport_::Quickie

  def self.bundles_class
    Bundles__
  end

  class Bundles__ < parent_anchor_module.bundles_class
    def CLI_sandbox=
      send :CLI_party=
      @child.const_set :Sandbox, ::Module.new
      @child::Constants.const_set :Sandbox, @child::Sandbox
    end
    def CLI_party=
      @child.const_set :Face_, Face_
      @child.const_set :TS__, @child
      @child.include @parent::Constants
      @child.extend TestSupport_::Quickie
    end
  end

  module TestLib_

    CLI_lib = -> do
      HL__[]::CLI
    end

    DSL_DSL = -> x, p do
      Parse_lib___[]::DSL_DSL.enhance_module x, & p
    end

    HL__ = Face_::Lib_::HL__

    Parse_lib___ = Face_::Lib_::Parse_lib

    Sout_serr = -> do
      sys = LIB_.system_IO
      [ sys.some_stderr_IO, sys.some_stderr_IO ]
    end
  end

  TestLib_::DSL_DSL[ self, -> do
    block :with_body
    atom :ptrn
    list :argv
    atom :desc
    list :expt
    atom :expt_desc
  end ]

  module ModuleMethods

    include Constants

    -> do
      fmt = "%-6s %-35s %-12s %s"
      define_method :does do
        ptrn = ptrn_value
        ptrn &&= "#{ ptrn })"
        ptrn ||= '<<no pattern>>'

        dsc = desc_value
        dsc ||= '<<no desc>>'

        arv = argv_value
        arv &&= "`#{ arv * ' ' }`"
        arv ||= '<<no argv>>'

        exp = expt_desc_value
        exp ||= expt_value
        exp ||= '<<no expt>>'

        fmt % [ ptrn, dsc, arv, exp ]
      end
    end.call

    define_singleton_method :let, TestSupport_::Let::LET_METHOD

    let :client_class do
      kls = Sandbox.produce_subclass
      with_body_value or raise "sanity - `client_class` or `with_body { .. }` expected"
      kls.class_exec( & with_body_value )
      kls
    end

    define_method :__memoized, TestSupport_::Let::MEMOIZED_METHOD
      # for memoizing **into** the test context **class**

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
          res = convert_whole_err_string_to_unstyled_lines
        end
        res
      end
    end
  end

  Whereby = ::Struct.new :sym, :rx, :modifier, :stream_symbol

  module InstanceMethods

    include Constants

    def invoke *argv
      argv.flatten! 1
      argv = argv.dup  # a) cli parsing is always descructive on ARGV, for
      client.invoke argv  # agnostic progressive chaining [#hl-056]
      # (note that in our tests we don't actually test that the argv is
      # getting mutated, and we probably shouldn't)
    end

    let :client do
      t = io_spy_triad
      client_class.new sin: t.instream, out: t.outstream, err: t.errstream,
        program_name: program_name
    end

    def client_class
      self.class.client_class
    end

    -> do  # `program_name` - just to be cute, test for freak accidents
      pn = 'wtvr'.freeze
      define_method :program_name do pn end
    end.call

    let :io_spy_triad do
      t = TestSupport_::IO.spy.triad nil  # making a fake stdin is on u
      if do_debug
        t.debug!
      end
      t
    end

    def only_line
      a = info_lines
      1 == a.length or
        fail "expected 1 had #{ a.length } lines (#{ a[ 1 ].inspect })"
      a.shift
    end

    def line
      info_lines.shift or fail "expected at least one more line, had none"
    end

    def there_should_be_no_lines
      info_lines.length.zero? or fail "expected no lines had #{ info_lines[0]}"
    end

    def build_info_lines
      io = @infostream ; @infostream = :spent
      io.string.split "\n"
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
        send meth, as.rx, idx_ref, as.stream_symbol
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

    def expect_styled_line rx, idx_ref=true, stream_symbol=:err
      line = expect_line idx_ref, stream_symbol
      if ! line then line else  # future-proof
        text = expect_styled line
        if ! text then text else
          expect_match text, rx
        end
      end
    end

    styling = Face_.lib_.brazen::CLI::Styling

    define_method :unstyle, styling::Unstyle

    define_method :unstyle_styled, styling::Unstyle_styled

    def expect_styled line
      text = unstyle_styled line
      if text then text else
        fail "line wasn't styled - #{ line.inspect }"
      end
    end

    def convert_whole_err_string_to_unstyled_lines
      x = whole_err_string
      str = unstyle_styled x
      str.split "\n"
    end

    def expect_match text, rx
      did_match = rx =~ text
      text.should match( rx )
      did_match  # (sorry, we are waiting for [#ts-009] test-failure exceptions)
    end

    def expect_line idx_ref, stream_symbol=:err
      if true == idx_ref
        lines.fetch( stream_symbol ).shift or
          fail "there was no more \"#{ stream_symbol }\" line."
      else
        lins = lines.fetch stream_symbol
        begin
          lins.fetch idx_ref
        rescue ::IndexError => e
          raise ::IndexError, "can't fetch \"#{ stream_symbol }\" line - #{ e }"
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

      isg = __memoized.fetch :io_spy_triad  # `memoized_`, but r.s compat

      __memoized[ :io_spy_triad ] = nil  # careful - we are 'digesting' it

      o, e = [ :outstream, :errstream ].map do |x|
        str = isg[x].string
        isg[ x ] = nil
        str.split "\n"
      end
      { out: o, err: e }
    end

    let :whole_string do
      t = io_spy_triad
      { out: t[:outstream].string, err: t[:errstream].string }
    end

    let :whole_err_string do
      whole_string.fetch :err
    end

    -> do  # `expect_nonstyled_line`

      simple_style_rx = Face_.lib_.brazen::CLI::Styling::SIMPLE_STYLE_RX

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

    def shift_until_after a, f
      found = false ; count = 0
      while a.length.nonzero?
        count += 1
        if f[ a.shift ]
          break( found = true )
        end
      end
      if ! found
        fail "found no lines matching the function in #{ count } lines."
      end
    end
  end

  Constants::Do_invoke_ = -> do
    if (( idx = ( argv = ::ARGV ).index '-x' ))
      argv[ idx ] = nil ; argv.compact!
      TestSupport_::Quickie.do_not_invoke!
      true
    end
  end
end
