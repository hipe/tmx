require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] CLI - recursive intro" do

    TS_[ self ]
    use :memoizer_methods
    use :my_non_interactive_CLI
    use :mock_systems

    _OP = 'recur'

    context "list (self)" do

      given do
        argv _OP, '--list', sidesystem_path_
      end

      it "succeeds" do
        succeeds
      end

      shared_subject :_sorted_tuples do
        __sort_these_tuples to_output_line_stream
      end

      it "first result is for the top thing, test file not exist (#FRAGILE)" do

        c_or_d, test_path, asset_path = _sorted_tuples.fetch 0
        c_or_d == :create || fail
        test_path == "test/core_spec.rb" || fail
        asset_path == 'doc_test.rb' || fail
      end

      it "second thing is etc (#FRAGILE)" do

        c_or_d, test_path, asset_path = _sorted_tuples.fetch 1
        c_or_d == :update || fail

        asset_path.include? '/test-file-context.' or fail

        # be jerks
        digislug = '\d+(?:\.\d+)*(?:-[a-z]+)+'
        test_path =~ %r(\Atest(?:/#{ digislug })+/#{ digislug }_spec\.rb\z) || fail
      end

      def this_system_conduit_
        mock_system_that_is_passthru_of_filesystem_related_only__
      end

      alias_method :this_filesystem_, :the_real_filesystem_
    end

    def __sort_these_tuples output_line_stream

      _ETC = {
        'would-create' => :create,
        'would-update' => :update,
      }
      _SPACE = Home_::SPACE_

      o = Home_.lib_.basic::Pathname::Localizer
      localize_asset = o[ ::File.dirname( home_dir_path_ ) ]
      localize_test = o[ sidesystem_path_ ]

      tuples = output_line_stream.map_by do |str|
        c_or_d, test_path, asset_path = str.split _SPACE
        [ _ETC.fetch( c_or_d ), localize_test[ test_path ], localize_asset[ asset_path ] ]
      end.to_a

      tuples.sort_by! do |tuple|
        tuple.last.length
      end

      tuples
    end
  end
end
# #tombstone: --dry-run and --force
# #tombstone: began to remove pre-zerk test cases
