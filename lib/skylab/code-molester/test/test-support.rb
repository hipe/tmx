require File.expand_path('../../..', __FILE__)
require 'skylab/slake/test/support'

module ::Skylab
  module CodeMolester
  end
end

module ::Skylab::CodeMolester::TestSupport
  TMPDIR = ::Skylab::ROOT.join('tmp')
end

