require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Box

  describe "[hl] CLI box core" do

    extend TS__

    context "minimal example (no o.p because it's overridden)" do

      box_class do
        class Frick
          Headless_::CLI::Box[ self, :core_instance_methods ]
        private
          def unbound_action_box
            self.class
          end
          def build_option_parser
          end

          define_singleton_method :names, Autoloader_.names_method

          self
        end
      end

      it "loads" do
        puts "ok: #{ box_class }"
      end

      it "builds" do
        box_action
      end

      it "1.x) it treats option-looking args as args" do
        invoke '-h'
        expect %r(\Athere is no "-h" action\. expecting \{\}\z)
        expect_usage_and_box_aware_invited
      end
    end

    context "minimal 'working' example (with no actions)" do

      box_class do
        class FudgeBox

          Headless_::CLI::Box[ self, :core_instance_methods ]

          define_singleton_method :each_const_value,
            Autoloader_.each_const_value_method

          def unbound_action_box
            self.class
          end

          define_singleton_method :names, Autoloader_.names_method

          self
        end
      end

      it "0)   you must define at least the box module getter method" do
        invoke
        expect "expecting {}"
        expect_usage_and_box_aware_invited
      end

      it "1.1) whines about unrecognized derkss (uselessly)" do
        invoke 'xx'
        expect "there is no \"xx\" action. expecting {}"
        expect_usage_and_box_aware_invited
      end

      it "1.4) out of the box it has an option parser " do
        invoke '-h'
        expect_usage
        expect_blank
        expect_header :options
        expect_item_line_for_help
        expect_blank
        expect_leading_invite
        expect_succeeded
      end
    end

    class Action_Stub
      def initialize client
        @a = client.spy_a ; nil
      end
      def name
        self.class.name_function.local
      end
      class << self
        attr_reader :name_function
      end
      def some_summary_ln
        "#{ name.as_slug } WEEHOO"
      end
      def invoke args
        @a.concat args.map { |s| "_#{ s }_" } ; :_fez_
      end
    end

    context "two children" do

      box_class do
        class Donk
          Headless_::CLI::Box[ self, :core_instance_methods ]

          def initialize * _
            @spy_a = []
            super
          end

          def client_services_for_bound_action_by_agent
            self  # don't break when we bring in client services
          end

          attr_reader :spy_a

          def unbound_action_box
            self.class
          end

          class FooBar < Action_Stub
            @name_function = Headless_::Name.
              via_module_name_anchored_in_module_name name, Donk.name
          end
          class BazzBiff < Action_Stub
            @name_function = Headless_::Name.simple_chain.
              via_symbol_list( [ :never_see, :bazz_biff ] )

            def help_screen y
              y << "helo"
              :_terff_
            end
          end

          define_singleton_method :each_const_value,
            Autoloader_.each_const_value_method
          define_singleton_method :names,
            Autoloader_.names_method

          self
        end
      end

      it "N.4,*) dispatches the request using the name function name" do
        invoke 'foo-bar', 'x', 'y'
        box_action.spy_a.should eql %w( _x_ _y_ )
        expect_no_more_serr_lines
        @result.should eql :_fez_
      end

      it "1.1) use a bad argument, it makes suggestions" do
        invoke "wizzle", "teef_taff"  # zip
        expect_there_is_no_action "wizzle"
        expect_usage_and_box_aware_invited
      end

      it "1.4) help screen with action index (actions need ~4 methods)" do
        invoke '-h'
        expect_big_help_screen_for_two_children
      end

      def expect_big_help_screen_for_two_children
        expect_usage
        expect_blank
        expect_header :options
        expect_item_line_for_help
        expect_blank
        expect_header :actions
        expect :styled, /\A {2,}foo-bar {2,}foo-bar WEEHOO\b/
        expect :styled, /\A {2,}bazz-biff {2,}bazz-biff WEEHOO\b/
        expect_blank
        expect_leading_invited
      end

      it "2.1) the infix-ed help switch with an incorrect action term" do
        invoke '-h', 'wenk'
        expect_there_is_no_action 'wenk'
        expect_usage_and_box_aware_invited
      end

      it "3.1,1) the infex-ed help switch with an incorrect action term plus" do
        invoke '-h', 'wernk', 'tazz'
        expect_ignoring 'tazz'
        expect_there_is_no_action 'wernk'
        expect_usage_and_box_aware_invited
      end

      it "2.3) the infix-ed help switch with a correct action term" do
        invoke '-h', 'bazz-biff'
        expect 'helo'
        expect_no_more_serr_lines
        @result.should eql :_terff_
      end

      it "3.3,1) the infixed-ed help switch with correct action term plus" do
        invoke '-h', 'bazz-biff', 'borf'
        expect_ignoring 'borf'
        expect 'helo'
        expect_no_more_serr_lines
        @result.should eql :_terff_
      end

      def expect_usage_and_box_aware_invited
        expect_usage
        expect_box_aware_invited
      end

      def expect_leading_invited
        expect_leading_invite
        expect_succeeded
      end

      def expect_box_aware_invited
        expect_box_aware_invite
        expect_failed
      end

      def expect_ignoring s
        expect %r(\bignoring\b.+\b#{ ::Regexp.escape s }\b)
      end

      def expect_there_is_no_action who_s
        expect :styled, /\bthere is no "#{ ::Regexp.escape who_s }" #{
          }action\. expecting \{ *foo-bar *\| *bazz-biff *\}/
      end

    end

    def expect_usage_and_box_aware_invited
      expect_usage
      expect_box_aware_invite
      expect_failed
    end

    def expect_item_line_for_help
      expect %r(\A {2,} -h, --help \[<sub-action>\] {2,} this screen #{
        }\[or sub-action help\]\z)
    end

    prognm_rxs = '(?:frick|fudge-box|donk)'

    def expect_usage
      expect :styled, USAGE_RX__
    end
    USAGE_RX__ = /\busage: yerp #{ prognm_rxs } \[<action>\] \[<args> \[\.\.\]\]/

    def expect_box_aware_invite
      expect :styled, INVITE_RX__
    end
    INVITE_RX__ = /\buse yerp #{ prognm_rxs } -h \[<action>\] for help/

    def expect_leading_invite
      expect :styled, LEADING_INVITE_RX__
    end
    LEADING_INVITE_RX__ = /\buse yerp #{ prognm_rxs } -h <action> for help on that action\b/
  end
end
