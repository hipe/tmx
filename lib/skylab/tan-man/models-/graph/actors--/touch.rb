module Skylab::TanMan

  class Models_::Graph

    class Actors__::Touch  # ~:+[#049] algo family

      Actor_[ self, :properties,
        :is_dry_run,
        :action,
        :entity,
        :workspace,
        :kernel ]

      def execute

        arg = @entity.get_argument_via_property_symbol :digraph_path

        ok_arg = NORMALIZE_DIGRAPH_PATH_.normalize_argument arg, & @on_event_selectively

        ok_arg and begin
          @digraph_path = ok_arg.value_x
          via_digraph_path
        end
      end

      o = TanMan_.lib_.basic::Pathname.normalization

      NORMALIZE_DIGRAPH_PATH_ = o.build_with :absolute

      NORMALIZE_STARTER_FILE_ = o.build_with :relative, :downward_only

      def via_digraph_path
        @pn = ::Pathname.new @digraph_path
        via_pn_any_stat
        if @stat
          when_stat
        elsif @pn.extname.length.zero?
          add_extension_to_everything
          via_pn_any_stat
          if @stat
            when_stat
          else
            when_stat_e
          end
        else
          when_stat_e
        end
      end

      def via_pn_any_stat
        @stat_e, @stat = stat_e_and_stat_via_pn @pn ; nil
      end

      def when_stat
        if FILE__ == @stat.ftype
          when_pn_is_file
        else
          when_pn_is_not_file
        end
      end

      def when_pn_is_not_file
        maybe_send_event :error, :resource_is_wrong_shape do
          bld_resource_is_wrong_shape_event
        end
        UNABLE_
      end

      def bld_resource_is_wrong_shape_event
        build_not_OK_event_with :resource_is_wrong_shape,
            :pathname, @pn, :shape, @stat.ftype do | y, o |

          y << "expected #{ val FILE__ } had #{ ick o.shape } #{
            }- #{ pth o.pathname }"
        end
      end

      FILE__ = 'file'.freeze

      def add_extension_to_everything
        @ext = EXT__
        maybe_send_adding_ext
        @digraph_path = "#{ @digraph_path }#{ EXT__ }"
        @entity.properties.replace :digraph_path, @digraph_path
        @pn = @pn.sub_ext @ext ; nil
      end

      EXT__ = '.dot'.freeze

      def maybe_send_adding_ext
        maybe_send_event :info, :adding_extensio do
          bld_adding_extension_event
        end
      end

      def bld_adding_extension_event

        build_neutral_event_with :adding_extension,
            :extension, @ext, :from_pn, @pn do |y, o|

          y << "adding #{ o.extension } extension to #{ pth o.from_pn }"
        end
      end

      def when_stat_e  # pn not exist
        @dpn = @pn.dirname
        @dpn_stat_e, @dpn_stat = stat_e_and_stat_via_pn @dpn
        if @dpn_stat
          when_dpn_stat
        else
          when_dpn_stat_e
        end
      end

      def stat_e_and_stat_via_pn pn
        [ nil, pn.stat ]
      rescue ::Errno::ENOENT => e
        [ e, false ]
      end

      def when_dpn_stat_e
        maybe_send_event :error, :resource_not_found do
          bld_resource_not_found_event
        end
        UNABLE_
      end

      def bld_resource_not_found_event

        Callback_::Event.wrap.exception @dpn_stat_e,
          :path_hack,
          :terminal_channel_i, :resource_not_found
      end

      def when_pn_is_file
        ACHIEVED_
      end

      def when_dpn_stat
        if DIRECTORY_FTYPE__ == @dpn_stat.ftype
          when_dpn_is_dir
        else
          self._TO_DO_when_dpn_is_not_dir
        end
      end
      DIRECTORY_FTYPE__ = 'directory'.freeze

      def when_dpn_is_dir
        @ws = @action.preconditions.fetch :workspace
        @value_fetcher = Value_Fetcher_Shell___.new Value_Fetcher_Kernel___.new @action
        @lines = via_ws_expect_lines
        @lines ||= any_lines
        @lines and via_lines
      end

      def via_ws_expect_lines

        # first, use any starter indicated in the workspace

        @kernel.call :starter, :lines,
          :value_fetcher, @value_fetcher,
          :workspace, @ws,
          & @on_event_selectively
      end

      def any_lines

        # if no starter is indicated in the workspace, use default

        @kernel.call :starter, :lines,
          :value_fetcher, @value_fetcher,
          :use_default, true,
          & @on_event_selectively
      end

      def via_lines

        is_dry = @is_dry_run
        _opener = if is_dry
          TanMan_.lib_.dry_stub
        else
          @pn
        end
        bytes = 0
        _opener.open WRITEMODE_ do |io|
          while line = @lines.gets
            bytes += io.write line
          end
        end
        maybe_send_event :info, :wrote_file do
          bld_wrote_file_event bytes, is_dry
        end
        bytes
      end

      WRITEMODE_ = 'w'.freeze

      def bld_wrote_file_event bytes, is_dry

        build_OK_event_with :wrote_file,
            :is_dry, is_dry,
            :path, @pn.to_path, :bytes, bytes do |y, o|

          o.is_dry and _dry = " dry"
          y << "wrote #{ pth o.path } (#{ o.bytes }#{ _dry } bytes)"
        end
      end

      class Value_Fetcher_Shell___

        # used by the template renderer to render its values

        def initialize k
          @kernel = k
        end

        def fetch i
          @kernel.__send__ i
        end
      end

      class Value_Fetcher_Kernel___ < ::BasicObject

        # the internal structure that effects the composition
        # of available template value names for the above shell

        def initialize provider
          @provider = provider
        end

        def created_on
          @provider.template_value :created_on_timestamp_string
        end
      end
    end
  end
end
