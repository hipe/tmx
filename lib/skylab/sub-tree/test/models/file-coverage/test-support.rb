require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  ::Skylab::SubTree::TestSupport[ TS_ = self, :filename, 'models/file-coverage' ]

  include Constants

  extend TestSupport_::Quickie

  Callback_ = Callback_

  module InstanceMethods

    include Callback_.test_support::Expect_event::Test_Context_Instance_Methods

  end

  module Build_Compound_Tree

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>

    def against t_or_a, f_or_d, r_or_nr=nil, path

      _cx = Subject_[]::Actors_::
        Classify_the_path::Classifications___.new( t_or_a, f_or_d, r_or_nr )

      @tree = Subject_[]::Actors_::Build_compound_tree[
        _cx, path,
        test_dir_for_build_compound_tree,
        Name_conventions_[],
        ___real_filesystem, & handle_event_selectively ]

      NIL_
    end

    def test_dir_for_build_compound_tree
      @test_dir
    end

    def ___real_filesystem
      SubTree_.lib_.system.filesystem
    end
  end

  Fixture_tree_test_dir_for_ = -> do
    h = {}
    -> sym do
      h.fetch sym do

        h[ sym ] = Top_TS_.dir_pathname.join(
          "fixture-trees/#{ sym }/test"
        ).to_path.freeze

      end
    end

  end.call

  Name_conventions_ = Callback_.memoize do

    Subject_[]::Models_::Name_Conventions.new %w( *_speg.rb *_spek.rb )
  end

  Subject_ = -> do
    SubTree_::Models_::File_Coverage
  end

  Mock_Boundish___ = ::Struct.new :to_kernel

  MOCK_BOUNDISH_ = Mock_Boundish___.new :_no_kernel_

  NIL_ = nil

  SubTree_ = SubTree_

  TEST__ = 'test'.freeze


end
