require File.expand_path('../../cli', __FILE__)
require File.expand_path('../test-support', __FILE__)
require 'skylab/porcelain/tite-color'

module Skylab::TanMan::TestSupport
  describe TanMan do
    include TanMan::TestSupport # prepare_local_conf_dir
    # alpha order. avoid early abstraction.
    let :cli do
      spy = output
      TanMan::Cli.new do |o|
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
    attr_accessor :result
    context 'Remotes' do
      before do
        TMPDIR.prepare
      end
      context 'when there is no local config directory' do
        it 'cannot get added, whines about no directory' do
          input 'remote add bing bong'
          output_shift_is(:stderr,
            "ferp failed to add remote: couldn't find local-conf.d in this or any parent directory"
          )
          output_shift_only_is(:stderr, 'try ferp init [-n] [<path>] to create it', false)
        end
        it 'cannot get listed, whines the same' do
          input 'remote list'
          output_shift_is(:stderr,
            "ferp failed to list remote: couldn't find local-conf.d in this or any parent directory"
          )
          output_shift_only_is(:stderr, false) # invite
        end
      end
      context 'when there is a local config directory' do
        before do
          prepare_local_conf_dir
        end
        it 'you can add a local remote' do
          input 'remote add bing bong'
          output_shift_only_is :stdout, %r{^creating .+/tmp/tanman/local-conf\.d.+\d\d bytes\.}, true
        end
        context 'you can list the remotes' do
          it 'when there are no remotes.' do
            input 'remote list'
            output_shift_only_is :stderr, 'no remotes found in 0 config files', true
          end
          it 'when there is one remote.' do
            input 'remote add nerp derp'
            output.clear
            input 'remote list'
            output_shift_only_is :stdout, 'nerp  derp', true
          end
        end
        context 'when removing a remote' do
          before do
            input 'remote add foo bar'
            output.clear
            input 'remote list'
            output_shift_only_is :stdout, 'foo  bar'
          end
          it 'using a valid name works' do
            input 'remote rm foo'
            output_shift_is :stdout, %r{updating .*local-conf\.d/config \.\. done \(\d\d+ bytes\.\)}
            output_shift_only_is :stderr, 'ferp remote rm: removed remote foo', true
          end
          it 'using an invalid name' do
            input 'remote rm fo'
            output_shift_is :stderr, 'failed to rm remote: couldn\'t find a remote named "fo"'
            output_shift_only_is :stderr, 'the only known remote is foo in this searched config resource', true
          end
        end
      end
    end
  end
end

