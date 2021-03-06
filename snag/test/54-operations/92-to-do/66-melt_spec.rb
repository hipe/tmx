require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - to-do - actions - melt" do

    TS_[ self ]

    use :want_event, :ignore, :find_command_args

    use :byte_up_and_downstreams
    use :my_tmpdir_

    it "if there are no file matches at all - looks same as no content matches" do

      call_API(
        :to_do, :melt,
        :path, Fixture_tree_[ :some_todos ],
      )

      _want_same
    end

    it "if files are matched but no content, is same" do

      call_API(
        :to_do, :melt,
        :path, Fixture_tree_[ :some_todos ],
        :name, '*.code',
      )

      _want_same
    end

    def _want_same

      _em = want_neutral_event :no_matches

      expect( black_and_white _em.cached_event_value ).to match(
        /\Athere are no found todos #{
         }in files whose name matched "\*\.[a-z]{2,4}" #{
          }in «[^»]+»\z/ )

      want_neutralled
    end

    it "with plain old todo's with no message, explains the pain" do

      call_API(
        :to_do, :melt,
        :pattern, '%to-dew',
        :path, Fixture_tree_[ :some_todos ],
        :name, '*.code',
      )

      _em = want_neutral_event :no_matches

      expect( black_and_white _em.cached_event_value ).to match(
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

      call_API(
        :to_do, :melt,
        :path, td.to_path,
        :name, '*.sc',
      )

      __want_these_events
    end

    def __want_these_events

      want_OK_event :wrote

      ev = want_neutral_event( :process_line ).cached_event_value

      expect( black_and_white ev ).to match %r(\Apatching file .+jeebis.sc$)

      fh = ::File.open @_source_pn.to_path
      expect( fh.gets ).to eql "aleph\n"
      expect( fh.gets ).to eql "bet ##{}open [#001] we shou[..]\n"
      expect( fh.gets ).to eql "gimmel\n"
      expect( fh.gets ).to be_nil

      fh = ::File.open @_manifest_pn.to_path
      expect( fh.gets ).to eql "[#02]       i started at two just to be cute\n"
      expect( fh.gets ).to eql "[#001]       we should fix this\n"
      expect( fh.gets ).to be_nil

      ev = want_OK_event( :summary ).cached_event_value.to_event
      expect( ev.number_of_files_seen_here ).to eql 1
      expect( ev.number_of_qualified_matches ).to eql 1
      expect( ev.number_of_seen_matches ).to eql 1
      want_no_more_events
    end

    it "multiple files, dry run" do

      _mani_path = Fixture_file_[ :rochambeaux_mani ]
      _tree_path = Fixture_tree_[ :melt_bonanza ]

      call_API(
        :to_do, :melt,
        :downstream_reference, _mani_path,
        :path, _tree_path,
        :name, '*.code',
        :pattern, '%to-dew',
        :dry_run,
      )

      __want_these_multiple_files_events
    end

    def __want_these_multiple_files_events

      want_OK_event :wrote
      want_neutral_event :process_line
      want_OK_event :wrote
      want_neutral_event :process_line

      _em = want_OK_event :summary

      expect( black_and_white _em.cached_event_value ).to eql(
        '(dryly) changed the 3 qualified todos of 5 todos in 2 files' )

      want_succeed
    end

    def _manifest_file

      Home_::Models_::NodeCollection::COMMON_MANIFEST_FILENAME_
    end
  end
end
