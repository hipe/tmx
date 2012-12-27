require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Node
  ::Skylab::TanMan::TestSupport::Models[ Node_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie



  module InstanceMethods

    let :controller do
      sexp = result or fail 'sanity - did parse fail?'
      cnt = TanMan::Models::Node::Collection.new :test_models_node_test_support,
        sexp
      cnt
    end

    def _input_fixtures_dir_path
      Node_TestSupport::Fixtures.dir_path
    end
  end
end
