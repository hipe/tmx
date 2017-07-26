module Skylab::BeautySalon

  class CrazyTownReports_::EchoFilePaths < Common_::MagneticBySimpleModel

    # -

      def self.describe_into_under y, expag

        y << 'just echo the path names. this is basically a "ping" to see'
        y << 'if the very basics are working. there will be no report'
        y << 'simpler than this one.'
      end

      attr_writer(
        :file_path_upstream_resources,
        :listener,
      )

      def execute

        @file_path_upstream_resources.line_stream_via_file_chunked_functional_definition do |y, oo|

          oo.define_document_hooks_plan :plan_A do |o|

            o.before_each_file do |potential_sexp|

              y << potential_sexp.path
            end
          end

          oo.on_each_file_path do |path, o|

            o.execute_document_hooks_plan :plan_A
          end
        end
      end
    # -
  end
end
# #born.
