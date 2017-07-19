require 'skylab/myterm'
require 'skylab/test_support'

module Skylab::MyTerm::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

  class << self
    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include Instance_Methods___
    end
  end  # >>

  # -

    Use_method___ = -> sym do
      TS_.__lib( sym )[ self ]
    end

  # -

  module Instance_Methods___  # re-opens below

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  class << self

    h = {}
    define_method :__lib do | sym |

      h.fetch sym do

        s = sym.id2name
        const = "#{ s[ 0 ].upcase }#{ s[ 1..-1 ] }".intern

        x = if TS_.const_defined? const, false
          TS_.const_get const, false
        else
          TestSupport_.fancy_lookup sym, TS_
        end
        h[ sym ] = x
        x
      end
    end
  end  # >>

  # --

  module My_Interactive_CLI

    def self.[] tcc

      TestSupport_::Memoization_and_subject_sharing[ tcc ]
      _ = Zerk_test_support_[].lib :expect_screens
      _[ tcc ]
      tcc.include self
    end

    def prepare_CLI_for_expect_screens cli, fc, sc

      # (if set, the last two above are from the `given` DSL)

      if ! fc
        fc = filesystem_conduit_for_iCLI_
      end

      if ! sc
        sc = system_conduit_for_iCLI_
      end

      cli.filesystem_conduit = fc  # nil means assert none used
      cli.system_conduit = sc  # nil means assert none used

      NIL_
    end

    def filesystem_conduit_for_iCLI_
      _OCD_filesystem_SINGLETON_
    end

    def system_conduit_for_iCLI_
      NOTHING_
    end

    def build_interactive_CLI_classeque
      Home_::CLI::Interactive.build_classesque__
    end
  end

  # --

  module My_API

    def self.[] tcc
      @_ ||= Zerk_test_support_[].lib :API
      @_[ tcc ]
      tcc.include self
    end

    def zerk_API_call oes_p, x_a  # #spot-2
      @root_ACS = build_root_ACS_for_testing_
      Home_::Call_.call( x_a, @root_ACS ) { |_| oes_p }
    end
  end

  # --

  module Instance_Methods___

    def build_root_ACS_for_testing_

      # read [#010] and come back. this is how we satisfy our OCD.

      acs = Home_.build_root_ACS_

      kernel = acs.kernel_

      inst = kernel.silo :Installation

      inst.system_conduit = false  # never use real system conduit by default
      # ACTUALLY - *do* use real system conduit (..

      inst.filesystem = _OCD_filesystem_SINGLETON_

      acs
    end

    yes = true ; x = nil
    define_method :_OCD_filesystem_SINGLETON_ do
      if yes
        yes = false
        x = OCD_Filesystem_Conduit___.new ::File, ::Dir
      end
      x
    end
  end

  # ==

  class OCD_Filesystem_Conduit___

    # satisfy the "OCD" described in [#010] by having this be long-running
    # (as in forever) and cache the filesystem hits. as we said, OCD

    def initialize file_guy, dir_guy
      @__upstream_dirsystem = dir_guy
      @_upstream_filesystem = file_guy
      @_globs = {}
    end

    def glob path
      @_globs.fetch path do
        x = @__upstream_dirsystem.glob path
        @_globs[ path ] = x
        x
      end
    end
  end

  # ==

  Zerk_test_support_ = -> do
    Home_.lib_.zerk.test_support
  end

  Common_ = ::Skylab::Common

  Autoloader__ = Common_::Autoloader

  module Stubs
    Autoloader__[ self ]
  end

  Autoloader__[ self, ::File.dirname( __FILE__ ) ]

  Home_ = ::Skylab::MyTerm

  COMMON_ADAPTER_CONST_ = :Imagemagick
  EMPTY_S_ = Home_::EMPTY_S_
  Lazy_ = Common_::Lazy
  NIL_ = nil
  NONE_ = nil
  NOTHING_ = nil
  SPACE_ = ' '
  TS_ = self
end
