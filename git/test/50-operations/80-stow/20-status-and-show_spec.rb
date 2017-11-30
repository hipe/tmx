require_relative '../../test-support'

module Skylab::Git::TestSupport

  describe "[gi] operations - stow - status, show" do

    TS_[ self ]
    use :stow

    it "status - dir not found" do

      _path = no_ent_path_

      begin
        call_API( :stow, :status,
          :current_relpath, 'xyz1',
          :project_path, _path,
          # :system_conduit, _sc,
        )
      rescue ::Errno::ENOENT => e
      end

      expect( e.message ).to match %r(\ANo such file or dir)
    end

    it "status - dir not dir" do

      _path = TestSupport_::Fixtures.file( :one_line )

      begin
        call_API( :stow, :status,
          :current_relpath, 'xyz2',
          :project_path, _path,
        )
      rescue ::Errno::ENOTDIR => e
      end

      expect( e.message ).to match %r(\ANot a directory )
    end

    it "status - OK - OK" do

      syscond = __this_mock_system_conduit
      define_singleton_method :prepare_subject_API_invocation do |invo|
        # (meh)
        invo.invocation_resources.define_singleton_method :system_conduit do
          syscond
        end
        invo
      end

      call_API( :stow, :status,
        :current_relpath, 'diffy',
        :project_path, '/wiffy',
      )

      want_neutral_event :command, /\Acommand: git ls-files /

      _st = @result
      want_these_lines_in_array_ _st do |y|
        y << 'diffy/derpus'
        y << 'diffy/nerpus/herpus'
      end

      want_no_more_events
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

      expect( o.want_styled_line ).to eql "flip.txt      | 2 ++"

      expect( o.want_styled_line ).to eql "flop/floop.tx | 4 ++++"

      expect( o.next_line ).to eql(
        "2 files changed, 6 insertions(+), 0 deletions(-)" )

      o.want_no_more_lines
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

      s = Zerk_lib_[]::CLI::Styling::Unstyle_styled[ _act ]
      s or fail
      expect( s ).to eql _exp
    end

    def _same_API_call

      call_API :stow, :show,
        :stows_path, Fixture_tree_[ :stows_2 ],
        :stow_name, 'derp'
      NIL_
    end

    def _to_line_scanner st

      TestSupport_::Want_Line::Scanner.via_line_stream st
    end
  end
end
