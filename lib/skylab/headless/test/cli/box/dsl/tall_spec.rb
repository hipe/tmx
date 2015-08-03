require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Box::DSL

  describe "[hl] x", wip: true do

    extend TS__

    context "x" do

      before :all do

        module CLI0_Action_InstanceMethods
          CLI_[].action self, :core_instance_methods
        end

        class CLI0_Action
          ACTIONS_ANCHOR_MODULE = -> { CLI0_Actions }
          CLI_[].action self, :DSL
          include CLI0_Action_InstanceMethods
        end

        class CLI0_Action_Box < CLI0_Action
          CLI_[]::Box[ self,
            :DSL, :leaf_action_base_class, -> { CLI0_Action },
            :core_instance_methods
          ]
        end

        module CLI0_Actions
          def self.dir_pathname
          end
        end

        class CLI0_Actions::Node < CLI0_Action_Box
          box.desc 'actions that act on a node'
          desc 'close a node'
          option_parser do |o|
            o.on '-v', '--verby' do |_| end
          end
          def close x
          end
        end

        class CLI0_Actions::Node::Actions::Go_Tags < CLI0_Action_Box
          box.desc 'actions for tags'
          desc 'add a tag.'
          option_parser do |o|
            o.on '-x', '--xyz VAL', 'the x option' do |x|
              @par_h[ :x ] = x
            end
          end
          def add x, y=nil
            emit_info_line "ok:( #{ x } )"
            :_foo_
          end
        end

        class CLI0_Actions::Node::Actions::Otr < CLI0_Action_Box
        end
      end

      def box_class
        CLI0_Actions::Node
      end

      it "  0)" do
        invoke
        expect :styled, 'expecting {close|go-tags|otr}'
        expect :styled, 'usage: yerp node [<action>] [<args> [..]]'
        expect :styled, 'use yerp node -h [<action>] for help'
        expect_failed
      end

      it "1.1)"

      it "1.3)" do
        invoke 'go-tags'
        expect :styled, 'expecting {add}'
        expect_usage_3_deep
        expect_invited_3_deep
      end

      it "2.3x1)" do
        invoke 'go-tags', 'nerp'
        expect :styled, 'there is no "nerp" action. expecting {add}'
        expect_usage_3_deep
        expect_invited_3_deep
      end

      it "2.3x3)" do
        invoke 'go-tags', 'add'
        expect :styled, 'expecting: <x>'
        expect_usage_4_deep
        expect_invite_4_deep
        expect_neutralled  # LOOK
      end

      it "3.3x3x3" do
        invoke 'go-tags', 'add', 'foo'
        expect 'ok:( foo )'
        expect_no_more_serr_lines
        @result.should eql :_foo_
      end

      def expect_invited_3_deep
        expect_invite_3_deep
        expect_failed
      end

      def expect_usage_3_deep
        expect :styled, 'usage: yerp node go-tags [<action>] [<args> [..]]'
      end

      def expect_invite_3_deep
        expect :styled, 'use yerp node go-tags -h [<action>] for help'
      end

      def expect_usage_4_deep
        expect :styled, 'usage: yerp node go-tags add [-x VAL] [-h] <x> [<y>]'
      end

      def expect_invite_4_deep
        expect :styled, 'use yerp node go-tags -h add for help'
      end
    end
  end
end
