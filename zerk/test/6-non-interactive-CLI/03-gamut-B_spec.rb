require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] non-interactive CLI - gamut B" do

    TS_[ self ]
    use :non_interactive_CLI

    context "ended before reaching operation name (#t6)" do

      given do
        argv 'compo2'
      end

      it "fails" do
        fails
      end

      it "splays" do
        first_line.should be_line( :styled, :e,
          %r(\Aexpecting [^{]+\{ 'compo3' \| 'ope2') )
      end
    end

    context "get a dash after a compound (#t7)" do

      given do
        argv 'compo2', '--any-option'
      end

      it "fails" do
        fails
      end

      it "first line specifically explains this failure" do

        _be_this = be_line :e,
          /\bcannot occur immediately after\b.+\(option: "--any-option"\)/

        first_line.should _be_this
      end

      it "full splay" do
        second_line.should look_like_full_splay_of_( 'compo3', 'ope2' )
      end

      it "stacked argument-specific invite" do
        last_line.should be_invite_with_argument_focus
      end
    end

    context "compound then operation (#t11)", wip: true do  # #milestone-4

      given do
        argv 'compo2', 'ope2'
      end

      it "succeeds" do
        succeeds
      end

      it "custom emission was expressed" do
        first_line.should be_line( :styled, :e, %r(\Ahello from ope2 with no\b ))
      end
    end

    context "compound then operation then good options (#t5, #t11)", wip: true do  # #milestone-4

      given do
        argv 'compo2', 'compo3', 'ope3', '--primi2', 'p2val', '--primi3', 'p3val'
      end

      it "succeeds" do
        succeeds
      end

      it "yay" do
        first_line.should be_line( :e, "(p2: p2val, p3: p3val)" )
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_42_Complexica ]
    end
  end
end
