require 'open3'

module ::Skylab::CovTree
  class API::Actions::Tree < API::Action
    emits(
      :anchor_point,
      :error,
      :number_of_test_files,
      :test_file,
      :tree_line_meta,
    )
    def anchors
      ::Enumerator.new do |y|
        test_dirs.each do |dir|
          ee = ::Enumerator.new do |yy|
            _glob_basename = GLOBS[dir.basename.to_s] or fail("unexepected: #{dir.basename.to_s}")
            _glob = dir.join("**/#{_glob_basename}").to_s
            Dir[_glob].each do |p|
              yy << Models::TestFile.new(p, dir)
            end
          end
          y << Models::Anchor.new(dir, ee)
        end
      end
    end
    def code_file_paths
      re = %r{^#{Regexp.escape @test_dir.to_s}/}
      files = Dir["#{@test_dir.dirname}/**/*.rb"]
      files.select { |f| re !~ f }
    end
    def execute # @todo naming
      list_as ? list : tree
    end
    def initialize params
      @list_as = nil
      yield self
      params.each { |k, v| send("#{k}=", v) }
      @path or self.path = '.'
    end
    def list
      num = 0
      anchors.each do |anchor|
        emit(:anchor_point, anchor_point: anchor)
        anchor.test_files.each do |node|
          num += 1
          emit(:test_file, test_file: node)
        end
      end
      if @last_error_message
        false
      else
        emit(:number_of_test_files, number: num)
        true
      end
    end
    attr_accessor :list_as
    def path= path
      @path = path ? Models::MyPathname.new(path) : path
    end
    def test_dirs
      ::Enumerator.new do |y|
        if ! @path.exist?
          error("no such directory: #{@path.pretty}")
        elsif ! @path.directory?
          error("single-file trees not yet implemented (for #{@path.pretty})")
        elsif test_dir_names.include?(@path.basename.to_s)
          y << Models::MyPathname.new(@path.to_s)
        else
          _n = test_dir_names.map { |x| "-name #{Shellwords.escape(x)}" }.join(' -o ')
          Open3.popen3("find #{@path.to_s.shellescape} -type dir \\( #{_n} \\)") do |_, sout, serr|
            '' == (e = serr.read) ? sout.each_line { |l| y << Models::MyPathname.new(l.chomp) } : error(e)
          end
        end
      end
    end
    def test_dir_names
      TEST_DIR_NAMES
    end
    def tree
      tree = tree_combined or return tree
      loc = ::Skylab::Porcelain::Tree::Locus.new
      loc.traverse(tree) do |node, meta|
        meta[:prefix] = loc.prefix(meta)
        meta[:node] = node
        emit(:tree_line_meta, meta)
      end
      true
    end
    def tree_combined
      tests = tree_of_tests or return false
      if 0 == tests.children_length # try to future-proof it.  careful!
        tests = Models::Node.new(root: true, slug: '(no tests)', type: :test)
      else
        tests = tests.find(@test_dir.to_s) or fail("truncation hack failed")
      end
      codes = tree_of_code or return false
      if 0 == codes.children_length # ditto above, test nodes w/ no code nodes
        _hack = true
        codes = Models::Node.new(root: true, slug: '(no code)', type: :code)
      else
        codes = codes.find(@test_dir.dirname.to_s) or fail("truncation hack failed")
      end
      # tell the tests tree that it follows the codes tree's structure by aliasing it
      tests.aliases = [codes.slug]
      both = Models::Node.combine([codes, tests],
        keymaker: ->(n) { [n.slug, *(n.aliases? ? n.aliases : [])].last } # use the last alias as the comparison key
      )
      both[:slug_dirname] = (_hack ? @test_dir.dirname : @test_dir.dirname.dirname).to_s
      both
    end
    def tree_of_code
      re = %r{^#{Regexp.escape @test_dir.to_s}/}
      paths = Dir["#{@test_dir.dirname}/**/*.rb"]
      paths = paths.select { |f| re !~ f }
      Models::Node.from_paths(paths){ |n| n[:type] = :code }
    end
    def tree_of_tests
      anchors = self.anchors.to_a
      case anchors.length
      when 0 ; return error("Couldn't find test directory: #{pre @path.join(test_dir_names.string).pretty}")
      when 1 ; anchor = anchors.first # and handled below
      else   ; fail("multiple anchor points not yet implemented (but soon!)")
      end
      @test_dir = anchor.dir # temporary!
      _test_file_paths = anchor.test_files.map { |f| f.pathname.to_s }
      Models::Node.from_paths(_test_file_paths) { |n| n[:type] = :test }
    end
  end
end

