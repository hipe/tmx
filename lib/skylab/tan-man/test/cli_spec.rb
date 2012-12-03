require File.expand_path('../test-support', __FILE__)
# above kept for posterity


module Skylab::TanMan::TestSupport

  describe "The #{TanMan} CLI", tanman: true do
    extend TanMan_TestSupport


    paystream = :paystream ; infostream = :infostream

    context 'for remotes' do

      before do
        prepare_submodule_tmpdir
      end

      context 'when there is no local config directory' do
        it 'cannot get added, whines about no directory' do
          input 'remote add bing bong'
          output_shift_is infostream,
            "ferp failed to add remote - couldn't find local-conf.d in #{
              }this or any parent directory"
          output_shift_only_is infostream, 'try ferp init to create it', false
        end

        it 'cannot get listed, whines the same' do
          input 'remote list'
          output_shift_is infostream,
            "ferp failed to list remote - couldn't find local-conf.d in #{
             }this or any parent directory"
          output_shift_only_is infostream, false # invite
        end
      end

      context 'when there is a local config directory' do
        before do
          prepare_local_conf_dir
          services_clear
        end

        it 'you can add a local remote', f:true do
          input 'remote add bing bong'
          output_shift_only_is infostream,
            %r{creating .+/tmp/#{ TMPDIR_STEM }/local-conf\.d.+\d\d bytes\.},
            true
        end

        context 'you can list the remotes' do
          it 'when there are no remotes.' do
            input 'remote list'
            output_shift_only_is infostream,
              'no remotes found in 0 config files', true
          end

          it 'when there is one remote.' do
            input 'remote add nerp derp'
            output.clear
            input 'remote list'
            output_shift_only_is paystream, 'nerp  derp', true
          end
        end

        context 'when removing a remote' do
          before do
            input 'remote add foo bar'
            output.clear
            input 'remote list'
            output_shift_only_is paystream, 'foo  bar'
          end

          it 'using a valid name works' do
            input 'remote rm foo'
            output_shift_is infostream,
              %r{updating .*local-conf\.d/config \.\. done \(\d\d+ bytes\.\)}
            output_shift_only_is infostream,
              'ferp remote rm: removed remote foo', true
          end

          it 'using an invalid name' do
            input 'remote rm fo'
            output_shift_is infostream,
              'failed to rm remote - couldn\'t find a remote named "fo"'
            output_shift_is infostream,
              'the only known remote is foo in this searched config resource'
            output_shift_only_is infostream,
              'try ferp remote rm -h for help', false
          end
        end
      end
    end
  end
end
