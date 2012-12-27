require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::Association
  ::Skylab::TanMan::TestSupport::Models[ Association_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie



  module InstanceMethods

    let :controller do
      sexp = result or fail 'sanity - did parse fail?'
      request_client = TanMan::CLI::Client.new :nein, :nein, :nein # for pen :/
      dfc = TanMan::Models::DotFile::Controller.new request_client, 'xyzzy.dot'
      dfc.define_singleton_method :sexp do sexp end # eek
      cnt = TanMan::Models::Association::Collection.new dfc, sexp
      cnt
    end

    def _input_fixtures_dir_path
      Association_TestSupport::Fixtures.dir_path
    end

    def lines
      result.unparse.split "\n"
    end
  end
end
