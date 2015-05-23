require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - to-do - actions - melt" do

    extend TS_

    use :expect_event, :ignore, :find_command_args

    use :byte_up_and_downstreams
    use :my_tmpdir_

    it "if there are no file matches at all - looks same as no content matches" do

      call_API :to_do, :melt,
        :path, [ Fixture_tree_[ :some_todos ] ]

      _expect_same
    end

    it "if files are matched but no content, is same" do

      call_API :to_do, :melt,
        :path, [ Fixture_tree_[ :some_todos ] ],
        :name, [ '*.code' ]

      _expect_same
    end

    def _expect_same

      _ev = expect_neutral_event :no_matches

      black_and_white( _ev ).should match(
        /\Athere are no found todos #{
         }in files whose name matched "\*\.[a-z]{2,4}" #{
          }in «[^»]+»\z/ )

      expect_neutralled
    end

    it "with plain old todo's with no message, explains the pain" do

      call_API :to_do, :melt,
        :pattern, [ '%to-dew' ],
        :path, [ Fixture_tree_[ :some_todos ] ],
        :name, [ '*.code' ]

      _ev = expect_neutral_event :no_matches
      black_and_white( _ev ).should match(
        /\Aof the 3 found todos, #{
        }none of them have message content after them #{
        }in files whose name matched "\*\.code" #{
        }in «[^»]+»\z/ )
    end

    it "but with one file with one such line, ADDS NODE AND EDITS FILE" do

      td = my_tmpdir_

      td.prepare

      @_source_pn = td.write 'jeebis.sc', <<-O.unindent
        aleph
        bet ##{}todo we should fix this
        gimmel
      O

      @_manifest_pn = td.write _manifest_file, <<-O.unindent
        [#02]       i started at two just to be cute
      O

      call_API :to_do, :melt,
        :path, [ td.to_path ],
        :name, [ '*.sc' ]

      ev = expect_neutral_event :process_line
      black_and_white( ev ).should match %r(\Apatching file .+jeebis.sc$)

      fh = ::File.open @_source_pn.to_path
      fh.gets.should eql "aleph\n"
      fh.gets.should eql "bet ##{}open [#001] we shou[..]\n"
      fh.gets.should eql "gimmel\n"
      fh.gets.should be_nil

      fh = ::File.open @_manifest_pn.to_path
      fh.gets.should eql "[#02]       i started at two just to be cute\n"
      fh.gets.should eql "[#001]       we should fix this\n"
      fh.gets.should be_nil

      ev = expect_OK_event( :summary ).to_event
      ev.number_of_files_seen_here.should eql 1
      ev.number_of_qualified_matches.should eql 1
      ev.number_of_seen_matches.should eql 1
      expect_no_more_events
    end

    it "multiple files, dry run" do

      _mani_path = Fixture_file_[ :rochambeaux_mani ]
      _tree_path = Fixture_tree_[ :melt_bonanza ]

      call_API :to_do, :melt,
        :downstream_identifier, _mani_path,
        :path, [ _tree_path ],
        :name, [ '*.code' ],
        :pattern, [ '%to-dew' ],
        :dry_run

      _ev1 = expect_neutral_event :process_line
      _ev2 = expect_neutral_event :process_line
      _ev = expect_OK_event :summary

      black_and_white( _ev ).should eql(
        '(dryly) changed the 3 qualified todos of 5 todos in 2 files' )

      expect_succeeded
    end

    def _manifest_file

      Snag_::Models_::Node_Collection::COMMON_MANIFEST_FILENAME_
    end
  end
end
