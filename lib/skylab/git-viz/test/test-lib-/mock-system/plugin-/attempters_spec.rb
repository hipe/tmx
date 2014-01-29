require_relative 'test-support'

module Skylab::GitViz::TestSupport::Test_Lib_::Mock_System::Plugin_

  describe "[gv] test-lib- mock system plugin- attempters" do

    context "one" do

      before :all do

        class Fazoozle

          GitViz::Test_Lib_::Mock_System::Plugin_::Host[ self ]

          def initialize
            m = method :raise
            class << m
              alias_method :<<, :call
            end
            @y = m
            load_plugins
          end

          def init_plugins
          end

          def run
            resolve_connection
          end
        private

          def resolve_connection
            attempt_with_plugins :on_attempt_to_connect
          end

          spec = build_mutable_callback_tree_specification
          spec << :on_attempt_to_connect
          Callback_Tree__ = spec.flush

          plugin_conduit_class
          class Plugin_Conduit
            def connected_via= x
              up.cntd_via = x
            end
            def << msg
              up.add_msg msg ; nil
            end
          end
       public
         attr_accessor :cntd_via
         def add_msg x
           @msg = x
         end
         attr_reader :msg

          module Plugins__
            class Connection_Strategy_A
              def initialize host
                @host = host
              end
              def on_attempt_to_connect
                @host << :no_this_didnt_work
                nil
              end
            end
            class Connection_Strategy_B
              def initialize host
                @host = host
              end
              def on_attempt_to_connect
                @host.connected_via = :connected_via_B
                :yep_that_worked
              end
            end
          end
        end
      end

      it "o" do
        faz = Fazoozle.new
        r = faz.run
        r.should eql :yep_that_worked
        faz.msg.should eql :no_this_didnt_work
        faz.cntd_via.should eql :connected_via_B
      end
    end
  end
end
