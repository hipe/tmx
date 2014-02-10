require_relative '../core'

module Skylab::Face::TestSupport

  TestLib_ = ::Module.new

  module CONSTANTS
    Face = ::Skylab::Face
    TestSupport = Face::Autoloader_.require_sidesystem :TestSupport
    TestLib_ = TestLib_
  end

  include CONSTANTS

  Face = Face ; TestSupport = TestSupport

  TestSupport::Regret[ self ]

  stowaway :CLI, 'cli/test-support'  # [#mh-030] for [#045]

  TestSupport::Sandbox::Host[ self ]

  module TestLib_

    sidesys = Face::Autoloader_.method :build_require_sidesystem_proc

    CLI_simple_style_rx = -> do
      Headless__[]::CLI::Pen::SIMPLE_STYLE_RX
    end

    CLI_unstyle_proc = -> do
      Headless__[]::CLI::Pen::FUN.unstyle
    end

    CLI_unstyle_styled_proc = -> do
      Headless__[]::CLI::Pen::FUN::Unstyle_styled
    end

    DSL_DSL = -> x, p do
      MetaHell__[]::DSL_DSL.enhance_module x, & p
    end

    Headless__ = sidesys[ :Headless ]

    Let = -> mod do
      mod.extend MetaHell__[]::Let
    end

    MetaHell__ = sidesys[ :MetaHell ]

    Sandboxify = -> test_node do
      Sandboxify_.new( test_node ).sandboxify
    end

    Sout_serr = -> do
      sys = Face::Lib_::System_IO[]
      [ sys.some_stderr_IO, sys.some_stderr_IO ]
    end
  end

  CONSTANTS::Common_setup_ = -> do  # ..
    common = -> do
      include self::CONSTANTS
      extend TestSupport::Quickie
      self::Face = Face
    end
    h = {
      sandbox: -> do
        module self::Sandbox
        end
        self::CONSTANTS::Sandbox = self::Sandbox
      end,
      sandboxer: -> do
        self::Sandboxer = self::TestSupport::Sandbox::Spawner.new
      end
    }.freeze
    -> mod, *i_a do
      mod.module_exec( & common )
      while i_a.length.nonzero?
        i = i_a.shift
        mod.module_exec( & h.fetch( i ) )
      end
      nil
    end
  end.call

  class Sandboxify_  # can probably replace part of above
    def initialize tn
      @test_node = tn
    end
    def sandboxify
      @test_node.const_set :TS_, @test_node
      s_a = @test_node.name.split DCOLON__
      s_a.pop
      parent_test_node = s_a.reduce ::Object do |m, s|
        m.const_get s, false
      end
      parent_test_node[ @test_node ]
      @test_node.include @test_node.const_get( :CONSTANTS, false )
      @test_node.const_set :Face, Face
      @test_node.const_set :Sandbox, Face::Autoloader_[ ::Module.new ]
      @test_node::Sandbox.dir_pathname
      @test_node::CONSTANTS.const_set :Sandbox, @test_node::Sandbox
      @test_node.extend TestSupport::Quickie ; nil
    end
    DCOLON__ = '::'.freeze
  end

  module InstanceMethods

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

    def info_lines
      @info_lines ||= begin
        io = @infostream ; @infostream = :spent
        io.string.split "\n"
      end
    end

    def infostream
      @infostream ||= begin
        io = TestSupport::IO::Spy.standard
        do_debug and io.debug! 'info >>> '
        io
      end
    end
  end
end
