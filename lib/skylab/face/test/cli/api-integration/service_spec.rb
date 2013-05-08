require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::API_Integration::Service

  ::Skylab::Face::TestSupport::CLI::API_Integration[ Service_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox

  describe "#{ Face::CLI } API INTEGRATED SERVICES" do

    extend CLI_TestSupport
    extend Service_TestSupport  # so CONSTANTS (Sandbox) is visible in i.m's

    Face = Face

    context "service in API/CLI is yes/no -" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI
            class Client < Face::CLI
              def fiff x
                api x
              end
            end
          end

          module API
            module Actions
              class Fiff < Face::API::Action
                services [ :zap, :ingest ]
                params :x
                def execute
                  @zap.call @x
                end
              end
            end

            class Client < Face::API::Client
              Face::Services::Headless::Plugin::Host.enhance self do
                service_names %i| zap |
              end

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

    context "service in API/CLI is no/yes - " do

      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_2
          module CLI
            class Client < Face::CLI
              Face::Services::Headless::Plugin::Host.enhance self do
                service_names %i| imogen |
              end

              def initialize( * )
                super
                @imogen = -> { "heap" }
              end

              def gleep_beep
                api
              end

              attr_reader :imogen
              private :imogen
            end
          end
          module API
            module Actions
              class GleepBeep < Face::API::Action
                services [ :imogen, :ingest ]
                def execute
                  @imogen.call
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
    end
  end
end
