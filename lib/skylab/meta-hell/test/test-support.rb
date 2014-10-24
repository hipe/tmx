require_relative '../core'
require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport

  ::Skylab::TestSupport::Regret[ self ]
  ::Skylab::TestSupport::Quickie.enable_kernel_describe

  module Constants
    MetaHell_ = ::Skylab::MetaHell
      Callback_ =  MetaHell_::Callback_
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  Callback_ = Callback_
  MetaHell_ = MetaHell_

  module ModuleMethods
    include Constants
    def memoize name_i, p
      define_method name_i, MetaHell_::Callback_.memoize( p ) ; nil
    end
  end

  module InstanceMethods
    include Constants
    extend MetaHell_::Let

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    let :o do
      klass.new
    end
  end
end
