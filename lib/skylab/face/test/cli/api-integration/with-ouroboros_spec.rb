require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::API_Integration::WOU

  ::Skylab::Face::TestSupport::CLI::API_Integration[ WOU_TestSupport = self ]

  CONSTANTS::Common_setup_[ self, :sandbox ]

  describe "#{ Face::CLI } API event integration" do

    extend CLI_TestSupport
    extend WOU_TestSupport  # so CONSTANTS (Sandbox) is visible in i.m's

    context "make sure ouroborous is ok when doing `api`" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module API
            module Actions
              module Foo
                class Bar < Face::API::Action
                  params :x
                  def execute
                    "okay:(#{ @x })"
                  end
                end
              end
            end
          end
          module CLI
            class Client < Face::CLI
              namespace :foo, -> { CLI::Actions::Foo }
            end
            module Actions
              class Foo < Face::Namespace
                use :api
                def bar x
                  api x
                end
              end
            end
          end
          module API
          end
        end
      end

      it "is ouroborous ok with all of this?" do
        r = invoke 'foo', 'bar', 'yes'
        r.should eql( 'okay:(yes)' )
      end
    end
  end
end
