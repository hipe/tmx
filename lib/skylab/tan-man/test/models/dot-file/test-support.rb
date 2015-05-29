require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  class << self

    def client_class

      if ! TS_.const_defined?( :Client, false )
        load ::File.join( TS_.dir_pathname.to_path, 'client' )  # because new a.l borks because no extname. meh
      end
      TS_::Client
    end
  end  # >>

  module InstanceMethods

    def prepare_to_produce_result
      @parse = TS_.client_class.new
      true
    end
  end

  Callback_ = Callback_
  TanMan_ = TanMan_
end
