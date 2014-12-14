module Skylab::TestSupport

  module DocTest

    class Output_Adapter_  # :[#025]. (storypoints in [#014] for now)

      include Lazy_Selective_Event_Methods_

      def initialize
        @on_shared_resources_created = nil
        @shared_resources = nil
      end

      def against * x_a
        before_call
        _ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
        _ok and execute
      end

    private

      def before_call
      end

      def when_no_nodes
        maybe_send_event :error, :no_nodes_in_upstream do
          build_not_OK_event_with :no_nodes_in_upstream
        end
      end

      def resolve_shared_resources
        @shared_resources ||= bld_shared_resources
        nil
      end

      def bld_shared_resources
        o = Shared_Resources_.new
        o.cache :template_dir_pathname, build_template_dir_pathname
        o.cache :view_controllers_parent_module, self.class
        o
      end

      def build_template_dir_pathname
        self.class.dir_pathname.join 'templates-'
      end

      def init_view_controller
        @view_controller = View_Controller_.view_controller(
          @shared_resources, & handle_event_selectively )
        nil
      end

      def templates * i_a
        @view_controller.templates_via_list i_a
      end

      def template i
        @view_controller.template i
      end

      def view_controller_for_node_symbol i
        @view_controller.view_controller_for_node_symbol i
      end

      class View_Controller_  # see [#026]

        class << self

          def view_controller shared_resc, & oes_p
            new shared_resc, & oes_p
          end

          private :new

        private
          def main_template_name _NAME_I
            define_method :main_template_name do
              _NAME_I
            end
          end
        end

        def initialize shared_resources, & oes_p
          @shared_resources = shared_resources
          @on_event_selectively = oes_p
        end

        # ~ templates - random access

        def templates * i_a
          templates_via_list i_a
        end

        def templates_via_list i_a
          pn = -> do
            x = @shared_resources.fetch :template_dir_pathname
            pn = -> { x }
            x
          end
          h = @shared_resources.touch_head_hash :templates
          i_a.map do |i|
            h.fetch i do
              h[ i ] = Template__.via_path pn[].join( "#{ i }#{ EXT__ }" ).to_path
            end
          end
        end

        def main_template
          @mt ||= template main_template_name
        end

        def template i
          @shared_resources.cached :templates, i do
            Template__.via_path(
              @shared_resources.fetch( :template_dir_pathname ).join(
                "#{ i }#{ EXT__ }" ).to_path )
          end
        end

        EXT__ = '.tmpl'.freeze

        # ~ other view controllrs

        def view_controller_for_node_symbol i

          _const_i = Callback_::Name.via_variegated_symbol( i ).as_const

          _parent_mod = @shared_resources.fetch :view_controllers_parent_module

          _module = _parent_mod::View_Controllers_.const_get _const_i, false

          _module.view_controller @shared_resources, & @on_event_selectively

        end

        # ~ courtesy rendering *functions*

        def write_to_stream_string_line_by_line line_downstream, string

          o = TestSupport_::Lib_::Bsc[]::String.line_stream string

          while s = o.gets
            s.chomp!
            line_downstream.puts s
          end
        end
      end

      Template__ = TestSupport_._lib.string_lib.template

      class Shared_Resources_

        def initialize
          @h = {}
        end

        def fetch * i_a, & p
          touch_tail_hash( i_a ).fetch( i_a.last, & p )
        end

        def cached * i_a, & build_p
          h = touch_tail_hash i_a
          h.fetch i_a.last do
            h[ i_a.last ] = build_p[]
          end
        end

        def cache * i_a, x
          touch_tail_hash( i_a )[ i_a.last ] = x
          nil
        end

        def touch_head_hash i
          @h.fetch i do
            @h[ i ] = {}
          end
        end

      private

        def touch_tail_hash i_a
          i_a[ 0 .. -2 ].reduce @h do | m, i |
            m.fetch i do
              m[ i ] = {}
            end
          end
        end
      end
    end


  class Xxx___

    # ~ option support & hook-outs

  public
    def any_exit_status_from_set_options option_a  # mutates
      Set_Options__.new( frml_options, self, option_a ).resolve_any_exit_status
    end
  private
    def frml_options
      self.class.formal_opts
    end
    class << self
      def formal_opts
        @formal_opts ||= bld_formal_options
      end
    private
      def bld_formal_options
        Parse_formal_options__[ const_get :OPTION_X_A__, false ]
      end
    end
  public
    def unhandled_options_from_set_options opt_a
      formals = frml_options
      @snitch.say :notice do
        "invalid template option(s) #{
        }#{ opt_a.map( & :inspect ) * ', ' } - valid option(s): #{
        }(#{ formals.map( & :name_i ) * ', ' })"
      end
      UNABLE_
    end
  private
    def show_option_help
      @snitch.puts "available template options:"
      build_section_yielder = -> y, name_i do
        first = true
        ::Enumerator::Yielder.new do |line|
          if first
            y << [ name_i.to_s, line ]
            first = false
          else
            y << [ EMPTY_S_, line ]
          end
        end
      end
      ea = ::Enumerator.new do |y|
        frml_options.values.each do |opt|
          opt.summarize_p[ build_section_yielder[ y, opt.name_i ] ]
        end
      end
      TestSupport_._lib.CLI_table(
        :field, :id, :name,
        :field, :id, :desc, :left,
        :show_header, false,
        :left, '| ', :sep, '    ',
        :write_lines_to, @snitch.method( :puts ),
        :read_rows_from, ea )
      nil
    end

    class Parse_formal_options__
      def self.[] x_a
        new( x_a ).execute
      end
      def initialize x_a
        @scn = Stream_via_Array__.new x_a
      end
      def execute
        name_i = @scn.gets and bld_nonzero_box name_i
      end
    private
      def bld_nonzero_box name_i
        box = RegretLib_::Box[]
        while true
          opt = Option__.new name_i, @scn
          box.add name_i, opt
          name_i = @scn.gets
          name_i or break
        end
        box
      end
    end

    class Stream_via_Array__
      def initialize a
        d = -1 ; last = a.length - 1
        @gets_p = -> do
          d < last and a.fetch d += 1
        end
        @peek_p = -> do
          d < last and a.fetch( d + 1 )
        end
        @skip_p = -> do
          d < last and d += 1 ; nil
        end
      end
      def gets ; @gets_p[] ; end
      def peek ; @peek_p[] ; end
      def skip ; @skip_p[] ; end
    end


    Simple_array_scanner__ = -> a do
      d = -1 ; last = a.length - 1
      -> { d < last and a.fetch d += 1 }
    end

    class Option__
      def initialize name_i, scn
        name_i.respond_to?( :id2name ) or raise ::ArgumentError,
          "no implicit conversion of #{ name_i.class } into symbol"
        @name_i = name_i ; @scn = scn
        map_reduce_p = self.class.map_reduce_method_name_p
        loop do
          i = scn.peek or break
          m_i = map_reduce_p[ i ] or break
          scn.skip
          send m_i
        end
      end
      class << self
        def map_reduce_method_name_p
          @mrmn_p ||= bld_map_reduce_method_name_p
        end
      private
        def bld_map_reduce_method_name_p
          -> i do
            m_i = :"#{ i }="
            private_method_defined?( m_i ) and m_i
          end
        end
      end
      attr_reader :name_i, :summarize_p,
        :when_not_provided_p, :when_provided_p
    private
      def when_not_provided=
        @when_not_provided_p = @scn.gets ; nil
      end
      def when_provided=
        @when_provided_p = @scn.gets ; nil
      end
      def summarize=
        @summarize_p = @scn.gets ; nil
      end
    end

    class Set_Options__
      def initialize formals, client, actual_a
        @actual_a = actual_a ; @client = client ; @formals = formals ; nil
      end
      def resolve_any_exit_status
        es = nil
        @formals.each_pair do |name_i, opt|
          if @actual_a and (( idx = @actual_a.index name_i.to_s ))
            es = prcs_formal_arg opt.when_provided_p, idx
            es.nil? or break
          else
            @client.instance_exec( & opt.when_not_provided_p )
          end
        end
        es.nil? and @actual_a and es = fnsh_options
        es
      end
    private
      def prcs_formal_arg p, d
        @actual_a[ d ] = nil
        @client.instance_exec( & p )
      end
      def fnsh_options
        @actual_a.compact!
        if @actual_a.length.nonzero?
          @client.unhandled_options_from_set_options @actual_a
        end
      end
    end
  end
  end
end
