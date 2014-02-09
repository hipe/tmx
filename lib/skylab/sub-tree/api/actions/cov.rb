module Skylab::SubTree

  class API::Actions::Cov < API::Action

    listeners_digraph hub_point: :datapoint,
                    error: :datapoint,
                     info: :datapoint,
     number_of_test_files: :datapoint,
                test_file: :structural,
           tree_line_card: :datapoint,
                info_tree: :structural


    Lib_::Fields_via[ :client, self, :method, :absorb, :field_i_a,
                            [ :list_as, :path, :be_verbose ] ]

    def initialize
      @error_was_emitted = @sub_path_a = @lister = nil
    end

    def init_for_invocation_with_services svcs
      ep, ip = svcs.at :error, :info
      ip and on_info ip
      ep and on_error ep
      self
    end

    def prepare *a
      absorb( *a )
      normalize_arg_pn @path
      if ! @error_was_emitted && @list_as
        normalize_list_as
      end
      nil
    end

    def execute
      if ! @error_was_emitted
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
      @lister = self.class::Lister_.new :emit_p, method( :call_digraph_listeners ),
        :list_as, @list_as, :hubs, hub_a,
        :did_error_p, -> { @error_was_emitted }
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
        err = upstream.test_dir_pathnames.each do |dir|
          baseglob = GLOB_H_.fetch dir.basename.to_s
          sub_dir = dir
          @sub_path_a and sub_dir = dir.join( @sub_path_a * SEP_ )
          glob = sub_dir.join( "**/#{ baseglob }" ).to_s
          y << SubTree::Models::Hub.new(
            :test_dir_pn, dir,
            :sub_path_a, @sub_path_a,
            :lister_p, -> { @lister },
            :info_tree_p, -> label, tree do
              call_digraph_listeners :info_tree, label: label, tree: tree
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
        error err if err
        nil
      end
    end
    #
    GLOB_H_ = SubTree::PATH.glob_h

    def upstream
      @upstream ||= begin
        if @arg_pn
          self.class::Upstream_::From_::Filesystem_.new :arg_pn, @arg_pn,
            :info_p, get_info_p, :be_verbose, ( @be_verbose || false )
        else
          fail "implement me"
        end
      end
    end

    def get_info_p
      -> s { call_digraph_listeners :info, s }
    end

    def tree
      if hub_a.length.zero?
        error No_Directory__.new @arg_pn
        false
      else
        self.class::Treeer_[ :hub_a, hub_a, :arg_pn, @arg_pn,
          :card_p, -> card { call_digraph_listeners :tree_line_card, card } ]
      end
    end

    class Message_
      class << self ; alias_method :orig_new, :new end
      def self.new &p
        ::Class.new self do
          const_set :P__, p
          class << self ; alias_method :new, :orig_new end
          self
        end
      end
      def initialize * a
        @a = a ; nil
      end
      attr_reader :a
      def p ; self.class::P__ end
    end

    No_Directory__ = Message_.new do |pn|
      "Couldn't find test directory: #{ ick escape_path(
        pn.join SubTree::PATH.test_dir_names_moniker ) }"
    end

    def say * actual_arg_a, & p
      fail 'whet'
      Messages_[ p ].new( * actual_arg_a )
    end

    TEST_DIR_NAME_A_ = SubTree::Constants::TEST_DIR_NAME_A
    #
    SOFT_RX_ = %r{(?:#{
      TEST_DIR_NAME_A_.map( & ::Regexp.method( :escape ) ) * '|'
    })}
    #
    HARD_RX_ = %r{ \A #{ SOFT_RX_.source } \z }x

    Cov = self

  end
end
