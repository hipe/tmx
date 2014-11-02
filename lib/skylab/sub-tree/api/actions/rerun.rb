self._NOT_USED  # here for referece

module Skylab::SubTree

  class API::Actions::Rerun < API::Actions::Cov

    attr_writer :rerun

    glob_h = SubTree::PATH.glob_h

    define_method :tree_to_render do
      rerun_ = rerun_file_paths or return false

      rerun = Node.from :paths, rerun_, :init_node, -> n { n.type = :rerun }

      path = rerun.longest_common_base_path or begin
        return error("Sorry, the test files must share a single common base path for now. " <<
                     "(had: #{rerun.children.map(&:key).join(', ')})")
      end
      dir = Pathname.new(path.join('/'))
      dir.exist? or
        return error("Sorry, expecting directory to exist: #{dir}")

      glob = glob_h[path.first] or
        return error("Sorry, expecting beginning of test path (#{path.first})" <<
                     " to be one of: (#{GLOB.keys.join(', ')})")

      all_ = Dir[dir.join('**').join(glob)]

      all = Node.from :paths, all_, :init_noe, -> n { n.type = :all }

      both = Node.combine :nodes, [ all, rerun ]

      both[:slug] ||= DOT_  # avoid warning about unable to make slug
      both
    end

    def rerun_file_paths
      File.exist?(@rerun) or return error("rerun file not found: #{@rerun.inspect}")
      File.read(@rerun).split(SPACE_).map do |path|
        RerunFile.new(path)
      end
    end
  end
  class Plumbing::Rerun::RerunFile < Pathname
    RE = %r{\A(.*[^:0-9]):(\d+(?::\d+)*)\z}
    def initialize str
      md = RE.match(str) or fail("Failed to match: #{str}")
      super(md[1])
      @line_numbers = md[2].split(':')
    end
    attr_reader :line_numbers
  end
end

