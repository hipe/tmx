module Skylab::TestSupport

  module FileCoverage

    module Magnetics_::TwoTrees_via_BigTreePattern::SubPath ; class << self

      def call sub_path, test_dir_localized, full  # assume path is not test dir

        test_head = "#{ test_dir_localized }#{ ::File::SEPARATOR }"

        if test_head == sub_path[ 0, test_head.length ]

          _path = sub_path[ test_head.length .. -1 ]

          _this_way :test, :asset, _path, full
        else

          # test dir is *within* asset dir, hence the asymmetry

          _this_way :asset, :test, sub_path, full
        end
      end

      def _this_way left, right, real_path, full

        paths = Models_::Trees.new
        pre_pruned = Models_::Trees.new

        path_a = real_path.split ::File::SEPARATOR

        _full_left = full[ left ].fetch_node path_a do end
        _full_right = full[ right ]

        pre_pruned[ left ] = _full_left
        pre_pruned[ right ] = _full_right

        paths[ left ] = path_a

        o = Result___.new
        o.order = [ left, right ]
        o.paths = paths
        o.pre_pruned = pre_pruned
        o
      end

      Result___ = ::Struct.new :order, :paths, :pre_pruned
    end ; end
  end
end
