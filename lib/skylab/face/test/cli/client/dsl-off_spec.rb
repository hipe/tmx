require_relative 'api-integration/test-support'
  # look, sorry: we want one method defined in above, because we choose to
  # define the whole client class (for aesthetics) and not just snippets.

module Skylab::Face::TestSupport::CLI::Client::DSL_Off

  ::Skylab::Face::TestSupport::CLI::Client[ self, :CLI_sandbox ]

  describe "[fa] CLI client DSL off" do

    extend CLI_Client_TS_::API_Integration
    extend TS__

    context "wankers" do

      define_sandbox_constant :application_module do

        module Sandbox::Nightclub_1
          module CLI
            class Client < Face_::CLI::Client
              with_dsl_off do
                def invoke( * )
                  @touched = true
                  super
                end
              end
              def foo
                @mechanics.sheet.command_tree.instance_variable_get( :@a )
              end
              attr_reader :touched
            end
          end
        end
      end

      it "hi" do
        client.invoke( ['foo'] ).should eql( [ :foo, :touched ] )
        client.touched.should eql( true )
      end
    end
  end
end
