require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize - shared subject update" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    context 'shared subject update' do

      call_by do

        _test = fixture_file_ '62-shared-subj-tezd.kd'  # #coverpoint5-5

        my_API_common_generate_(
          asset_line_stream: _same_asset_line_stream,
          original_test_line_stream: ::File.open( _test ),
        )
      end

      shared_subject :_the_custom_tuple do
        _build_the_same_custom_tuple
      end

      it "looks OK structurally" do
        _the_custom_tuple || fail
      end

      it "the before block got updated" do
        the_before_block_looks_OK_
      end

      it "the shared subject got updated" do
        the_shared_subject_looks_OK_
      end

      it "the example block got updated" do
        the_example_block_looks_OK_
      end
    end

    context 'shared subject create' do

      call_by do

        _test = fixture_file_ '64-shared-subj-create-tezd.kd'

        my_API_common_generate_(
          asset_line_stream: _same_asset_line_stream,
          original_test_line_stream: ::File.open( _test ),
        )
      end

      shared_subject :_the_custom_tuple do
        _build_the_same_custom_tuple
      end

      it "looks OK structurally" do
        _the_custom_tuple || fail
      end

      it "the before block got updated" do
        the_before_block_looks_OK_
      end

      it "the shared subject got created" do
        the_shared_subject_looks_OK_
      end

      it "the example block got updated" do
        the_example_block_looks_OK_
      end
    end

    context 'example insert' do

      call_by do

        _test = fixture_file_ '63-insert-example-tezd.kd'

        my_API_common_generate_(
          asset_line_stream: _same_asset_line_stream,
          original_test_line_stream: ::File.open( _test ),
        )
      end

      shared_subject :_the_custom_tuple do
        _build_the_same_custom_tuple
      end

      it "looks OK structurally" do
        _the_custom_tuple || fail
      end

      it "the before block got updated" do
        the_before_block_looks_OK_
      end

      it "the shared subject got updated" do
        the_shared_subject_looks_OK_
      end

      it "the example block got updated" do
        the_example_block_looks_OK_
      end
    end

    def _same_asset_line_stream
      ::File.open fixture_file_ '12-shared-subject.kd'
    end

    def _build_the_same_custom_tuple
      n_significant_nodes_from_only_context_node_via_result_ 3
    end

    def the_before_block_looks_OK_
      a = _the_custom_tuple.first.nodes
      a[1].line_string == "        X_xkcd_MyPerkser = K::D::Lang.new :foo, :baz\n" || fail
      3 == a.length || fail
    end

    def the_shared_subject_looks_OK_
      a = _the_custom_tuple[1].nodes
      a[1].line_string == "        pxy = X_xkcd_MyPerkser.new(\n" || fail
    end

    def the_example_block_looks_OK_
      a = _the_custom_tuple.last.nodes
      a[1].line_string == "        expect( pxy.class ).to eql X_xkcd_MyPerkser\n" || fail
      3 == a.length || fail
    end
  end
end
