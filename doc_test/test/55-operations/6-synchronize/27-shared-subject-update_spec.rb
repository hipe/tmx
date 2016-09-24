require_relative '../../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - synchronize - shared subject update" do

    TS_[ self ]
    use :fixture_files_simple_triad_asset
    use :my_API

    context 'shared subject update' do

      call_by do
        the_API_call_
      end

      shared_subject :the_custom_tuple_ do
        build_the_custom_tuple_
      end

      def the_existing_test_file_path_
        fixture_file_ '62-shared-subj-tezd.kd'  # #coverpoint5-5
      end

      it "looks OK structurally" do
        the_custom_tuple_ || fail
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
        the_API_call_
      end

      shared_subject :the_custom_tuple_ do
        build_the_custom_tuple_
      end

      def the_existing_test_file_path_
        fixture_file_ '64-shared-subj-create-tezd.kd'
      end

      it "looks OK structurally" do
        the_custom_tuple_ || fail
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
        the_API_call_
      end

      shared_subject :the_custom_tuple_ do
        build_the_custom_tuple_
      end

      def the_existing_test_file_path_
        fixture_file_ '63-insert-example-tezd.kd'
      end

      it "looks OK structurally" do
        the_custom_tuple_ || fail
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
  end
end
