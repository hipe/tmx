module Skylab::DocTest::TestSupport

  module Fixture_Files

    def self.[] tcc
      tcc.include self
    end

    module Simple_Triad_Asset

      def self.[] tcc
        Here___[ self ]
        tcc.include self
      end

      def the_API_call_

        _asset = fixture_file_ '12-shared-subject.kd'

        _test = the_existing_test_file_path_

        my_API_common_generate_(
          asset_line_stream: ::File.open( _asset ),
          original_test_line_stream: ::File.open( _test ),
        )
      end

      def build_the_custom_tuple_

        _ctxt = context_node_via_result_

        a = _ctxt.nodes
        a = filter_endcaps_and_blank_lines_common_ a
        3 == a.length || fail
        a
      end

      def the_before_block_looks_OK_
        a = the_custom_tuple_.first.nodes
        a[1].line_string == "        X_xkcd_MyPerkser = K::D::Lang.new :foo, :baz\n" || fail
        3 == a.length || fail
      end

      def the_shared_subject_looks_OK_
        a = the_custom_tuple_[1].nodes
        a[1].line_string == "        pxy = X_xkcd_MyPerkser.new(\n" || fail
      end

      def the_example_block_looks_OK_
        a = the_custom_tuple_.last.nodes
        a[1].line_string == "        pxy.class.should eql X_xkcd_MyPerkser\n" || fail
        3 == a.length || fail
      end
    end

    # -

      def test_document_via_line_stream_ st  # (imperfect fit here, might move)
        Home_::OutputAdapters_::Quickie::Models::TestDocument.via_line_stream st
      end

      def the_noent_directory_
        TestSupport_::Fixtures.directory :not_here
      end

      def line_stream_via_filename_ file

        ::File.open fixture_file_( file ), ::File::RDONLY
      end

      def fixture_tree_pather path

        dirname = ::File.expand_path path, _fixture_trees_directory

        -> path_ do
          ::File.expand_path path_, dirname
        end
      end

      def tree_path_via_dir_ dir
        ::File.join _fixture_trees_directory, dir
      end

      def fixture_file_ file
        ::File.join _fixture_files_directory, file
      end

      common = Lazy_.call do
        TS_.dir_pathname.to_path
      end

      define_method :_fixture_trees_directory, ( Lazy_.call do
        ::File.join common[], 'fixture-trees'
      end )

      define_method :_fixture_files_directory, ( Lazy_.call do
        ::File.join common[], 'fixture-files'
      end )
    # -

    Here___ = self
  end
end
# #tombstone: "path cache" that mapped short symbols to paths
