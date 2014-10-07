require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Formal::Attribute

  ::Skylab::MetaHell::TestSupport::Formal[ TS_ = self ]

  include CONSTANTS

  MetaHell_ = MetaHell_

  extend TestSupport_::Quickie

  module Methods
    include CONSTANTS
    define_method :one_such_class do |&block|
      kls = TS_.const_set "KLS_#{ FUN.next_id[] }", ::Class.new
      kls.class_eval do
        MetaHell_::Formal::Attribute::DSL[ self ]
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
