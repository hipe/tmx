require_relative '../../test-support'

module Skylab::SubTree::TestSupport::Models_File_Coverage

  ::Skylab::SubTree::TestSupport[ TS_ = self, :filename, 'models/file-coverage' ]

  include Constants

  extend TestSupport_::Quickie

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

  module Expect_Node_Characteristics

    class << self
      def [] tcm
        tcm.include self
      end
    end  # >>


    def expect_tests_but_no_assets_ node

      _expect_tests node
      _expect_NO_assets node
    end

    def expect_assets_but_no_tests_ node

      _expect_assets node
      _expect_NO_tests node
    end

    def expect_assets_and_tests_ node

      _expect_assets node
      _expect_tests node
    end

    def _expect_assets node

      node.node_payload.has_assets or fail _say_expected( :assets, node )
    end

    def _expect_tests node

      node.node_payload.has_tests or fail _say_expected( :tests, node )
    end

    def _expect_NO_assets node

      node.node_payload.has_assets and fail _say_expected( :no, :assets, node )
    end

    def _expect_NO_tests node

      node.node_payload.has_tests and fail _say_expected( :no, :tests, node )
    end

    def _say_expected no=nil, which, node

      s = node.slug.inspect

      if no
        "expected no #{ which }, had some: #{ s }"
      else
        "expected #{ which }, had none: #{ s }"
      end
    end
  end

  Fixture_tree_ = -> do
    h = {}
    -> sym do
      h.fetch sym do
        h[ sym ] = Top_TS_.dir_pathname.
          join( "fixture-trees/#{ sym }" ).to_path.freeze
      end
    end
  end.call

  Fixture_tree_test_dir_for_ = -> do
    h = {}
    -> sym do
      h.fetch sym do
        h[ sym ] = ::File.join( Fixture_tree_[ sym ], 'test' ).freeze
      end
    end

  end.call

  Callback_ = Callback_

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
