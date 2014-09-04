require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models

  ::Skylab::TanMan::TestSupport[ self ]

  module InstanceMethods

    let :controller do
      sexp = result or fail 'sanity - did parse fail?'
      request_client = TanMan_::CLI::Client.new :nein, :nein, :nein # for pen :/
      dfc = TanMan_::Models::DotFile::Controller.new request_client, 'xyzzy.dot'
      dfc.define_singleton_method :sexp do sexp end # eek
      cnt = collection_class.new dfc, sexp
      cnt
    end
  end
end
