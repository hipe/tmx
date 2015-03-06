module Skylab::SubTree

  module API

    Brazen_ = SubTree_.lib_.brazen

    SubTree_::Action_ = Brazen_.model.action_class

    extend Brazen_::API.module_methods

    Kernel = ::Class.new Brazen_::Kernel_  # not settled yet

    SubTree_::Kernel_ = Kernel

  end
end
