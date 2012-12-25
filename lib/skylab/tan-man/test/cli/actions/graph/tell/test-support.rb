require_relative '../test-support'


module Skylab::TanMan::TestSupport::CLI::Actions::Graph::Tell
  ::Skylab::TanMan::TestSupport::CLI::Actions::Graph[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module InstanceMethods

    def tell *words               # centralize and encapsulate this especially!!
      c = client
      cd dotfile_pathname.dirname do
        c.invoke [ 'graph', 'tell', *words ]
      end
      nil
    end
  end
end
