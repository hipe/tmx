module Skylab::TestSupport

  module DocTest

    class Output_Adapters_::Quickie

      class View_Controllers_::Example_Node_In_Context < View_Controller_

        main_template_name :"_eg-in-sandbox"

        def render line_downstream, doc_context, node

          lds = my_line_downstream
          up = node.to_child_stream

          exp = up.gets
          while exp
            _line_renderer = view_controller_for_node_symbol exp.expression_symbol
            _line_renderer.render lds, doc_context, exp
            exp = up.gets
          end

          _dsc = Render_description_[ node.description_string ]
          _code = lds.flush

          _s = main_template.call(
            dsc: _dsc,
            num: doc_context.fetch( :context_count ),
            code: _code )

          write_to_stream_string_line_by_line line_downstream, _s

          nil
        end

        def my_line_downstream
          o = @shared_resources.cached :_eg_LDS_ do
            _margin = main_template.first_margin_for :code
            Build_common_marginated_line_downtream_[ _margin ]
          end
          o.rewind
          o
        end
      end
    end
  end
end
