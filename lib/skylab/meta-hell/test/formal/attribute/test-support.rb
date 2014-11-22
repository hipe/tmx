require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Formal::Attribute

  ::Skylab::MetaHell::TestSupport::Formal[ TS_ = self ]

  include Constants

  MetaHell_ = MetaHell_

  Formal_TS_ = Formal_TS_

  MetaHell_._lib.stdlib_set

  extend TestSupport_::Quickie

  module Methods

    include Constants

    def one_such_class & p
      _const_i = :"KLS_#{ Formal_TS_.next_id }"
      _cls = TS_.const_set _const_i, ::Class.new
      _cls.class_exec do
        MetaHell_::Formal::Attribute::DSL[ self ]
        class_exec( & p )
        self
      end
    end
  end

  module ModuleMethods
    include Methods
  end

  module InstanceMethods
    include Methods
  end
end
