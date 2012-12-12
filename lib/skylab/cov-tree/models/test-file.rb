module Skylab::CovTree

  class Models::TestFile < Struct.new :pathname, :anchor_dir

    def relative_pathname
      pathname.relative_path_from anchor_dir
    end

  protected

    def initialize path, anchor_dir
      pn = ::Pathname.new path.to_s
      super pn, anchor_dir
    end
  end
end
