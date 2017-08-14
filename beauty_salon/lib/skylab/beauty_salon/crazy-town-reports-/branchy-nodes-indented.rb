# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownReports_::BranchyNodesIndented < Common_::MagneticBySimpleModel

    # -

      def self.describe_into_under y, expag

        y << 'this one is a bit of a "contact exercise" to work with stacks.'
        y << 'summarize every file in two ways:'
        y << nil
        y << '  1) pretending that it\'s python, use indentation only'
        y << '     (no `end` keywords) to signify the depth of the element.'
        y << nil
        y << '  2) express only "branchy" nodes, so things like modules,'
        y << '     classes and methods..'
      end

      attr_writer(
        :file_path_upstream_resources,
        :on_error_once,
        :listener,
      )

      def execute

        indent_s = SPACE_ * 2

        @file_path_upstream_resources.line_stream_via_file_chunked_functional_definition do |y, oo|

          oo.define_document_hooks_plan :plan_A do |o|

            # (something like this is not necessary,
            #  because we get a stack frame for each file:)
            #
            # o.before_each_file do |potential_node|
            #  y << "file #{ potential_node.path }"
            # end

            o.on_each_branchy_node__ do |wnode|
              y << "#{ indent_s * wnode.depth }#{ wnode.to_description }"
            end

            o.on_error_once = @on_error_once
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
