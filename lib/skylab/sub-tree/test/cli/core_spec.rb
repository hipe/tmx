require_relative 'test-support'

describe "#{ ::Skylab::SubTree } CLI" do

  ts = ::Skylab::SubTree::TestSupport

  extend ts::CLI

  _PN = ts::CLI::CONSTANTS::PN_

  acts_rx = /\{ping.+rerun\}/
  actions = acts_rx.source
  expecting_rx_ = /\AExpecting #{ actions }\.\z/i # look!
  expecting_rx  = /\AExpecting #{ actions }\z/i
  usage_rx = /\AUsage: #{ _PN } #{ actions } \[opts\] \[args\]\z/i
  invite_rx = /\ATry #{ _PN } -h for help\.\z/

  it "0   : no args        : expecting / invite" do
    argv
    line.should match( expecting_rx_ )
    line.should match( usage_rx )
    line.should match( invite_rx )
    emission_a.should be_empty
    names.should eql( [ :usage_issue, :usage, :ui ] )
    result.should eql( 1 )  # old-school exit code
  end

  it "1.1 : one unrec arg  : msg / expecting / invite" do
    argv 'borf'
    line.should match( /\Ainvalid action: borf\z/i )
    line.should match( expecting_rx )
    line.should match( invite_rx )
    emission_a.should be_empty
    names.should eql( [ :usage_issue, :usage_issue, :ui ] )
    result.should eql( 1 )  # old-school exit code
  end

  it "1.2 : one unrec opt  : expecting / invite" do
    argv '-z'
    line.should match( /\Ainvalid action: -z\z/i )
    line.should match( expecting_rx )
    line.should match( invite_rx )
    emission_a.should be_empty
    names.should eql( [ :usage_issue, :usage_issue, :ui ] )
    result.should eql( 1 )
  end

  it "1.3 : one opt : `-h` : usage / invite" do
    argv '-h'
    line.should match( usage_rx )
    line.should match( /^$/ )
    line.should match(
    /\AFor help on a particular subcommand, try #{ _PN } <subcommand> -h\.\z/i
    )
    emission_a.should be_empty
    names.detect{ |x| :help != x }.should be_nil
    result.should eql( 0 )
  end

  it "2.1 : `-h unrec`     : msg invite" do
    argv '-h', 'wat'
    line.should match( /\Ainvalid action: wat\z/i )
    line.should match( expecting_rx )
    line.should match( invite_rx )
    emission_a.should be_empty
    names.should eql( [:usage_issue, :usage_issue, :ui] )
    result.should eql( 1 )
  end

  _CMD = 'cov'

  it "2.2 : `-h rec`       : 1) usage 2) desc 3) opts" do
    argv '-h', _CMD
    line.should match(/\Ausage: #{ _PN } #{ _CMD }/i)
    line.should match( /^$/ )
    line.should match(/\Adescription:?\z/i)
    line.should match(/\A *see crude/i)
    line.should match(/\A +\*/)
    line.should match(/\A +\*/)
    line.should match( /^$/ )
    line.should match(/\Aoptions:?\z/i)
    l = line
    loop do
      l.should match(/\A  /)
      l = line or break
    end
    names.uniq.should eql( [ :help ] )
    result.should eql( 0 )
  end

  it "2.3 : `-h rec more`  : msg / usage / invite" do
    argv '-h', _CMD, 'wat'
    line.should match( /\bignoring: "wat"/ )
    line.should match( /\Ausage: #{ _PN } / )
    # ..meh
    names.uniq.should eql( [ :info, :help ] )
    result.should eql( 0 )
  end
end
