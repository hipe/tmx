require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI - iso. - argument intro" do

    TS_[ self ]
    use :CLI_isomorphic_methods_client

    invoke_appropriate_action

    context "the zero arg syntax ()" do

      it "loads" do

        client_class_
      end

      it "0 args - no output, result is result" do

        invoke
        expect_no_more_lines
        @exitstatus.should eql :_zoink_
      end

      it "1 args - whines of unexpected, result is multi line" do

        invoke 'foo'
        expect_unexpected_argument 'foo'
        expect_common_failure_
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_zas < subject_class_

          def noink
            :_zoink_
          end

          self
        end
      end

      def expect_this_usage_
        expect :styled, :e, 'usage: zeepo noink'
      end
    end

    context "the one arg req syntax (foo)" do

      it "0 args - first line is styled whine of missing arg" do

        invoke
        expect :styled, :e, /\Aexpecting: <mono-arg>\z/
        expect_common_failure_
      end

      it "1 args - no output, result is result" do

        invoke 'foo'
        expect_succeeded_with_ '->foo<-'
      end

      it "2 args - whines of unexpected" do

        invoke 'aa', 'bb'
        expect_unexpected_argument 'bb'
        expect_common_failure_
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_oars < subject_class_

          def naples mono_arg
            "->#{ mono_arg }<-"
          end

          self
        end
      end

      def expect_this_usage_
        expect :styled, :e, 'usage: zeepo naples <mono-arg>'
      end
    end

    context "the simple glob syntax (*args)" do

      it "0 args - no output, result is reesult" do

        invoke
        expect_succeeded_with_ '{{  }}'
      end

      it "1 args - o" do

        invoke 'foo'
        expect_succeeded_with_ '{{ foo }}'
      end

      it "2 args - o" do

        invoke 'foo', 'blearg'
        expect_succeeded_with_ '{{ foo -- blearg }}'
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_sgs < subject_class_

          def zeeple * parts

            "{{ #{ parts.join ' -- ' } }}"
          end

          self
        end
      end
    end

    context "the trailing glob syntax (a, *b)" do

      it "0 args - whines of missing" do

        invoke
        expect :styled, :e, 'expecting: <apple>'
        expect_common_failure_
      end

      it "1 args - o" do

        invoke 'foo'
        expect_succeeded_with_ '_foo_'
      end

      it "2 args - o" do

        invoke 'x', 'y'
        expect_succeeded_with_ '_x*y_'
      end

      it "3 args - o" do

        invoke %w( x y z )
        expect_succeeded_with_ '_x*y*z_'
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_tgs < subject_class_

          def liffe apple, *annane
            "_#{ annane.unshift( apple ).join '*' }_"
          end

          self
        end
      end

      def expect_this_usage_

        expect :styled, :e, "usage: zeepo liffe #{
          }<apple> [<annane> [<annane> [..]]]"
      end
    end

    context "weird syntax (*a, b)" do

      it "0 args - whines of missing (WOW: includes optional; highlights other)" do

        invoke

        st = stream_for_expect_stdout_stderr
        _line_o = st.gets_one

        _omg = Zerk_lib_[]::CLI::Styling::Parse_styles[ _line_o.string ]

        _omg.should eql(

          [ [:string, "expecting: [<lip> [..]] "],
            [:style, 1, 32],
            [:string, "<nip>"],
            [:style, 0],
            [:string, "\n"] ] )

        expect_common_failure_
      end

      it "1 arg - o" do

        invoke 'sure'
        expect_succeeded_with_ 'sure'
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_ws1 < subject_class_

          def feeples *lip, nip
            ( lip.push nip ).join '.'
          end

          self
        end
      end

      def expect_this_usage_

        expect :styled, :e, "usage: zeepo feeples #{
          }[<lip> [<lip> [..]]] <nip>"
      end
    end

    context "weird syntax (a, *b, c)" do

      it "0 args - whines of missing" do

        invoke
        expect :styled, :e, /\Aexpecting: <zing>\z/
        expect_common_failure_
      end

      it "1 arg - whines of missing" do

        invoke 'win'
        expect :styled, "expecting: [<zang> [..]] <zhang>"
        expect_common_failure_
      end

      it "2 args - o" do

        invoke 'one', 'two'
        expect_succeeded_with_ '(one|two)'
      end

      it "3 args - o" do

        invoke 'A', 'B', 'C'
        expect_succeeded_with_ '(A|B|C)'
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_ws2 < subject_class_

          def fooples zing, *zang, zhang
            "(#{ [ zing, *zang, zhang ].join '|' })"
          end

          self
        end
      end

      def expect_this_usage_

        expect :styled, :e, "usage: zeepo fooples #{
          }<zing> [<zang> [<zang> [..]]] <zhang>"
      end
    end
  end
end
