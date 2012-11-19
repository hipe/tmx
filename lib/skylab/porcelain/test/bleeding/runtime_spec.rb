require_relative 'runtime/test-support'

module ::Skylab::Porcelain::TestSupport::Bleeding::Runtime # #po-008
  describe "#{::Skylab::Porcelain::Bleeding::Runtime}" do
    extend Runtime_TestSupport
    include Runtime_TestSupport::CONSTANTS
    Bleeding = self::Bleeding # ruby stahp

    let( :debug ) { false }

    let( :meta_hell_anchor_module )  { Runtime_TestSupport }

    context "at level 0" do

      klass :My_CLI_Runtime, extends: Bleeding::Runtime do # @todo try deeper names
        include Runtime_InstanceMethods
        rt = self
        class rt::MyAction
          # extend Bleeding::Action # @todo
          def self.build rt
            new.build!(rt)
          end
          def build! rt
            @parent = rt ; self
          end
        end
        module rt::Actions
        end
        class rt::Actions::Act1 < rt::MyAction
        end
        class rt::Actions::Act2 < rt::MyAction
          # desc 'fooibles your dooibles'
          def invoke fizzle, bazzle
            "yerp: #{fizzle.inspect} #{bazzle.inspect}"
          end
        end
      end


      frame "with no args" do
        argv
        specify { should be_event(0, :help, /expecting.+act1.+act2/i) }
        specify_should_usage_invite
      end

      frame "with bad args" do
        argv 'foo', 'bar'
        specify { should be_event(0, :help, /invalid action.+foo.+expecting.+act1.+act2/i) }
        specify_should_usage_invite
      end

      frame "with bad opts" do
        argv '-x'
        specify { should be_event(0, :help, /invalid action "-x"/i) }
      end

      def self.should_show_index
        specify { should be_event(0, /usage.+DORP.+act1.+act2/i) }
        specify { should be_event(2, /act1/i) }
        # specify { should be_event(3, /act2.+fooible/i) } #@todo desc
        specify { should be_event(4, /for help on a particular action/i) }
      end

      frame "-h" do
        argv '-h'
        should_show_index
      end

      frame "help" do
        argv 'help'
        should_show_index
      end

      frame "-h <valid action>" do
        argv '-h', 'act2'
        specify { should be_event(0, "usage: DORP act2 <fizzle> <bazzle>") }
        # specify { should be_event(1, "description: fooibles your dooibles") } @todo
      end

      frame "-h <invalid action>" do
        argv '-h', 'whatevr'
        specify { should be_event(0, /invalid action.+whatevr.+expecting.+act1.+act2/i) }
        specify { should be_event(1, nil) }
      end
    end


    context "at level 1 (the action 'pony')" do
      klass :MyKliss, extends: Bleeding::Runtime do
        o = self
        include Runtime_InstanceMethods
        class o::MyAction
          # extend Bleeding::Action # @todo
          def self.build rt
            new.build! rt
          end
          def build! rt
            @parent = rt ; self
          end
          def emit(*a)
            @parent.emit(*a)
          end
        end
        module o::Actions
        end
        module o::Actions::Pony
          # extend Bleeding::Namespace # @todo
        end
        class o::Actions::Pony::Create < o::MyAction
        end
        class o::Actions::Pony::PutDown < o::MyAction
          def invoke oingo=nil, boingo
            emit(:ze_payload, "yerp-->#{oingo.inspect}<-->#{boingo.inspect}<--")
            :you_put_down_the_pony
          end
        end
        class o::Actions::Pony::PutUp < o::MyAction
          extend Bleeding::ActionModuleMethods
          option_syntax.help_enabled = true
          def invoke
            emit(:mein_payload, "yoip")
          end
        end
      end


      frame "just it" do
        argv  'pony'
        specify { should be_event(0, /expecting.+create.+put-down/i) }
      end

      def self.index
        specify { should be_event(0, :help, /usage.+DORP.+pony.+create.+put-down.+put-up/i) }
        specify { should be_event(1, /^ *actions:?$/) }
        ['create', 'put-down', 'put-up'].each_with_index do |act, idx|
          specify { should be_event(idx + 2, /^ *#{act} *$/) }
        end
        specify { should be_event(-1, /try DORP pony <action> -h for help on a particular action/i) }
      end

      frame "-h it" do
        argv '-h', 'pony'
        index
      end

      frame "it -h" do
        argv 'pony', '-h'
        index
      end

      frame "at level 2" do
        frame "with a bad name" do
          msg_rx = /invalid action.+nerk.+expecting.+create.+put-down/i

          frame "just it" do
            argv  'pony', 'nerk'
            specify { should be_event(0, msg_rx) }
          end

          frame "-h it" do
            argv 'pony', '-h', 'nerk'
            specify { should be_event(0, :error, msg_rx) }
          end

          frame "it -h" do
            argv 'pony', 'nerk', '-h'
            specify { should be_event(0, :help, msg_rx) }
          end
        end

        frame "with an ambiguous name" do
          argv 'pony', 'put'
          specify { should be_event(0, :help, /ambiguous action .+put.+did you mean put-down or put-up\?/i) }
        end

        frame "with a good name" do
          frame "unambiguous fuzzy" do
            msg_rx = /usage.+DORP pony put-down \[<oingo>\] <boingo>/i

            frame "just it does cute syntax thing" do
              argv  'pony', 'put-d'
              specify { should be_event(0, :syntax_error, /missing.+argument.+boingo/i) }
              specify { should be_event(1, msg_rx) }
              specify { should be_event(2, /try DORP pony put-down -h for help/i) }
            end

            frame "-h it" do
              argv 'pony', '-h', 'put-d'
              specify { should be_event(0, :help, msg_rx) }
              specify { should be_event(1, nil) }
            end

            frame "it -h out of the box will process it as an arg" do
              argv 'pony', 'put-d', '-h'
              specify { should be_event(0, :ze_payload, 'yerp-->nil<-->"-h"<--') }
              specify { should be_event(1, nil) }
            end
          end

          frame "exact match, with a thing with no option syntax but help enabled" do
            msg_rx = "usage: DORP pony put-up"

            frame "it -h" do
              argv 'pony', 'put-up', '-h'
              specify { should be_event(:help, msg_rx) }
            end

            frame "-h it" do
              argv 'pony', '-h', 'put-up'
              specify { should be_event(:help, msg_rx) }
            end
          end
        end
      end
    end
  end
end
