module Skylab::DocTest

  module DocTest

    class Output_Adapters_::Quickie

      class View_Controllers_::Context_Node < View_Controller_

        main_template_name :_ctx

        def render line_downstream, document_context, node

          d = document_context.fetch :context_count
          document_context.cache :context_count, ( d += 1 )

          lds = my_line_downstream
          up = node.to_child_stream
          cx = up.gets
          while cx
            _vc = view_controller_for_node_symbol cx.node_symbol_when_context
            _vc.render lds, document_context, cx
            cx = up.gets
          end

          _dsc = Render_description_[ node.description_string ]
          _body = lds.flush

          _s = main_template.call(
            dsc: _dsc,
            num: d,
            ctx_body: _body )

          write_to_stream_string_line_by_line line_downstream, _s

          nil
        end

        def my_line_downstream
          o = @shared_resources.cached :_ctxt_LDS_ do
            _margin = main_template.first_margin_for :ctx_body
            Build_common_marginated_line_downtream_[ _margin ]
          end
          o.rewind
          o
        end
      end
    end
  end
end
