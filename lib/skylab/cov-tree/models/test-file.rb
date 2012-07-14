module Skylab::CovTree
  class Models::TestFile < Struct.new(:pathname, :anchor_dir)
    def initialize path, anchor_dir
      super Models::MyPathname.new(path), anchor_dir
    end
    def relative_pathname
      pathname.relative_path_from anchor_dir
    end
  end
end
