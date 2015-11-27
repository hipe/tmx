require_relative '../../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] models - survey aggregators" do

    TS_[ self ]
    use :expect_event

    it "add a strange name" do

      call_API :survey, :edit,
        :add_aggregator, 'wiff-nabble-paws( cantankerous )',
        :path, dir( :freshly_initted )

      expect_not_OK_event :uninitialized_constant
      expect_failed
    end


    it "add a good name" do

      td = prepare_tmpdir_with_patch :with_fuzz_biff

      call_API :survey, :edit,
        :add_aggregator, 'unique-features',
        :path, td.to_path

      expect_neutral_event :added_function_call
      expect_OK_event :collection_resource_committed_changes

      content_of_the_file( td ).scan( /(?<=^function = ).+/ ).should(
        eql( [
          'mutator:remove-empty-act( fuz bif, true, 1.3 )',
          '"mutator:split-and( \"stay\" )"',
          'mutator:remove-empt( x, y )',
          'aggregator:unique-features'
        ] ) )
    end

    it "remove (in a temporary omg) (also we sneak a test for map in here)" do

      call_API :survey, :reduce,

        :upstream, file( :two_tables_md ),

        :add_map, 'single-property-value( prog lang name )',

        :add_aggregator, 'unique-feat',
        :remove_aggregator, 'unique-feature'

      expect_no_events

      st = @result
      st.gets.should eql "ruby"
      st.gets.should eql "haskell"
      st.gets.should be_nil

    end

    it "ersatz catalyst case (integration for sure)" do

      call_API :survey, :reduce,

        :add_mutator, 'remove-empty-actual-prop',

        :add_aggregator, 'unique-features( name field: the feature )',

        :upstream, file( :mutators_01_simple_md ),
        :table_number, 2

      expect_no_events

      st = @result

      a = [ :"entity name", :"feature name", :"feature value" ]
      st.gets.at( * a ).should eql [ "bike", :"uses gas?", "no gas" ]
      st.gets.at( * a ).should eql [ "bike", :"is it cheap?", "yes" ]
      st.gets.at( * a ).should eql [ "car", :"can you live in it?", "yes" ]
      st.gets.should be_nil

    end
  end
end
