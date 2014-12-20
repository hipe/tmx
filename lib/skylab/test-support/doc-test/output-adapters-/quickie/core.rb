module Skylab::TestSupport

  module DocTest

    class Output_Adapters_::Quickie < DocTest_::Output_Adapter_

      include Lazy_Selective_Event_Methods_

      class << self

        def output_adapter is_known_dry, & oes_p  # #hook-out
          new do
            @is_known_dry = is_known_dry  # cosmetic only!
            @on_event_selectively = oes_p
          end
        end

        private :new
      end

      Callback_::Actor.methodic self, :simple, :properties,

        :property, :business_module_name,
        :property, :line_downstream,
        :property, :node_upstream,
        :property, :on_shared_resources_created,
        :property, :arbitrary_proc_array,
        :property, :shared_resources

      def initialize
        @arbitrary_proc_array = nil
        @do_coverage_part = false  # :+#re-init
        @marginated_pre_body_string = nil
        @subsystem_index = 1
        @template_var_bx = nil
        super
      end

    private

      def execute  # #hook-out
        @node = @node_upstream.gets
        if @node
          when_node
        else
          when_no_nodes
        end
      end

      # ~

      def when_node
        ok = normalize
        ok && prepare
        ok &&= arbitraries
        ok && write_document
      end

      # ~ prepare

      def prepare
        resolve_shared_resources
        init_view_controller
        load_templates
        init_margination_ivars
        nil
      end

      def load_templates

        @base_when_not_do_regret_setup, @base_when_do_regret_setup,

        @bef_template, @ctx_template, @tst_template =

          templates( :_sibling, :_base, :_bef, :_ctx, :_tst )

        @will_do_regret_setup = false
        @base_template = @base_when_not_do_regret_setup

        nil
      end

      def init_margination_ivars

        struct = @shared_resources.cached :__shared_margination__ do

          o = Margination__.new

          s = template( :_base ).first_margin_for :pre_body

          o.common_margin_ = s

          o.st_ = Build_common_marginated_line_downtream_[ s ]

          o
        end

        @marginating_body_line_downstream = struct.st_

        @marg = struct.common_margin_

        nil
      end

      Margination__ = ::Struct.new :st_, :common_margin_

      # ~ normalize

      def normalize
        normalize_business_module_name
      end

      def normalize_business_module_name
        @num_subsystem_parts = @subsystem_index + 1
        s_a = @business_module_name.split CONST_SEP_
        s_a.first.length.zero? and s_a.shift  # normalize out full qualification
        if s_a.length < @num_subsystem_parts
          when_short_business_module_name
        else
          @business_const_s_a = s_a.freeze
          ACHIEVED_
        end
      end

      def when_short_business_module_name
        maybe_send_event :error, :shallow_business_module_name do
          bld_shallow_business_module_name
        end
        UNABLE_
      end

      def bld_shallow_business_module_name
        build_not_OK_event_with :shallow_business_module_name,
            :module_name, @business_module_name,
            :min_parts, @num_subsystem_parts do |y, o|
          y << "business module name is too shallow. we need at least #{
          }#{ o.min_parts } parts to the module name - #{ ick o.module_name }"
        end
      end

      # ~ arbitraries

      def arbitraries
        if @arbitrary_proc_array
          arbitrary_normalizations
        else
          ACHIEVED_
        end
      end

      def arbitrary_normalizations
        ok = true
        @arbitrary_proc_array.each do | p |
          ok = p[ self ]
          ok or break
        end
        ok
      end

    public  # for above

      def in_pre_body & receive_yielder_p

        to_join = []
        p = -> line do
          to_join.push line
          p = -> line_ do
            to_join.push "#{ @marg }#{ line_ }"
            nil
          end
          nil
        end

        receive_yielder_p.call(
          ::Enumerator::Yielder.new do | line |
            p[ line ]
          end )

        to_join.push @marg

        @marginated_pre_body_string = to_join.join NEWLINE_

        ACHIEVED_
      end

      def receive_template_variable sym, x
        @template_var_bx ||= Callback_::Box.new
        @template_var_bx.set sym, x
        ACHIEVED_
      end

      def receive_do_regret_setup yes_do
        if yes_do
          if ! @will_do_regret_setup
            @base_template = @base_when_do_regret_setup
            @will_do_regret_setup = false
          end
        elsif @will_do_regret_setup
          @base_template = @base_when_not_do_regret_setup
          @will_do_regret_setup = true
        end
        ACHIEVED_
      end

      Chomp_trailing_underscores__ = -> s do
        s.sub NO_TRAILING_RX___, EMPTY_S_
      end

      NO_TRAILING_RX___ = /_+$/

      define_method :chomp_trailing_underscores, Chomp_trailing_underscores__

    private

      # ~ write document

      def write_document
        init_document_context
        _ok = resolve_marginated_body_string
        _ok && assemble_document
      end

      def init_document_context
        @doc_ctx = Shared_Resources_.new
        @doc_ctx.cache :context_count, 0
        nil
      end

      def resolve_marginated_body_string

        begin
          via_node_and_marginated_body_line_downstream_render
          @node = @node_upstream.gets
        end while @node

        s = @marginating_body_line_downstream.flush

        if s.length.nonzero?
          @marginated_body_string = s
          ACHIEVED_
        else
          UNABLE_
        end
      end

      def via_node_and_marginated_body_line_downstream_render

        o = view_controller_for_node_symbol @node.node_symbol
        if o
          o.render( @marginating_body_line_downstream, @doc_ctx, @node )
        end

        nil
      end

      def assemble_document

        @amod, @bmod, @cmod = business_module_name_as_three_name_parts

        @acon = @business_const_s_a.fetch @subsystem_index

        @do_coverage_part and _newlined_and_marginated_coverage_part = rndr_cvg

        _desc = description_string

        _whole_string = @base_template.call(
          ts_relpath: some_test_support_relpath,
          acon: @acon,
          amod: @amod,
          bmod: @bmod,
          cmod: @cmod,
          pre_body: @marginated_pre_body_string,
          body: @marginated_body_string,
          cover: _newlined_and_marginated_coverage_part,
          desc: _desc )

        _any_result_for_write_to_line_downstream_whole_string _whole_string
      end

      def some_test_support_relpath
        if @template_var_bx
          x = @template_var_bx[ :require_test_support_relpath ]
        end
        x || DEFAULT_TEST_SUPPORT_RELPATH__
      end

      DEFAULT_TEST_SUPPORT_RELPATH__ = TestSupport_::Init.test_support_filestem

      def _any_result_for_write_to_line_downstream_whole_string whole_string

        o = TestSupport_::Lib_::String_lib[].line_stream whole_string

        bytes = 0 ; lines = 0
        while line = o.gets
          lines += 1
          bytes += line.length
          @line_downstream.puts line
        end

        maybe_send_event :success, :wrote do
          Event_for_Wrote_[ @is_known_dry, bytes, lines ]
        end
      end

      def business_module_name_as_three_name_parts
        s_a = @business_const_s_a.map do |const_s|
          Chomp_trailing_underscores__[ const_s ]
        end
        a = ::Array.new 3
        a[ 0 ] = s_a[ 0, @num_subsystem_parts ] * CONST_SEP_
        a[ 2 ] = s_a.fetch( -1 )
        if @num_subsystem_parts + 1 < s_a.length
          a[ 1 ] = "#{ CONST_SEP_ }#{ s_a[ @num_subsystem_parts .. -2 ] * CONST_SEP_ }"
        end
        a
      end

    public  # ~ const-name-related for arbitraries

      def test_local_qualified_business_module_name
        test_local_qualified_business_module_name_parts * CONST_SEP_
      end

      def test_local_qualified_business_module_name_parts
        a = @business_const_s_a[ @num_subsystem_parts  .. -1 ]
        a.unshift get_sidesystem_test_local_const
        a
      end

      def get_sidesystem_test_local_const
        "#{ @business_const_s_a[ @num_subsystem_parts - 1 ] }#{ UNDERSCORE_ }"
      end

      def business_module_basename
        @business_const_s_a.last
      end

    private  # ~

      def rndr_cvg
        _mod = "#{ @acon }#{ @bmod }#{ CONST_SEP_ }#{ @cmod }"
        tmpl, = templates [ :_cover ]
        s = tmpl[ mod: _mod ]
        s.chomp!
        s
      end

      def description_string
        s_a = @business_const_s_a
        top_usually_ignored, sidesys, * rest = s_a
        d = s_a.length
        if d.nonzero?
          if 1 == d
            top_usually_ignored
          else
            medallion = "[#{ Infer_initials_via_const__[ sidesys ] }]"
            if 2 == d
              "#{ medallion } #{ s_a * CONST_SEP_ }"
            else
              "#{ medallion } #{ rest * CONST_SEP_ }"
            end
          end
        end
      end

      Build_common_marginated_line_downtream_ = -> _MARGIN do

        Callback_::Scn.articulators.eventing(
          :any_first_item, -> y, x do
            if x.length.nonzero?
              y << x  # first margin is already there. no trailing delimiters
            end
          end,
          :any_subsequent_items, -> y, x do
            if x.length.zero?
              y << NEWLINE_
            else
              y << "#{ NEWLINE_ }#{ _MARGIN }#{ x }"  # no trailing delimiters
            end
          end,
          :y, [],
          :flush, -> y do
            x = y * EMPTY_S_
            y.clear
            x
          end )
      end

    Infer_initials_via_const__ = -> do
      h = {}
      rx = %r{  \A  ([A-Z])  ([a-z])  [^A-Z]*  ([A-Z])?  }x
      infer = -> i do
        md = rx.match i.to_s
        if md
          "#{ md[1].downcase }#{ md[3] ? md[3].downcase : md[2] }"
        else
          i.to_s
        end
      end
      -> i do
        h.fetch i do
          h[ i ] = infer[ i ]
        end
      end
    end.call

      Render_description_ = -> s do
        s.inspect
      end

      Self_ = self
    end
  end
end
