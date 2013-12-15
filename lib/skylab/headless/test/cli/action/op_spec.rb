require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Action::OP__

  ::Skylab::Headless::TestSupport::CLI::Action[ TS__ = self ]

  include CONSTANTS

  Headless = Headless

  extend TestSupport::Quickie

  describe "[hl] CLI action OP integration", ok: true do

    extend TS__

    context "action class with nothing" do

      with_action_class do
        class Nothing
          Headless::CLI::Action[ self, :core_instance_methods ]
          self
        end
      end

      it "loads" do
      end

      it "builds" do
        action
      end

      it "no 'default_action' - X" do
        act = action
        -> do
          act.invoke [ '-x' ]
        end.should raise_error ::NameError,
          /\bundefined\b.+\bmethod\b.+`default_action_i'/
      end
    end

    context "action class with default action" do
      with_action_class do
        class Something
          Headless::CLI::Action[ self,
            :core_instance_methods,
            :default_action, :foo ]
          def foo x
            "ok:(#{ x })"
          end
          self
        end
      end
      it "when no o.p, argv is passed thru unchanged" do
        invoke '-x'
        @result.should eql 'ok:(-x)'
        expect_no_more_serr_lines
      end
    end

    context "with o.p" do
      with_action_class do
        class Op_A
          Headless::CLI::Action[ self,
            :core_instance_methods,
            :default_action, :bar ]
          def initialize * _
            @param_x_a = []
            super
          end
          attr_reader :param_x_a

          def build_option_parser
            op = Headless::Services::OptionParser.new
            op.on '-y', '--yes <hi>' do |x|
              @param_x_a.push :yes, x
            end
            op
          end
          def bar
            :ok
          end
          self
        end
      end
      # here we use [#133] the canonical numbers for CLI input permutations
      it "0)   no arg - o" do
        invoke
        @result.should eql :ok
        expect_no_more_serr_lines
      end
      it "1.2) one arg, bad opt: look at what thinks its name is (A B) - x" do
        invoke '-x'
        expect "invalid option: -x"
        expect_usage_line_with 'yerp op-a [-y <hi>]'
        expect_invite_line_with 'yerp op-a'
        expect_no_more_serr_lines
        @result.should be_result_for_parse_failure
      end
      it "2.(4,3) one good opt (when required argument is provided) - o" do
        invoke %w( -y hi )
        action.param_x_a.should eql [ :yes, 'hi' ]
        expect_no_more_serr_lines
        @result.should eql :ok
      end
      it "1.4 one good opt (but no required argument) - x" do
        invoke %w( -y )
        expect "missing argument: -y"
        expect_a_few_more_serr_lines
        @result.should be_result_for_parse_failure
      end
    end

    context "dark hack" do
      with_action_class do
        class Dark_OP
          def parse! argv
            mine = argv.dup ; argv.clear
            yield -> do
              @holy_gizzards = mine.zip( %w( dee ) ).flatten.compact.join ' '
              nil
            end ; nil
          end
        end

        class Dark_Action
          Headless::CLI::Action[ self, :core_instance_methods,
                                 :default_action, :zerp ]
          def build_option_parser
            Dark_OP.new
          end
          def zerp
            @yes = :_win_
            true  # get the close to happen
          end
          attr_reader :holy_gizzards, :yes
          self
        end
      end

      it "with dark hacks you can" do
        invoke %w( hoop doop )
        @action.yes.should eql :_win_
        @action.holy_gizzards.should eql 'hoop dee doop'
        @result.should eql true
      end
    end

    def be_result_for_parse_failure
      eql false
    end
  end
end
