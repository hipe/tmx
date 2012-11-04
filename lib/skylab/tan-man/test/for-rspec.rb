require 'shellwords'

module Skylab::TanMan::TestSupport
  shared_context tanman: true do
  include ::Skylab::TanMan::TestSupport::Tmpdir_InstanceMethods
  def api
    TanMan.api
  end
  let :cli do
    spy = output
    TanMan::CLI.new do |o|
      o.program_name = 'ferp'
      o.stdout = spy.for(:stdout)
      o.stderr = spy.for(:stderr)
      o.on_info { |x| o.stderr.puts x.touch!.message } # similar but not same to default
      o.on_out  { |x| o.stdout.puts x.touch!.message }
      o.on_all  { |x| o.stderr.puts(x.touch!.message) unless x.touched? }
    end
  end
  def input str
    argv = Shellwords.split(str)
    self.result = cli.invoke argv
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
  attr_accessor :result
  let(:output) { StreamsSpy.new }
  def output_shift_is *assertions
    subject = output.first
    assertions.each do |assertion|
      case assertion
      when FalseClass ; result.should_not be_trueish
      when Regexp     ; subject.string.should match(assertion)
      when String     ; subject.string.should be_include(assertion)
      when Symbol     ; subject.name.should eql(assertion)
      when TrueClass  ; result.should be_trueish
      else            ; fail("unrecognized assertion class: #{assertion}")
      end
    end
    output.shift # return subject, and change the stack only at the end
  end
  def output_shift_only_is *assertions
    res = output_shift_is(*assertions)
    output.size.should eql(0)
    res
  end
  def prepare_local_conf_dir
    prepare_submodule_tmpdir.mkdir(TanMan::API.local_conf_dirname)
  end
  attr_accessor :result
  end
end

RSpec::Matchers.define(:be_trueish) { match { |actual| actual } }

RSpec::Matchers.define(:be_gte) { |expected| match { |actual| actual >= expected } }
