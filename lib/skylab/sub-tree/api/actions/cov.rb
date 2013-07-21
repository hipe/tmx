module Skylab::SubTree

  class API::Actions::Cov < API::Action

    emits       hub_point: :datapoint,
                    error: :datapoint,
                     info: :datapoint,
     number_of_test_files: :datapoint,
                test_file: :structural,
           tree_line_card: :datapoint,
                info_tree: :structural


    MetaHell::FUN::Fields_[ :client, self, :method, :absorb, :field_i_a,
                            [ :list_as, :path, :be_verbose ] ]

    def initialize request_client
      super
      @last_error_message = @sub_path_a = @lister = nil
    end

    def prepare *a
      absorb( *a )
      normalize_arg_pn @path
      if ! @last_error_message && @list_as
        normalize_list_as
      end
      nil
    end

    def execute
      if ! @last_error_message
        if @list_as
          r = execute_lister_and_resolve
          r and r = send( r )  # e.g `tree` - same as below
        else
          r = tree
        end
      end
      r
    end

    def get_mutex_list_as
      @lister and @lister.get_mutex_list_as
    end

  private

    def normalize_arg_pn x
      use_x = x || ''
      begin
        (( md = STRIP_TRAILING_RX_.match use_x )) or break error "your #{
            }path looks funny - #{ x.inspect }"
        @arg_pn = ::Pathname.new md[ :no_trailing ]
      end while nil
      nil
    end

    STRIP_TRAILING_RX_ = %r{ \A (?<no_trailing> / | .* [^/] ) /* \z }x

    def normalize_list_as
      @lister = self.class::Lister_.new :emit_p, method( :emit ),
        :list_as, @list_as, :hubs, hub_a,
        :did_error_p, -> { @last_error_message }
      @lister.normalize
    end

    def execute_lister_and_resolve
      @lister.execute_and_resolve
    end

    def hub_a
      @hub_a ||= get_hubs.to_a
    end

    def get_hubs
      ::Enumerator.new do |y|
        test_dir_a = test_dirs.to_a
        test_dir_a.each do |dir|
          baseglob = GLOB_H_.fetch dir.basename.to_s
          sub_dir = dir
          @sub_path_a and sub_dir = dir.join( @sub_path_a * SEP_ )
          glob = sub_dir.join( "**/#{ baseglob }" ).to_s
          y << SubTree::Models::Hub.new(
            :test_dir_pn, dir,
            :sub_path_a, @sub_path_a,
            :lister_p, -> { @lister },
            :info_tree_p, -> label, tree do
              emit :info_tree, label: label, tree: tree
            end,
            :local_test_pathname_ea, ::Enumerator.new do |yy|
              ::Dir[ glob ].each do |path|
                spec_pathname = ::Pathname.new path
                shortpath = spec_pathname.relative_path_from sub_dir
                yy << shortpath
              end
            end )
          nil
        end
        nil
      end
    end

    GLOB_H_ = SubTree::PATH.glob_h

    # result is an enumerator over every pathname that looks like it is
    # a test directory from our `path`

    def test_dirs
      ::Enumerator.new do |y|
        begin
          (( pn = @arg_pn )).exist? or break error "no such #{
            }directory: #{ escape_path pn }"

          pn.directory? or break error "single file trees not yet #{
            }implemented (for #{ escape_path pn })"

          TEST_DIR_NAME_A_.include?( pn.basename.to_s ) and break( y << pn )
            # if pn looks like foo/bar/test then we are done

          (( pn_ = mutate_if_test_subnode )) and break( y << pn_ )
            # if pn looks like test/cli then

          find_with_find y

        end while nil
      end
    end

    TEST_DIR_NAME_A_ = SubTree::Constants::TEST_DIR_NAME_A

    def mutate_if_test_subnode
      begin
        SOFT_RX_ =~ @arg_pn.to_s or break    # is test dir in the path?
        curr = @arg_pn ; seen_a = [ ] ; found = false
        until Stop_at_pathname_[ curr ]
          bn = curr.basename
          HARD_RX_ =~ bn.to_s and break( found = true )  # is the test dir?
          seen_a << bn.to_s
          curr = curr.dirname
        end
        found or break
        @sub_path_a and fail "sanity"  # #todo - when?
        @sub_path_a = seen_a.reverse # empty iff test dir was first dir
        r = curr
      end while nil
      r
    end

    def find_with_find y
      self.class::Finder_[ :yielder, y, :error_p, method( :error ),
        :info_p, -> s { emit :info, s } , :find_in_pn, @arg_pn,
        :be_verbose, @be_verbose ]
    end

    SOFT_RX_ = %r{(?:#{
      TEST_DIR_NAME_A_.map( & ::Regexp.method( :escape ) ) * '|'
    })}

    HARD_RX_ = %r{ \A #{ SOFT_RX_.source } \z }x

    def tree
      if hub_a.length.zero?
        error "Couldn't find test directory: #{ pre escape_path(
          @arg_pn.join SubTree::PATH.test_dir_names_moniker ) }"
        false
      else
        self.class::Treeer_[ :hub_a, hub_a, :arg_pn, @arg_pn,
          :card_p, -> card { emit :tree_line_card, card } ]
      end
    end
  end
end
