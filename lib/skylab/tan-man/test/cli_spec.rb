require File.expand_path('../../cli', __FILE__)
require File.expand_path('../test-support', __FILE__)

module Skylab::TanMan::TestSupport
  describe "The #{TanMan} CLI", tanman: true do
    context 'for remotes' do
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

