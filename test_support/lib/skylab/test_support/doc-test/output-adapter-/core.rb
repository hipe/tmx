module Skylab::TestSupport

  module DocTest

    class Output_Adapter_  # :[#025]. (storypoints in [#014] for now)

      include Lazy_Selective_Event_Methods_

      class << self

        def event_for_wrote
          Event_for_Wrote_
        end

        def templates_path
          templates_pathname.to_path
        end

        def templates_pathname
          dir_pathname.join 'templates-'
        end
      end

      def initialize
        @on_shared_resources_created = nil
        @shared_resources = nil
      end

      def initialize_copy _
        # nothing yet. (child classes should do this, though)
      end

      def formal_properties_array

        # assume that this will not be mutated by the caller
        # and its uptake will be cached so we need not do so

        mod = self.class.const_get :Parameter_Functions_, false  # etc

        pcls = DocTest::Models_::Front::Actions::Generate::Property

        mod.constants.map do | sym |

          Parameter_Function_::Build_property_for_function[
            :output_adapter_pfunc,
            pcls,
            mod.const_get( sym, false ),
            sym ]
        end
      end

      def against * x_a
        before_call
        _ok = process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
        _ok and execute
      end

      Fields___ = Home_.lib_.fields

      def receive_stream_and_pfunc_prop st, prp

        pfunc = Autoloader_.const_reduce(
          [ prp.name.as_const ],
          self.class::Parameter_Functions_ )

        if Fields___::Takes_argument[ prp ]
          _x = st.gets_one
          pfunc.call self, _x, @o, & @on_event_selectively
        else
          pfunc.call self, & @on_event_selectively
        end
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
        self.class.templates_path
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
          template_idioms.templates_via_list i_a
        end

        def main_template
          @mt ||= template main_template_name
        end

        def template i
          template_idioms.template i
        end

        def templates_via_list i_a
          template_idioms.templates_via_list i_a
        end

        def template_idioms
          @shared_resources.cached :template_idioms do
            DocTest_::Idioms_::Template.new(
              @shared_resources.fetch( :template_dir_pathname ),
              @shared_resources,
              & @on_event_selectively )
          end
        end

        # ~ other view controllrs

        def view_controller_for_node_symbol i

          _const_i = Callback_::Name.via_variegated_symbol( i ).as_const

          _parent_mod = @shared_resources.fetch :view_controllers_parent_module

          _module = _parent_mod::View_Controllers_.const_get _const_i, false

          _module.view_controller @shared_resources, & @on_event_selectively

        end

        # ~ courtesy rendering *functions*

        def write_to_stream_string_line_by_line line_downstream, string

          o = Home_.lib_.basic::String.line_stream string

          while s = o.gets
            s.chomp!
            line_downstream.puts s
          end
        end
      end

      Event_for_Wrote_ = Callback_::Event.prototype_with :wrote,

        :is_known_to_be_dry, false,
        :bytes, nil,
        :line_count, nil,
        :ok, nil do | y, o |

          y << " done (#{ o.line_count } line#{ s o.line_count }, #{
            }#{ o.bytes }#{ ' (dry)' if o.is_known_to_be_dry } bytes)."
        end

  class Xxx___

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
          opt.summarize_p[ build_section_yielder[ y, opt.name_symbol ] ]
        end
      end
      Home_.lib_.CLI_table(
        :field, :id, :name,
        :field, :id, :desc, :left,
        :show_header, false,
        :left, '| ', :sep, '    ',
        :write_lines_to, @snitch.method( :puts ),
        :read_rows_from, ea )
      nil
    end
  end

    end
  end
end
# +:#posterity: multiple early versions of stream via array, param lib
