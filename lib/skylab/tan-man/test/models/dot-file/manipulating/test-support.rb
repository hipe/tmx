require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Manipulating

  ::Skylab::TanMan::TestSupport::Models::DotFile[ self ]

  module InstanceMethods

    let :controller do
      sexp = result or fail 'sanity - parse failure?'

      # we give it a "null request client" below -- should be ok!
      # haha "should" as in "shoulda"

      cnt = TanMan_::Models::Node::Collection.new :test_models_dotfile_manipulus,
        sexp
      cnt
    end
  end
end
