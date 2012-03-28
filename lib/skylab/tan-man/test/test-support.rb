require 'skylab/test-support/test-support'
require 'skylab/test-support/tmpdir'
require 'shellwords'


module Skylab::TanMan::TestSupport
  TanMan = Skylab::TanMan
  include Skylab::TestSupport
  TMPDIR = Tmpdir.new(Skylab::ROOT.join('tmp/tanman'))

  # this is dodgy but should be ok as long as you accept that:
  # 1) you are assuming meta-attributes work and 2) the below is universe-wide!
  # 3) the below presents holes that need to be tested manually
  TanMan::Api.tap do |c|
    c.local_conf_dirname = 'local-conf.d' # a more visible name
    c.local_conf_maxdepth = 1
    c.local_conf_startpath = ->(){ TMPDIR }
    c.global_conf_path = ->() { TMPDIR.join('global-conf-file') } # a more visible name
  end
  def api
    TanMan.api
  end
  def lone_error ee, regex
    ee.size.should eql(1)
    ee.should_not be_success
    ee.first.message.should match(regex)
  end
  def lone_success ee, regex
    ee.size.should eql(1)
    ee.should be_success
    ee.first.message.should match(regex)
  end
  def prepare_local_conf_dir
    TMPDIR.prepare.mkdir(TanMan::Api.local_conf_dirname)
  end
  attr_accessor :result
end

RSpec::Matchers.define(:be_trueish) { match { |actual| actual } }

RSpec::Matchers.define(:be_gte) { |expected| match { |actual| actual >= expected } }

