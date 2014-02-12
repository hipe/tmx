require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::API_Integration::Service

  ::Skylab::Face::TestSupport::CLI::API_Integration[ Service_TestSupport = self ]

  CONSTANTS::Common_setup_[ self, :sandbox ]

  describe "[fa] API INTEGRATED SERVICES" do

    extend CLI_TestSupport
    extend Service_TestSupport  # so CONSTANTS (Sandbox) is visible in i.m's

    context "service in API/CLI is yes/no -" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI
            class Client < Face::CLI
              def fiff x
                @mechanics.api x
              end
            end
          end

          module API
            module Actions
              class Fiff < Face::API::Action
                services [ :zap, :ivar ]
                params :x
                def execute
                  @zap.call @x
                end
              end
            end

            class Client < Face::API::Client
              Face::Plugin::Host.enhance self do
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
            class Client < Face::CLI

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

              Face::Plugin::Host::Proxy.enhance self do
                services :imogen
              end
            end
          end
          module API
            module Actions
              class GleepBeep < Face::API::Action
                services [ :imogen, :ivar ]
                def execute
                  @imogen.call
                end
              end

              class WinkleTankle < Face::API::Action
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
          Face::Plugin::DeclarationError,
            /has not declared the required services.+biffle.+baffle/
        )
      end
    end
  end
end
