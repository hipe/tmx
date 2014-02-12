require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Client::API_Integration::Param

  ::Skylab::Face::TestSupport::CLI::Client::API_Integration[ self, :CLI_sandbox]

  describe "[fa] CLI client API integration - param" do

    extend CLI_Client_TS_
    extend TS__  # so CONSTANTS (Sandbox) is visible in i.m's

    context "this is testing both API and CLI integration ..." do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI
            class Client < Face_::CLI::Client
              def tengel is_dree_run, verboze, email
                @mechanics.api is_dree_run, verboze, email
              end
            end
          end

          module API
            module Actions
              class Tengel < Face_::API::Action
                meta_params :opto, :feld
                params [ :is_dree_run, :opto ], [ :verboze, :opto, :feld ],
                       [ :email, :feld ]
                def execute
                  unpack_params :opto, :feld
                end
              end
            end
          end
          Face_::Autoloader_[ self ]
        end
      end

      it "LOOK AT `unpack_params` - IT IS AMAZING" do
        o_h, f_h = invoke 'tengel', 'D', 'V', 'E'
        o_h.keys.map( & :id2name ).sort.map(& :intern ).should eql(
           [ :is_dree_run, :verboze ] )
        o_h[ :is_dree_run ].should eql( 'D' )
        o_h[ :verboze ].should eql( 'V' )
        f_h.length.should eql( 1 )
        f_h[ :email ].should eql( 'E' )
      end
    end
  end
end
