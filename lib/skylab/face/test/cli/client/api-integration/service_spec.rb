require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Client::API_Integration::Service

  ::Skylab::Face::TestSupport::CLI::Client::API_Integration[ self, :CLI_sandbox]

  describe "[fa] CLI client API integrtaion - service" do

    extend CLI_Client_TS_
    extend TS__  # so CONSTANTS (Sandbox) is visible in i.m's

    context "service in API/CLI is yes/no -" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI
            class Client < Face_::CLI::Client
              def fiff x
                @mechanics.api x
              end
            end
          end

          module API
            module Actions
              class Fiff < Face_::API::Action
                services [ :zap, :ivar ]
                params :x
                def execute
                  @zap.call @x
                end
              end
            end

            class Client < Face_::API::Client
              Face_::Plugin::Host.enhance self do
                services :zap
              end  # note that we do *not* use the plugin *proxy* dsl here

              def initialize
                super
                @zap = -> x { "<ZAP:#{ x }>" }
              end

              attr_reader :zap
            end
          end
        end
      end

      it "ok - uses API service" do
        r = invoke 'fiff', 'zeep'
        r.should eql( '<ZAP:zeep>' )
      end
    end

    context "service in API/CLI is .. " do

      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_2
          module CLI
            class Client < Face_::CLI::Client

              def initialize( * )
                super
                @imogen = -> { "heap" }
              end

              def gleep_beep
                @mechanics.api
              end

              use :api

              def winkle_tankle
                api
              end

              attr_reader :imogen
              private :imogen

              Face_::Plugin::Host::Proxy.enhance self do
                services :imogen
              end
            end
          end
          module API
            module Actions
              class GleepBeep < Face_::API::Action
                services [ :imogen, :ivar ]
                def execute
                  @imogen.call
                end
              end

              class WinkleTankle < Face_::API::Action
                services :biffle, [ :baffle ]
                def execute
                  fail 'never see'
                end
              end
            end
          end
        end
      end

      it "service in API/CLI : no/yes - ok" do
        r = invoke 'gleep-beep'
        r.should eql( 'heap' )
      end

      it "service in API/CLI : no/no - .." do
        -> do
          invoke 'winkle-tankle'
        end.should raise_error(
          Face_::Plugin::DeclarationError,
            /has not declared the required services.+biffle.+baffle/
        )
      end
    end
  end
end
