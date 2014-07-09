require_relative '..'
require 'skylab/callback/core'

module Skylab::TreetopTools

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  RuntimeError = ::Class.new ::RuntimeError

  module Lib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    Basic__ = sidesys[ :Basic ]
    CLI = -> do
      Headless__[]::CLI
    end
    CodeMolester__ = sidesys[ :CodeMolester ]
    Const_pryer = -> do
      CodeMolester__[]::ConstPryer
    end
    Digraph = -> do
      Basic__[]::Digraph
    end
    Headless__ = sidesys[ :Headless ]
    Parameter = -> do
      Headless__[]::Parameter
    end
    SubClient = -> do
      Headless__[]::SubClient
    end
  end

  module Parser  # #stowaway
    Autoloader_[ self ]
  end

  class Parameter < Lib_::Parameter[]
    param :dir, boolean: true
    param :exist, enum: [:must], accessor: true

    public :[]                    # the Definer::I_M of this is private
    public :known?                # the Definer::I_M of this is private

    def pathname= x
      super x
      :dir == x and dir!
    end
  end

  TreetopTools_ = self

  # ([#su-001] none.)
end
