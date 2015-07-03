require_relative '../../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] models - stow - actions - status, show" do

    extend TS_
    use :models_stow_support

    it "status - dir not found" do

      _status_against no_ent_path_
      expect_not_OK_event :errno_enoent  #  same as in suite 1
      expect_failed
    end

    it "status - dir not dir" do

      _status_against TestSupport_::Data::Universal_Fixtures[ :one_line ]
      _ev =  expect_not_OK_event :wrong_ftype

      black_and_white( _ev ).should match(
        /\A«[^»]+» exists but is not a directory, it is a file\z/ )

      expect_failed
    end

    def _status_against path

      call_API :stow, :status,
        :directory, :_trueish_,
        :stows_path, path,
        :system_conduit, :_trueish_

      NIL_
    end

    it "status - OK - OK" do

      call_API :stow, :status,
        :directory, :_papadopoulis_,
        :stows_path, stashiz_path_,
        :system_conduit, __this_mock_system_conduit

      expect_neutral_event :command, /\Acommand: git ls-files /

      st = @result
      st.gets.should eql "derpus"
      st.gets.should eql "nerpus/herpus"
      st.gets.should be_nil

      expect_no_more_events
    end

    def __this_mock_system_conduit

      mock_system_conduit_where_(
        :_papadopoulis_,
        %w(  git ls-files --others --exclude-standard ),
      ) do | i, o, e |
        o << "derpus\n"
        o << "nerpus/herpus\n"
        0
      end
    end

    it "show - by default does the --stat format" do

      _same_API_call

      _st = @result.to_styled_stat_line_stream

      o = _to_line_scanner _st

      o.expect_styled_line.should eql "flip.txt      | 2 ++"

      o.expect_styled_line.should eql "flop/floop.tx | 4 ++++"

      o.next_line.should eql(
        "2 files changed, 6 insertions(+), 0 deletions(-)" )

      o.expect_no_more_lines
    end

    it "show - it can also do the --patch format" do

      _same_API_call

      _st = @result.to_styled_patch_line_stream

      _o = _to_line_scanner _st

      _act = _o.flush

      _exp = <<-HERE.unindent
        --- /dev/null
        +++ b/flip.txt
        @@ -0,0 +1,2 @@
        +one 
        +two
        --- /dev/null
        +++ b/flop/floop.tx
        @@ -0,0 +1,4 @@
        +one two
        +trhee
        +foour
        +
      HERE

      s = Home_.lib_.brazen::CLI::Styling::Unstyle_styled[ _act ]
      s or fail
      s.should eql _exp
    end

    def _same_API_call

      call_API :stow, :show,
        :filesystem, ::File,
        :system_conduit, Home_.lib_.open_3,  # using the real one is OK here:
          # we do a `find` command inside a fixture tree, and ..

        :stows_path, Fixture_tree_[ :stows_2 ],
        :stow_name, 'derp'
      NIL_
    end

    def _to_line_scanner st

      TestSupport_::Expect_Line::Scanner.via_line_stream st
    end
  end
end
