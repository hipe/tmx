module Skylab::GitViz

  module Test_Lib_

    module Mock_FS  # read [#013] the mock FS narrative #storypoint-5 (or not)

      class << self

        def [] mod
          mod.include Instance_Methods__
          nil
        end
      end  # >>

      module Instance_Methods__

        def mock_pathname path_s
          mock_FS.touch_pn path_s
        end

        def mock_FS
          @__mock_FS__ ||= __produce_mock_FS
        end

        def __produce_mock_FS

          path = send :manifest_path_for_mock_FS  # #:+#hook-out

          cache = send :cache_hash_for_mock_FS  # #:+#hook-out

          mock_FS = cache[ path ]

          if ! mock_FS
            mock_FS = Mock_FS___.new path
            cache[ path ] = mock_FS
          end

          mock_FS
        end
      end

      class Mock_FS___

        def initialize path

          fs_p = -> { self }

          fh = ::File.open path, ::File::RDONLY

          _ea = Each_Proxy___.new do | & yield_p |

            begin
              line = fh.gets
              line or break
              line.chop!
              line.freeze

              yield_p[ Pathname__.new( line, fs_p, __produce_tree_path( line ) ) ]

              redo
            end while nil

          end

          @tree = GitViz_.lib_.tree.from :node_identifiers, _ea

          fh.close

          @pathname_pool_h = {}

          @FS_p = -> { self }
        end

        class Each_Proxy___ < ::Proc
          alias_method :each, :call
        end

        def __produce_tree_path line  # #storypoint-90

          is_dir = SEPARATOR_BYTE__ == line.getbyte( -1 )

          path_i_a = line.gsub( ABNORMAL_SEPARATOR_RX__, EMPTY_S_ ).
            split( ::File::SEPARATOR, -1 ).map( & :intern )

          is_dir and path_i_a.push :'.'

          path_i_a
        end

      public

        def touch_pn path_x  # #storypoint #80
          path_x.respond_to? :to_str or
            raise Exception_for_not_string__[ path_x ]
          path_s = path_x.to_str
          pn = lookup_any_FS_pathname path_s
          pn or tch_cached_pn path_s
        end

        def get_some_mock_stat_of_path_s path_s
          path_s = path_s.to_str
          tn = any_tree_node_with_path_s path_s
          if tn
            Mock_Stat___.new tn.is_branch ? :directory_ftype : :file_ftype
          else
            raise ::Errno::ENOENT, path_s
          end
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
          path_s.gsub( ABNORMAL_SEPARATOR_RX__, EMPTY_S_ ).
            split( ::File::SEPARATOR ).map( & :intern )
        end

        def hack_add_dir_pathname tree_node, path_s
          pn = tch_cached_pn path_s
          tree_node.set_node_payload pn
          pn
        end
        def tch_cached_pn path_s
          @pathname_pool_h.fetch path_s do
            path_s.frozen? or path_s = path_s.dup.freeze
            @pathname_pool_h[ path_s ] = Pathname__.new path_s, @FS_p
          end
        end

        ABNORMAL_SEPARATOR_RX__ = %r((?<=/)/+|/+\z)
      end

      class Pathname__

        def initialize path_x, fs_p, tree_path_x=nil
          path_x.respond_to? :to_str or
            raise Exception_for_not_string_[ path_x ]
          unsanitized_s = path_x.to_str
          path_s = unsanitized_s.frozen? ? unsanitized_s :
            unsanitized_s.dup.freeze  # memory "optimization", may change
          @FS_p = fs_p
          @is_absolute = path_s.getbyte( 0 ) == SEPARATOR_BYTE__  # str may be empty
          @has_trailing_slash = path_s.getbyte( -1 ) == SEPARATOR_BYTE__
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

        def to_path
          to_str  # see
        end

        def to_s
          to_str  # see
        end

        def to_str
          @path  # frozen means frozen, so this does not comport with
          # stdlib Pathname but we leave it here to detect suspicious mutation
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

        def relative_path_from x
          x.respond_to?( :cleanpath ) or x = ::Pathname.new( x )
          _pn = ::Pathname.new( @path ).relative_path_from x
          inst_from_unsanitized _pn.instance_variable_get :@path
        end

        # ~ that talk to the FS

        def stat
          _FS.get_some_mock_stat_of_path_s @path
        end

        def exist?
          _FS.does_path_s_exist @path
        end

        def directory?
          _FS.is_path_s_directory @path
        end

        # ~ in-universe #hook-in's

        def description  # for :+[#cb-010]
          "«mock pathname: #{ @path }»"  # :+#guillemets
        end

      private  # ~ :#ultra-private implementation methods used in > 1 place

        def inst_from_unsanitized x
          x.respond_to? :to_str or
            raise Exception_for_not_string__[ x ]
          _FS.touch_pn x.to_str
        end

        def _FS
          @FS_p[]
        end
      end

      class Mock_Stat___

        def initialize ftype_i
          send :"__receive_ftype_of__#{ ftype_i }__" ; nil
        end

        attr_reader :ftype

        def __receive_ftype_of__directory_ftype__
          @ftype = DIRECTORY_FTYPE___ ; nil
        end

        DIRECTORY_FTYPE___ = 'directory'.freeze

        def __receive_ftype_of__file_ftype__
          @ftype = FILE_FTYPE___
        end

        FILE_FTYPE___ = 'file'.freeze
      end

      Exception_for_not_string__ = -> x do
        ::TypeError.new "no implicit conversion of #{ Typeish___[ x ]} into String"
      end

      Typeish___ = -> x do  # :+[ba-019]-like but for types not value
        case x
        when ::NilClass, ::FalseClass, ::TrueClass ; x.inspect
        else x.class.name
        end
      end

      SEPARATOR_BYTE__ = ::File::SEPARATOR.getbyte 0

    end
  end
end
