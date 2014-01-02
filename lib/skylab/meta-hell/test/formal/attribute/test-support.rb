require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Attribute

  ::Skylab::MetaHell::TestSupport::Formal[ TS__ = self ]

  include CONSTANTS

  MetaHell = MetaHell

  extend TestSupport::Quickie

  module Methods
    include CONSTANTS
    define_method :one_such_class do |&block|
      kls = TS__.const_set "KLS_#{ FUN.next_id[] }", ::Class.new
      kls.class_eval do
        extend MetaHell::Formal::Attribute::Definer
        class_exec(& block )
      end
      kls
    end
  end

  module ModuleMethods
    include Methods
  end

  module InstanceMethods
    include Methods
  end
end
