require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI microservice toolkit - argument intro" do

    TS_[ self ]
    use :CLI_microservice_toolkit

    invoke_appropriate_action

    context "the zero arg syntax ()" do

      it "loads" do

        client_class_
      end

      it "0 args - no output, result is result" do

        invoke
        want_no_more_lines
        expect( @exitstatus ).to eql :_zoink_
      end

      it "1 args - whines of unexpected, result is multi line" do

        invoke 'foo'
        want_unexpected_argument 'foo'
        want_common_failure_
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_zas < subject_class_

          def noink
            :_zoink_
          end

          self
        end
      end

      def want_this_usage_
        want :styled, :e, 'usage: zeepo noink'
      end
    end

    context "the one arg req syntax (foo)" do

      it "0 args - first line is styled whine of missing arg" do

        invoke
        want :styled, :e, /\Aexpecting: <mono-arg>\z/
        want_common_failure_
      end

      it "1 args - no output, result is result" do

        invoke 'foo'
        want_succeeded_with_ '->foo<-'
      end

      it "2 args - whines of unexpected" do

        invoke 'aa', 'bb'
        want_unexpected_argument 'bb'
        want_common_failure_
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_oars < subject_class_

          def naples mono_arg
            "->#{ mono_arg }<-"
          end

          self
        end
      end

      def want_this_usage_
        want :styled, :e, 'usage: zeepo naples <mono-arg>'
      end
    end

    context "the simple glob syntax (*args)" do

      it "0 args - no output, result is reesult" do

        invoke
        want_succeeded_with_ '{{  }}'
      end

      it "1 args - o" do

        invoke 'foo'
        want_succeeded_with_ '{{ foo }}'
      end

      it "2 args - o" do

        invoke 'foo', 'blearg'
        want_succeeded_with_ '{{ foo -- blearg }}'
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
        # #lends-coverage to [#fi-008.5]
        invoke
        want :styled, :e, 'expecting: <apple>'
        want_common_failure_
      end

      it "1 args - o" do

        invoke 'foo'
        want_succeeded_with_ '_foo_'
      end

      it "2 args - o" do

        invoke 'x', 'y'
        want_succeeded_with_ '_x*y_'
      end

      it "3 args - o" do

        invoke %w( x y z )
        want_succeeded_with_ '_x*y*z_'
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_tgs < subject_class_

          def liffe apple, *annane
            "_#{ annane.unshift( apple ).join '*' }_"
          end

          self
        end
      end

      def want_this_usage_

        want :styled, :e, "usage: zeepo liffe #{
          }<apple> [<annane> [<annane> [..]]]"
      end
    end

    context "weird syntax (*a, b)" do

      it "0 args - whines of missing (WOW: includes optional; highlights other)" do

        invoke

        st = stream_for_want_stdout_stderr
        _line_o = st.gets_one

        st = Home_::CLI::Styling::ChunkStream_via_String[ _line_o.string ]

        _s = st.gets
        _s == "expecting: [<lip> [..]] " || fail

        sct = st.gets
        sct.styles == [:strong, :green] || fail
        sct.string == "<nip>" || fail

        scn = st.gets
        scn.styles == [:no_style] || fail
        scn.string == NEWLINE_ || fail

        scn = st.gets
        scn && fail

        want_common_failure_
      end

      it "1 arg - o" do

        invoke 'sure'
        want_succeeded_with_ 'sure'
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_ws1 < subject_class_

          def feeples *lip, nip
            ( lip.push nip ).join '.'
          end

          self
        end
      end

      def want_this_usage_

        want :styled, :e, "usage: zeepo feeples #{
          }[<lip> [<lip> [..]]] <nip>"
      end
    end

    context "weird syntax (a, *b, c)" do

      it "0 args - whines of missing" do

        invoke
        want :styled, :e, /\Aexpecting: <zing>\z/
        want_common_failure_
      end

      it "1 arg - whines of missing" do

        invoke 'win'
        want :styled, "expecting: [<zang> [..]] <zhang>"
        want_common_failure_
      end

      it "2 args - o" do

        invoke 'one', 'two'
        want_succeeded_with_ '(one|two)'
      end

      it "3 args - o" do

        invoke 'A', 'B', 'C'
        want_succeeded_with_ '(A|B|C)'
      end

      shared_subject :client_class_ do

        class TS_::CLI_IMC_02_ws2 < subject_class_

          def fooples zing, *zang, zhang
            "(#{ [ zing, *zang, zhang ].join '|' })"
          end

          self
        end
      end

      def want_this_usage_

        want :styled, :e, "usage: zeepo fooples #{
          }<zing> [<zang> [<zang> [..]]] <zhang>"
      end
    end
  end
end
