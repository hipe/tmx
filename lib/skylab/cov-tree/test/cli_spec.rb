require_relative 'test-support'

describe "#{ ::Skylab::CovTree }" do
  extend ::Skylab::CovTree::TestSupport

  acts_rx = /\{tree\|rerun\}/
  actions = acts_rx.source
  expecting_rx_ = /\AExpecting #{ actions }\.\z/ # look!
  expecting_rx  = /\AExpecting #{ actions }\z/
  invite_rx = /\ATry cov-tree -h for help\.\z/

  it "0   : no args        : expecting / invite" do
    args
    line.should match( expecting_rx_ )
    line.should match( invite_rx )
    stack.should be_empty
    types.should eql([:runtime_issue, :ui])
    result.should eql(nil)
  end

  it "1.1 : one unrec arg  : msg / expecting / invite" do
    args 'borf'
    line.should match( /\AInvalid action: borf\z/ )
    line.should match( expecting_rx )
    line.should match( invite_rx )
    stack.should be_empty
    types.should eql([:runtime_issue, :runtime_issue, :ui])
    result.should eql(false)
  end

  it "1.2 : one unrec opt  : expecting / invite" do
    args '-z'
    line.should match( expecting_rx_ )
    line.should match( invite_rx )
    stack.should be_empty
    types.should eql([:runtime_issue, :ui])
    result.should eql(nil)
  end

  usage_rx = /\Ausage: cov-tree #{ actions } \[opts\] \[args\]\z/

  it "1.3 : one opt : `-h` : usage / invite" do
    args '-h'
    line.should match( usage_rx )
    line.should match(
      /\AFor help on a particular subcommand, try cov-tree <subcommand> -h\.\z/
    )
    stack.should be_empty
    types.should eql([:ui, :ui])
    result.should eql(1) # #wat #todo
  end

  it "2.1 : `-h unrec`     : msg invite" do
    args '-h', 'wat'
    line.should match(/\ANo such action "wat"\.  #{
      }Try cov-tree help #{ actions } -h\.\z/)
    stack.should be_empty
    types.should eql([:error])
    result.should eql(1) # #wat #todo
  end

  it "2.2 : `-h rec`       : 1) usage 2) desc 3) opts" do
    args '-h', 'tree'
    line.should match(/\Ausage: cov-tree tree/)
    line.should match(/\Adescription:\z/i)
    line.should match(/\Asee crude/i)
    line.should match(/\A  \*/)
    line.should match(/\A  \*/)
    line.should match(/\AUsage: rspec/) # wat
    line.should match(/\Aoptions:\z/i)
    l = line
    loop do
      l.should match(/\A  /)
      l = line or break
    end
    types.uniq.should eql([:usage, :help])
    result.should be_kind_of(::Array) # #wat
  end

  it "2.3 : `-h rec more`  : msg / usage / invite" do
    args '-h', 'tree', 'wat'
    line.should eql('unexpected argument: "wat"')
    line.should match( /\Ausage: cov-tree help \[<action>\]\z/ )
    line.should match( /\ATry cov-tree help -h for help\.\z/ ) # wat
    stack.should be_empty
    types.should eql([:syntax, :runtime_issue, :ui])
    result.should eql(false)
  end
end
