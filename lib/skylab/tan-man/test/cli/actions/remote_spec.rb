require_relative 'test-support'

module Skylab::TanMan::TestSupport::CLI::Actions

  describe "[tm] CLI action `remote`", tanman: true, cli_action: true, wip: true do

    extend TS_

    paystream = :paystream ; infostream = :infostream

    context 'for remotes' do

      context 'when there is no local config directory' do

        before :each do
          prepare_tanman_tmpdir
        end

        it "cannot get added, whines about no directory" do
          input 'remote add bing bong'
          output_shift_is infostream,
            "ferp failed to add remote - couldn't find local-conf.d in #{
              }this or any parent directory"
          output_shift_only_is infostream, 'use ferp init to create it', false
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

        context "-" do
          before :each do
            prepare_local_conf_dir
          end

        it 'you can add a local remote' do
          input 'remote add bing bong'
          output_shift_only_is infostream,
            'while ferp was adding remote: creating config .. done (146 bytes.)',
            true
        end
        end

        context 'you can list the remotes' do

          before :each do
            prepare_local_conf_dir
          end

          it 'when there are no remotes.' do
            input 'remote list'
            output_shift_only_is infostream,
              'no remotes found in 0 config files', true
          end

          it 'when there is one remote.' do
            input 'remote add nerp derp'
            output.lines.clear
            input 'remote list'
            output_shift_only_is paystream, 'nerp  derp', true
          end
        end

        context 'when removing a remote' do

          before :each do
            input 'remote add foo bar'
            output.lines.clear
            input 'remote list'
            output_shift_only_is paystream, 'foo  bar'
          end

          it 'using a valid name works' do
            input 'remote rm foo'
            output_shift_is infostream,
              /updating config \.\. done \(\d+ bytes\.\)/
            output_shift_only_is infostream,
              /removed remote foo/, true
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
