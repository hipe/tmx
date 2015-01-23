require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile

  ::Skylab::TanMan::TestSupport::Models[ TS_ = self ]

  include Constants

  TanMan_ = TanMan_

  module InstanceMethods

    def prepare_to_produce_result

      if ! TS_.const_defined?( :Client, false )
        load ::File.join( TS_.dir_pathname.to_path, 'client' )  # because new a.l borks because no extname. meh
      end

      @parse = TS_::Client.new
      true
    end
  end
end
