module Skylab::GitViz

  module TestSupport

    module Mock_FS  # read [#013] the mock FS narrative #storypoint-5 (or not)

      def self.[] user_mod
        user_mod.module_exec do
          extend Module_Methods__
          include Instance_Methods__ ; nil
        end
      end

      module Instance_Methods__
        def mock_pathname path_s
          _fm = mock_FS
          _fm.touch_pn path_s
        end
        def mock_FS
          @mock_FS ||= rslv_mock_FS
        end
        def rslv_mock_FS
          pn = get_pathnames_manifest_pn
          mock_FS_proc[ pn ]
        end
        def get_pathnames_manifest_pn
          fixtures_module.dir_pathname.join 'pathnames.manifest'
        end
        def fixtures_module
          self.class.fixtures_mod
        end
        def mock_FS_proc
          self.class.mock_FS_p
        end
      end

      module Module_Methods__
        def fixtures_mod
          send( :nearest_test_node )::Fixtures  # covered
        end
        def mock_FS_p
          @mock_FS_p ||= Cache_.new
        end
      end

      class Cache_
        def initialize
          @h = {}
        end
        def [] pathname
          @h.fetch pathname.instance_variable_get( :@path ) do |path|
            @h[ path ] = FS_.new pathname
          end
        end
      end

      class FS_

        def initialize pn
          @self_reference = -> { self }
          init_tree pn
          init_pathname_pool ; nil
        end
      private
        def init_pathname_pool
          @pathname_pool_h = {} ; nil
        end
        def init_tree pn
          fs_p = -> { self }
          fh = pn.open 'r'
          _ea = Each__.new do |&p|
            line = fh.gets
            while line
              path_x =
                mutate_manifest_line_into_normd_path_and_get_tree_path line
              p[ Pathname_.new line, fs_p, path_x ]
              line = fh.gets
            end
            fh.close ; nil
          end
          @tree = GitViz::Porcelain::Tree.from :path_nodes, _ea ; nil
        end

        def mutate_manifest_line_into_normd_path_and_get_tree_path line
          # #storypoint-90
          line.chomp! ; line.freeze  # tiny optimization
          do_dir_hack = SEP_ == line.getbyte( -1 )
          norm_s = line.gsub WANKY_SEPARATOR_RX__, ''
          path_i_a = norm_s.split( SEPARATOR_STRING_, -1 ).map( & :intern )
          do_dir_hack and path_i_a << :'.'
          path_i_a
        end

      public

        def touch_pn path_x  # #storypoint #80
          path_x.respond_to? :to_str or
            raise Exception_for_not_string_[ path_x ]
          path_s = path_x.to_str
          pn = lookup_any_FS_pathname path_s
          pn or tch_cached_pn path_s
        end

        def does_path_s_exist path_s
          !! any_tree_node_with_path_s( path_s ) # #OCD
        end

        def is_path_s_directory path_s
          node = any_tree_node_with_path_s path_s
          if ! node
            false
          elsif node.children_count.zero?
            false
          else
            true
          end
        end

      private

        def lookup_any_FS_pathname path_s
          tree_node = any_tree_node_with_path_s path_s
          if tree_node
            _pn = tree_node.node_payload
            _pn or hack_add_dir_pathname tree_node, path_s
          end
        end
        def any_tree_node_with_path_s path_s
          _path_x = nrmlz_path_for_tree_lookup path_s
          @tree.fetch _path_x do end
        end
        def nrmlz_path_for_tree_lookup path_s
          path_s.gsub( WANKY_SEPARATOR_RX__, '' ).
            split( SEPARATOR_STRING_ ).map( & :intern )
        end

        def hack_add_dir_pathname tree_node, path_s
          pn = tch_cached_pn path_s
          tree_node.set_node_payload pn
          pn
        end
        def tch_cached_pn path_s
          @pathname_pool_h.fetch path_s do
            path_s.frozen? or path_s = path_s.dup.freeze
            @pathname_pool_h[ path_s ] = Pathname_.new path_s, @self_reference
          end
        end

        class Each__ < ::Proc
          alias_method :each, :call

        end

        WANKY_SEPARATOR_RX__ = %r((?<=/)/+|/+\z)
      end

      class Pathname_

        def initialize path_x, fs_p, tree_path_x=nil
          path_x.respond_to? :to_str or
            raise Exception_for_not_string_[ path_x ]
          unsanitized_s = path_x.to_str
          path_s = unsanitized_s.frozen? ? unsanitized_s :
            unsanitized_s.dup.freeze  # memory "optimization", may change
          @FS_p = fs_p
          @is_absolute = path_s.getbyte( 0 ) == SEP_  # str may be empty
          @has_trailing_slash = path_s.getbyte( -1 ) == SEP_
          @path = path_s
          @tree_path_x = tree_path_x || @path
          freeze
        end

        def relative?
          ! @is_absolute
        end

        def absolute?
          @is_absolute
        end

        def to_tree_path
          @tree_path_x
        end

        def to_s
          to_str
        end

        def to_str
          @path  # frozen means frozen so this might not comport #todo
        end

        def dirname
          inst_from_unsanitized ::File.dirname @path
        end

        def join * a  # #storypoint #155
          a.unshift self
          r = inst_from_unsanitized a.pop
          while a.length.nonzero? && ! r.absolute?
            _pn = inst_from_unsanitized a.pop
            r = _pn + r
          end
          r
        end

        def + other_x
          other_pn = inst_from_unsanitized other_x
          _path_s = Plus__[ @path, other_pn.path.dup ]
          inst_from_unsanitized _path_s
        end
        attr_reader :path ; protected :path

        Plus__ = ::Pathname.new( '' ).method :plus

        # ~ that talk to the FS

        def exist?
          _FS.does_path_s_exist @path
        end

        def directory?
          _FS.is_path_s_directory @path
        end

      private  # ~ :#ultra-private implementation methods used in > 1 place

        def inst_from_unsanitized x
          x.respond_to? :to_str or
            raise Exception_for_not_string_[ x ]
          _FS.touch_pn x.to_str
        end

        def _FS
          @FS_p[]
        end
      end

      Exception_for_not_string_ = -> x do
        ::TypeError.new "no implicit conversion of #{ Inspect__[ x ]} into String"
      end

      Inspect__ = -> x do  # :+[#mh-050] a challenger appears
        case x
        when ::NilClass, ::FalseClass, ::TrueClass ; x.inspect
        else x.class.name
        end
      end

      SEP_ = (( SEPARATOR_STRING_ = '/'.freeze )).getbyte 0

    end
  end
end
