require_relative '..'
require 'skylab/callback/core'

module Skylab::TreetopTools

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  RuntimeError = ::Class.new ::RuntimeError

  def self.lib_
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  end

  module Lib_

    memoize = -> p { p_ = -> { x = p[] ; p_ = -> { x } ; x } ; -> { p_[] } }

    sidesys = Autoloader_.build_require_sidesystem_proc

    Bsc__ = sidesys[ :Basic ]

    Basic_fields = -> * x_a do
      MH__[]::Basic_Fields.call_via_iambic x_a
    end

    Bzn__ = sidesys[ :Brazen ]

    CLI = -> do
      HL__[]::CLI
    end

    CodeMolester__ = sidesys[ :CodeMolester ]

    Digraph = -> do
      Bsc__[]::Digraph
    end

    File_utils = memoize[ -> { require 'fileutils' ; ::FileUtils } ]

    HL__ = sidesys[ :Headless ]

    List_scanner = -> x do
      Callback_::Scn.try_convert x
    end

    MH__ = sidesys[ :MetaHell ]

    Parameter = -> do
      HL__[]::Parameter
    end

    Strange_proc = -> do
      MH__[].strange.to_proc
    end

    String_scanner = memoize[ -> { require 'strscan' ; ::StringScanner } ]

    Sub_client = -> do
      HL__[]::SubClient
    end

    System = -> do
      HL__[].system
    end

    Treetop = memoize[ -> do
      # Autoloader_.require_quietly 'treetop'
      require 'treetop' ; ::Treetop
    end ]
  end

  LIB_ = lib_

  module Parser  # #stowaway
    Autoloader_[ self ]
  end

  class Parameter < LIB_.parameter
    param :dir, boolean: true
    param :exist, enum: [:must], accessor: true

    public :[]                    # the Definer::I_M of this is private
    public :known?                # the Definer::I_M of this is private

    def pathname= x
      super x
      :dir == x and dir!
    end
  end

  PROCEDE_ = true
  TreetopTools_ = self
  UNABLE_ = false

  # ([#su-001] none.)
end
