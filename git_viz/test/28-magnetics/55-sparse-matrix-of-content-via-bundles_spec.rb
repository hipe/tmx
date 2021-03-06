# frozen_string_literal: true

require_relative '../test-support'

module Skylab::GitViz::TestSupport

  describe '[gv] magnetics - sparse matrix of content via bundles' do

    TS_[ self ]
    use :VCS_adapters_git_bundles

    it "loads" do
      _subject
    end

    it "sparse row, each cel knows if it is first, and its amount classification" do

      bundle_against_ '/m04/repo'

      _table = _subject[ @bundle, @repository ]

      expect( _table.rows.length ).to eql 3

      row = _table.rows.fetch 0

      a = row.business_items

      expect( a.length ).to eql 5

      expect( a[ 0 ] ).to be_nil

      this = :count_towards_weight_for_rasterized_visualization.to_proc

      mfc = a.fetch 1
      expect( mfc.is_first ).to eql true
      this[ mfc ] == 1 || fail

      mfc = a.fetch 2
      expect( mfc.is_first ).to eql false
      this[ mfc ] == 2 || fail

      expect( a[ 3 ] ).to be_nil

      mfc = a.fetch 4
      expect( mfc.is_first ).to eql false
      this[ mfc ] == 2 || fail
    end

    def _subject
      Home_::Magnetics_::SparseMatrix_of_Content_via_Bundles
    end

    def manifest_path_for_stubbed_FS
      at_ :STORY_04_PATHS_
    end

    def manifest_path_for_stubbed_system
      at_ :STORY_04_COMMANDS_
    end
  end
end
