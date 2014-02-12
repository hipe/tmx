require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::API_Integration::Core

  ::Skylab::Face::TestSupport::CLI::API_Integration[ Core_TestSupport = self ]

  CONSTANTS::Common_setup_[ self, :sandbox ]

  describe "[fa] API integration (core)" do

    extend CLI_TestSupport
    extend Core_TestSupport  # so CONSTANTS (Sandbox) is visible in i.m's

    context "some nightclub - request a simple isomorphic call" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI  # maybe magic one day [#009]
            class Client < Face::CLI
              def fee
                @mechanics.api  # one way..
              end

              use :api
              def foo
                api  # ..another way
              end
            end
          end

          module API
            module Actions
              class Foo < Face::API::Action
                def execute
                  :foo_it_is
                end
              end
            end
          end
        end
      end

      it "for which no action defined - raises boxxy name error" do
        -> do
          invoke 'fee'
        end.should raise_error( /"fee"/i )
          # ( the particular class is asserted elsewhere. )
      end

      it "that takes no arguments anywhere - works" do
        r = invoke 'foo'
        r.should eql( :foo_it_is )
      end
    end
  end
end
