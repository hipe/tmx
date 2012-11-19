require_relative '..'
require 'skylab/face/core' # MyPathname
require 'skylab/headless/core'


module Skylab::TreetopTools
  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive

  Headless = ::Skylab::Headless
  const_get :Grammar, false       # ick load this now so we can say 'Grammar'


  class Pathname < ::Skylab::Face::MyPathname # future-proofed to this
  end


  class RuntimeError < ::RuntimeError
  end


  class Parameter < Headless::Parameter::Definition
    param :dir, boolean: true
    param :exist, enum: [:must], accessor: true

    public :[]                    # the Definer::I_M of this is protected
    public :known?                # the Definer::I_M of this is protected

    def pathname= x
      super x
      :dir == x and dir!
    end
  end
end
