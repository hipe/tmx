module Skylab::Treemap
  module Plugins::R::API::Actions
    extend MetaHell::Boxxy        # HAVE YOU HEARD OF BOXXY
  end

  class Plugins::R::API::Action
    extend Headless::Action::ModuleMethods
    include Headless::Action::InstanceMethods
    ACTIONS_ANCHOR_MODULE = Plugins::R::API::Actions
  end
end
