require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - iso. - o.p intro" do

    TS_[ self ]
    use :CLI_isomorphic_methods_client

    context "a client with one action with an option parser" do

      it "reflect (ok to remove)" do

        _cls = client_class_
        _cls::Modalities::CLI::Actions.constants.should eql [ :Wen_Kel ]
      end

      # here we use [#108] the canonical numbers for CLI input permutations

      it "2.3. invoke (just the arg)" do

        invoke 'wen-kel', 'biz'
        expect :e, "«biz with {}»"
        expect_no_more_lines
        @exitstatus.should eql :yerp
      end

      it "3.4 invoke (good opt)" do

        invoke 'wen-kel', 'biz', '--ex', 'yuss'
        _expect_same_yuss
      end

      it "3.4 invoke (same but infix)" do

        invoke 'wen-kel', '--ex', 'yuss', 'biz'
        _expect_same_yuss
      end

      def _expect_same_yuss
        expect :e, '«biz with {:ex=>"yuss"}»'
        expect_no_more_lines
        @exitstatus.should eql :yerp
      end

      it "3.2 invoke (bad opt)" do

        invoke 'wen-kel', 'x', '--ziz'
        expect :e, "invalid option: --ziz"
        expect_specifically_invited_to 'wen-kel'
      end

      context "2.4 help (postfix)" do

        shared_subject :state_ do
          immutable_helpscreen_state_via_invoke_ 'wen-kel', '-h'
        end

        it "succeeded" do
          _succeeded
        end

        it "usage section" do
          _usage_section
        end

        it "options section" do
          _options_section
        end

        it "argument section" do
          _argument_section
        end
      end

      context "2.4 help (prefix)" do

        shared_subject :state_ do
          immutable_helpscreen_state_via_invoke_ '-h', 'wen-kel'
        end

        it "succeeded" do
          _succeeded
        end

        it "usage section" do
          _usage_section
        end

        it "options section" do
          _options_section
        end

        it "argument section" do
          _argument_section
        end
      end

      def _succeeded
        state_.exitstatus.should be_zero
      end

      def _usage_section
        expect_section_ "usage", _expect_usage
      end

      def _options_section
        expect_section_ "options", _expect_options
      end

      def _argument_section
        expect_section_ "argument", _expect_argument
      end

      memoize :_expect_usage do
        <<-HERE.unindent
          usage: zeepo wen-kel [-x FUN] <bar>
                 zeepo wen-kel -h

        HERE
      end

      memoize :_expect_options do
        <<-HERE.unindent
          options
              -x, --ex <wat-fun>               ohai
              -h, --help                       this screen

        HERE
      end

      memoize :_expect_argument do
        <<-HERE.unindent
          argument
              <bar>
        HERE
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_03 < subject_class_

          def initialize( * )
            @_parm_h = {}
            super
          end

          option_parser do | o |
            o.on '-x', '--ex <wat-fun>', 'ohai' do |x|
              @_parm_h[ :ex ] = x
            end
          end

          def wen_kel bar
            @resources.serr.puts "«#{ bar } with #{ @_parm_h.inspect }»"
            :yerp
          end

          self
        end
      end
    end
  end
end
