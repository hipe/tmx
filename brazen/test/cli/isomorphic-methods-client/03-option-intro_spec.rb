require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - iso. - o.p intro" do

    extend TS_
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

      it "2.4 help (postfix)" do

        invoke 'wen-kel', '-h'
        _expect_same_help_screen
      end

      it "2.4 help (prefix)" do

        invoke '-h', 'wen-kel'
        _expect_same_help_screen
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

      define_method :_expect_same_help_screen, -> do

        _HELP_SCREEN_UNSTYLED = <<-HERE.unindent
          usage: zeepo wen-kel [-x X] <bar>
                 zeepo wen-kel -h

          options
              -x, --ex <wat-fun>               ohai
              -h, --help                       this screen

          argument
              bar
        HERE

        -> do

          _str = flush_to_unstyled_string_contiguous_lines_on_stream :e

          _str.should eql _HELP_SCREEN_UNSTYLED  # or more regressible

          expect_succeeded
        end
      end.call
    end
  end
end
