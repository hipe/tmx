require_relative 'api-integration/test-support'
  # look, sorry: we want one method defined in above, because we choose to
  # define the whole client class (for aesthetics) and not just snippets.

module Skylab::Face::TestSupport::CLI::DSL_Off

  ::Skylab::Face::TestSupport::CLI[ DSL_Off_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox

  Face = Face

  describe "#{ Face::CLI } dsl off" do

    extend CLI_TestSupport::API_Integration
    extend DSL_Off_TestSupport

    context "wankers" do

      define_sandbox_constant :application_module do

        module Sandbox::Nightclub_1
          module CLI
            class Client < Face::CLI
              with_dsl_off do
                def invoke( * )
                  @touched = true
                  super
                end
              end
              def foo
                @mechanics.sheet.command_tree._order
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
