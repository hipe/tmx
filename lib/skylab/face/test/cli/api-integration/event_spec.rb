require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::API_Integration::Event

  ::Skylab::Face::TestSupport::CLI::API_Integration[ Event_TestSupport = self ]

  CONSTANTS::Common_setup_[ self, :sandbox ]

  describe "#{ Face::CLI } API event integration" do

    extend CLI_TestSupport
    extend Event_TestSupport  # so CONSTANTS (Sandbox) is visible in i.m's

    context "does the thing with even names and the `on_` pattern" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI
            class Client < Face::CLI
              def barf
                @mechanics.call_api :burf
              end

            private ; dsl_off

              def on_honkey
                @y << "<<H.>>"
              end

              def on_tonkey
                @y << "<t.>"
              end
            end
          end

          module API
            module Actions
              class Burf < Face::API::Action
                taxonomic_streams  # none.
                emits :honkey, :tonkey
                def execute
                  emit :tonkey
                  emit :honkey
                  :x
                end
              end
            end
          end
        end
      end

      it "you event handling solution is nothing short of sheer ginus" do
        x = invoke 'barf'
        lines[:err].shift.should eql( '<t.>' )
        lines[:err].shift.should eql( '<<H.>>' )
        lines[:err].length.should eql( 0 )
        lines[:out].length.should eql( 0 )
        x.should eql( :x )
      end
    end

    context "how can she slap" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_2
          module CLI
            class Client < Face::CLI
              def marf
                @mechanics.api
              end
            end
          end

          module API
            module Actions
              class Marf < Face::API::Action
                taxonomic_streams  # none.
                emits :hinkey, :tinkey
                def execute
                  fail 'never see.'
                end
              end
            end
          end
        end
      end

      it "wat if u didn't - el raiso excepto" do
        -> do
          invoke 'marf'
        end.should raise_error(
          /unhandled non-taxonomic event streams \[:hinkey, :tinkey\]/i
        )
      end
    end
  end
end
