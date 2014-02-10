require_relative '../test-support'

module Skylab::Face::TestSupport::API::Action::Param_Set

  ::Skylab::Face::TestSupport::TestLib_::Sandboxify[ self ]

  describe "[fa] API::Action - param - set" do

    extend TS_

    context "`set` is like a `normalize` \"macro\"" do
      define_sandbox_constant :nightclub do

        module Sandbox::Wizzle
          class << self              # so ghetto to stick it to the wall
            attr_accessor :last_msg  # like this, but i was tired of catching
          end                        # exceptions and testing their messages..

          Face::API[ self ]

          class API::Actions::Pizzle < Face::API::Action
            params [ :where, :set, [ :here, :to_go ] ]

            def initialize
              @expression_agent = Face::TestSupport::EXPRESSION_AGENT_STUB_
            end

            attr_reader :msg_a

            def normalization_failure_line_notify msg
              Sandbox::Wizzle.last_msg = msg
            end
          end
          Face::Autoloader_[ self ]
        end
      end

      it "that generates the message" do
        r = nightclub::API::invoke :pizzle, where: :in_my_car
        Sandbox::Wizzle.last_msg.should eql( "invalid <<where>> #{
          }value __in_my_car__. expecting here or to_go" )
        r.should eql( false )
      end
    end
  end
end
