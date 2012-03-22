require File.expand_path('../../cli', __FILE__)
require File.expand_path('../test-support', __FILE__)

module Skylab::TanMan::TestSupport
  TanMan = Skylab::TanMan
  describe TanMan do
    include TanMan::TestSupport # let(:input)
    let (:cli) do
      cli_class.new do |o|
        o.stdout = OutstreamSpy.new(_output, debug)
        o.on_all { |e| _output.push(e) ; debug and $stderr.puts(e) }
      end
    end
    let (:cli_class) { TanMan::Cli }
    let (:_output) { [ ] }

    context 'Remotes' do
      before do
        self.debug = false
        TMPDIR.verbose!.prepare
        TanMan::Api.global_conf_path { TMPDIR.join('tanrc') }
      end
      it 'can get added' do
        input 'remote add bing bong'
        output.grep(%r{^creating .+/tmp/tanman/tanrc}).size.should be_gte(1)
        output.grep(%r{^updating .+/tmp/tanman/tanrc}).size.should be_gte(1)
        result.should be_trueish
      end
      context 'can get listed' do
        it 'when none' do
          input 'remote list'
          output.grep(/\(empty\)/).size.should eql(1)
        end
        it 'when some' do
          input 'remote add nerp derp'
          _output.clear
          input 'remote list'
          output.should eql(['nerp  derp'])
        end
      end
      it 'get removed' do
        input 'remote add foo bar'
        _output.clear
        input 'remote list'
        output.should eql(['foo  bar'])
        input 'remote rm foo'
        output.grep(/removed remote foo./).size.should eql(1)
      end
    end
  end
end

