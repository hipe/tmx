module Skylab::DocTest

  module DocTest

    class Output_Adapters_::Quickie

      class View_Controllers_::Before_Node < View_Controller_

        main_template_name :_bef

        def render line_downstream, document_context, node

          lds = my_line_downstream
          lines = node.to_line_stream

          line = lines.gets

          while line
            lds.puts line.chomp
            line = lines.gets
          end

          _num = document_context.fetch :context_count
          _code = lds.flush

          _s = main_template.call(
            num: _num,
            code: _code )

          write_to_stream_string_line_by_line line_downstream, _s

          nil
        end

        def my_line_downstream
          o = @shared_resources.cached :_bef_LDS_ do
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
# :+#posterity - a comment showed primordial thoughts of "intermediates"
