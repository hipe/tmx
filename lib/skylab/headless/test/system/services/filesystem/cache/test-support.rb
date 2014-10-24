require_relative '../test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem::Cache

  ::Skylab::Headless::TestSupport::System::Services::Filesystem[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  Headless_ = Headless_

  module InstanceMethods

    def subject
      Subject_[]
    end
  end

  Subject_ = -> *a do
    if a.length.zero?
      Headless_.system.filesystem.cache
    else
      _p = Headless_.system.filesystem.cache.cache_pathname_proc_via_module( * a )
      a.first.define_singleton_method :cache_pathname, _p
      nil
    end
  end

  Woo_Wee_PATHNAME = TS_.tmpdir_pathname.join 'woo-wee'
end
