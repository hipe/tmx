require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Client::API_Integration::Core_

  ::Skylab::Face::TestSupport::CLI::Client::API_Integration[ self, :CLI_sandbox ]

  describe "[fa] CLI client API integration (core)" do

    extend CLI_Client_TS_
    extend TS__  # so Constants (Sandbox) is visible in i.m's

    context "some nightclub - request a simple isomorphic call" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI  # maybe magic one day [#009]
            class Client < Face_::CLI::Client
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
              class Foo < Face_::API::Action
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
        end.should raise_error(
          %r(\bthere is no constant that isomorphs with "fee")i )
          # ( the particular class is asserted elsewhere. )
      end

      it "that takes no arguments anywhere - works" do
        r = invoke 'foo'
        r.should eql( :foo_it_is )
      end
    end
  end
end
