module Skylab::CovTree

  class API::Actions::Tree < API::Action

    emits :anchor_point,
      :error,
      :info,
      :number_of_test_files,
      :test_file,
      :tree_line_meta



    params = ::Struct.new :list_as, :path, :verbose

    define_method :invoke do |params_h|
      p = params.new
      params_h.each { |k, v| p[k] = v }
      @list_as = p[:list_as] # nil ok
      self.path = p[:path] || '.'
      @verbose = p[:verbose]
      res = nil
      if last_error_message # #todo vodoo?
        res = false
      elsif list_as
        res = list
      else
        res = tree
      end
      res
    end



  protected


    def initialize request_client
      @last_error_message = nil
      super request_client
    end


    globs = CovTree::FUN.globs

    define_method :anchors do
      ::Enumerator.new do |y|
        test_dirs.each do |dir|
          baseglob = globs[ dir.basename.to_s ]
          baseglob or fail "unexepected: #{ dir.basename }"
          sub_dir = dir
          if sub_path
            sub_dir = dir.join( sub_path.join '/' )
          end
          glob = sub_dir.join( "**/#{ baseglob }" ).to_s
          ee = ::Enumerator.new do |yy|
            ::Dir[ glob ].each do |path|
              spec_pathname = ::Pathname.new path
              shortpath = spec_pathname.relative_path_from sub_dir
              yy << shortpath
            end
          end
          y << CovTree::Models::Anchor.new( dir, sub_path, ee )
        end
      end
    end


    attr_reader :last_error_message


    def list
      num = 0
      anchors.each do |anchor|
        emit :anchor_point, anchor_point: anchor
        anchor.test_file_short_pathnames.each do |shpn|
          num += 1
          emit :test_file, anchor: anchor, short_pathname: shpn
        end
      end
      res = nil
      if last_error_message
        res = false
      else
        emit :number_of_test_files, number: num
        res = true
      end
      res
    end


    attr_accessor :list_as


    strip_trailing_rx = %r{ \A (?<no_trailing> / | .* [^/] ) /* \z }x

    define_method :path= do |x|   # strip trailing slashes from paths.
      begin                       # allows you to set the path to nil or false,
        if ! x                    # but fails on the empty string.
          @pathname = x
          break
        end
        md = strip_trailing_rx.match x.to_s
        if ! md
          error "Your path looks funny: #{ x.inspect }"
          break
        end
        @pathname = ::Pathname.new md[:no_trailing]
      end while nil
      x
    end

    attr_reader :pathname

    fun = CovTree::FUN                         # (i anticipate needing to un-
    test_dir_names = fun.test_dir_names        # memoize these things when
                                               # they become configurable ..)

    soft_rx = %r{(?:#{ test_dir_names.map{ |x| ::Regexp.escape x }.join '|' })}
    hard_rx = %r{ \A #{ soft_rx.source } \z }x
    stop_rx = fun.stop_rx

    define_method :pathname_is_subtree_of_test_dir! do # this has side effects..
      res = nil                                # does our pathname look like
      begin                                    # it might contain a test-dir
        soft_rx =~ pathname.to_s or break      # in it? (short-circuiting this
        current = pathname                     # might be silly)
        seen = []
        found = true
        while stop_rx !~ current.to_s
          basename = current.basename
          if hard_rx =~ basename.to_s
            found = true
            break
          end
          seen.push basename.to_s
          current = current.dirname
        end
        found or break
        @sub_path = seen.reverse                # (empty iff test dir was first
        res = current                           # the first one we saw)
      end while nil
      res
    end

    attr_reader :sub_path

    define_method :test_dir_names do
      test_dir_names
    end

    def test_dirs                              # result is an enumerator that
                                               # will enumerate every pathname
      ::Enumerator.new do |y|                  # that looks like it is a test
                                               # directory from our `path`
        begin
          if ! pathname.exist?
            error "no such directory: #{ escape_path pathname }"
            break
          end
          if ! pathname.directory?
            error "single file trees not yet implemented #{
              }(for #{ escape_path pathname })"
            break
          end
          if test_dir_names.include? pathname.basename.to_s # this pathname
            y << pathname                      # itself looks like a test dir,
            break                              # e.g. it is named /foo/bar/test
          end
          pathnm = pathname_is_subtree_of_test_dir! # if our pathname is inside
          if pathnm                            # of what looks like a testdir,
            y << pathnm                        # e.g. "test/api/actions", then
            break                              # we do something special..
          end
          test_dirs_using_find y               # last resort, use find
        end while nil
      end # ::Enumerator.new
    end

    def test_dirs_using_find y    # Now we can assume we are a directory that
                                  # itself is not a test directory. So what we
                                  # want to do is find those nerks! with
      # a find command (which [#sl-118] might get unified but not today)

      CovTree::Services::Shellwords || nil # ick load it our way

      cmd = -> do
        ors = test_dir_names.map { |x| "-name #{ x.to_s.shellescape }" }
        ors = ors.join ' -o '
        "find #{ pathname.to_s.shellescape } -type dir \\( #{ ors } \\)"
      end.call

      if verbose
        emit :info, cmd
      end

      CovTree::Services::Open3.popen3 cmd do |_, sout, serr|
        e = serr.read
        if '' == e
          sout.each_line do |line|
            o = ::Pathname.new line.chomp
            y << o
          end
        else
          error e
        end
      end
      nil
    end

    def tree
      res = false
      begin
        anchors_a = self.anchors.to_a
        case anchors_a.length
        when 0
          path = pathname.join test_dir_names.string
          error "Couldn't find test directory: #{ pre escape_path( path ) }"
          break
        when 1
          uber_tree = anchors_a.first.tree_combined
        else
          tt = anchors_a.map(& :tree_combined)
          a = pathname.to_s.split tt.first.path_separator
          need = a.first
          tt.each do |t|
            if t.isomorphic_slugs.last != need
              t.isomorphic_slugs.push need
            end
          end
          uber_tree = tt.first.class.combine(* tt) do |t|
            t.isomorphic_slugs.last
          end
        end
        loc = Porcelain::Tree::Locus.new
        loc.traverse uber_tree do |node, meta|
          meta[:prefix] = loc.prefix meta
          meta[:node] = node
          emit :tree_line_meta, meta
        end
        res = true
      end while nil
      res
    end

    attr_reader :verbose
  end
end
