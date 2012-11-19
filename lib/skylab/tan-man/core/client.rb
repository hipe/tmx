module Skylab::TanMan
  module Core::Client
  end


  module Core::Client::ModuleMethods
    include PubSub::Emitter::ModuleMethods
  end


  module Core::Client::InstanceMethods
    extend MetaHell::Let          # we define things as memoized here

    extend PubSub::Emitter        # we want the instance methods this creates

    emits :all, out: :all, info: :all
                                  # #todo eventually make this PIE [#037]
                                  # note that clients will add their own events


  protected
    let( :core_runtime ) { Core::Runtime.get }
  end
end
