require_relative '../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - stow - status, show" do

    TS_[ self ]
    use :stow

    it "status - dir not found" do

      _path = no_ent_path_
      _sc = real_system_conduit_

      begin
        call_API( :stow, :status,
          :current_relpath, 'xyz1',
          :project_path, _path,
          :system_conduit, _sc,
        )
      rescue ::Errno::ENOENT => e
      end

      e.message.should match %r(\ANo such file or dir)
    end

    it "status - dir not dir" do

      _path = TestSupport_::Fixtures.file( :one_line )
      _sc = real_system_conduit_

      begin
        call_API( :stow, :status,
          :current_relpath, 'xyz2',
          :project_path, _path,
          :system_conduit, _sc,
        )
      rescue ::Errno::ENOTDIR => e
      end

      e.message.should match %r(\ANot a directory )
    end

    it "status - OK - OK" do

      call_API( :stow, :status,
        :current_relpath, 'diffy',
        :project_path, '/wiffy',
        :system_conduit, __this_mock_system_conduit,
      )

      expect_neutral_event :command, /\Acommand: git ls-files /

      st = @result
      st.gets.should eql "diffy/derpus"
      st.gets.should eql "diffy/nerpus/herpus"
      st.gets.should be_nil

      expect_no_more_events
    end

    def __this_mock_system_conduit

      mock_system_conduit_where_(

        '/wiffy/diffy',
        git_ls_files_others_,

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

      s = Home_.lib_.zerk::CLI::Styling::Unstyle_styled[ _act ]
      s or fail
      s.should eql _exp
    end

    def _same_API_call

      call_API :stow, :show,
        :filesystem, real_filesystem_,  # glob
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
