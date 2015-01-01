module Skylab::Snag

  class Models::Manifest  # [#038]

    class << self

      def build_silo _API_client
        Silo__.new _API_client
      end

      def build_file pathname
        self::File__.new pathname
      end

      def header_width
        HEADER_WIDTH__
      end
      HEADER_WIDTH__ = '[#867] '.length

      def line_width
        LINE_WIDTH__
      end
      LINE_WIDTH__ = 80
    end

    def initialize _API_client, path_x
      @API_client = _API_client
      @manifest_file = nil
      path_x or self._SANITY
      @pathname = ::Pathname.new path_x
      @tmpdir_pathname = nil
    end

    attr_reader :pathname

    def node_collection
      @node_collection ||= Models::Node.build_collection self, @API_client
    end

    def curry_scan * x_a
      scan = self.class::Node_Scan__.new
      scan.absorb_iambic_fully x_a
      scan
    end

    def add_node node, dry_run, verbose_x
      self::class::Node_add__[ node, agnt_adapter, node.delegate,
        :is_dry_run, dry_run,
        :verbose_x, verbose_x ]
    end

    def change_node node, dry_run, verbose_x
      self::class::Node_edit__[ node, agnt_adapter, node.delegate,
        :is_dry_run, dry_run,
        :verbose_x, verbose_x ]
    end

    def manifest_file
      manifest_file_for_agent
    end

  private

    def agnt_adapter
      @agnt_adapter ||= bld_agent_adapter
    end

    def bld_agent_adapter
      self.class::Agent_Adapter__.new(
        :all_nodes, method( :all_nodes_for_agent ),
        :file_utils, method( :build_file_utils_for_agent_via_iambic_stream ),
        :manifest_file, method( :manifest_file_for_agent ),
        :render_line_a, method( :render_line_a_for_agent ),
        :produce_tmpdir, method( :produce_tmpdir_via_iambic_for_agent ) )
    end

    def all_nodes_for_agent
      manifest_file_for_agent
      Models::Node.build_scan_from_lines @manifest_file.normalized_line_producer
    end

    def build_file_utils_for_agent_via_iambic_stream st  # (was #note-75)
      Build_file_utils_curry__.new( st ).execute
    end

    def manifest_file_for_agent
      @manifest_file ||= Manifest_.build_file @pathname
    end

    def render_line_a_for_agent identifier_d, node
      identifier_d and node.init_identifier identifier_d, ID_NUM_DIGITS__
      line_a = [ "#{ node.identifier.render } #{ node.first_line_body }" ]
      line_a.concat node.extra_line_a
      line_a
    end
    ID_NUM_DIGITS__ = 3

    def produce_tmpdir_via_iambic_for_agent x_a
      @tmpdir_pathname ||= Snag_.lib_.tmpdir_pathname.join TMP_DIRNAME_
      self.class::Tmpdir_produce__[ :tmpdir_pathname, @tmpdir_pathname, * x_a ]
    end

    Entity_ = -> client, _fields_, * field_i_a do
      :fields == _fields_ or raise ::ArgumentError
      Snag_.lib_.basic_fields :client, client,
        :absorber, :initialize,
        :field_i_a, field_i_a
    end

    class Build_file_utils_curry__

      Callback_::Actor[ self, :properties, :be_verbose, :delegate ]

      def initialize st
        process_iambic_stream_fully st
      end

      def execute
        Snag_.lib_.FUC.new -> s do
          if @be_verbose
            @delegate.receive_info_event Hacky_Path_Event__.new s
          end
        end
      end
    end

    Hacky_Path_Event__ = Snag_::Model_::Event.new :line do

      message_proc do |y, o|  # escape things that look like abs paths

        y << ( o.line.gsub Snag_.lib_.path_tools.absolute_path_hack_rx do
          pth ::Pathname.new $~[ 0 ]
        end )

      end
    end

    class Agent_

      Snag_.lib_.funcy_globless self

    private

      def bork_via_event ev
        @delegate.receive_error_event ev
      end

      def send_info_string s
        @delegate.receive_info_string s
      end
    end

    class Silo__

      def initialize _API_client
        @API_client = _API_client
        @cache_h = {}
      end

      def if_manifest_for_working_dir path, yes_p, no_p
        if @cache_h.key? path
          yes_p[ @cache_h.fetch path ]
        else
          Build__.new( path, yes_p, no_p, @cache_h, @API_client ).lookup
        end
      end

      class Build__

        def initialize *a
          @path, @yes_p, @no_p, @cache_h, @API_client = a
        end

        def lookup
          @config = @API_client
          @did_fail = false
          @pathname = bld_walk.find_any_nearest_file_pathname
          if @did_fail
            @no_p[ @ev ]
          else
            when_found
          end
        end

        def bld_walk

          _oes_p = -> * i_a, & ev_p do
            if :error == i_a.first
              recv_walk_error_event ev_p[]
            end
          end

          Snag_.lib_.system.filesystem.walk.build_with(
            :filename, @config.manifest_file,
            :max_num_dirs_to_look,
              @config.max_num_dirs_to_search_for_manifest_file,
            :property_symbol, :path,
            :start_path, @path,
            :on_event_selectively, _oes_p )
        end

        def recv_walk_error_event ev
          o = Snag_::Model_::Event.inflectable_via_event ev
          o.inflected_verb = 'find'
          o.inflected_noun = 'manifest file'
          @ev = Routing_Wrapper__[ :error_event, o ]
          @did_fail = true ; nil
        end

        def when_found
          mani = Models::Manifest.new @API_client, @pathname
          @cache_h[ @path ] = mani
          @yes_p[ mani ]
        end
      end

      Routing_Wrapper__ = ::Struct.new :channel_i, :ev do
        alias_method :unwrap, :values
      end
    end

    Manifest_ = self

    TMP_DIRNAME_ = 'snag-production-tmpdir'
  end
end
