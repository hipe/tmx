# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownUnparseMagnetics_::String_via_Definition < Common_::MagneticBySimpleModel

    # (this is #[#026.F] one of these.)

    # as far as we've seen, "definition" maps are used for method definitions,
    # and modules (e.g classes)..

    # -

      -> do
        THESE___ = {
          class: {
            method: :_write_using_placeholders,
            name_part: :__name_part_for_class,
          },
          module: {
            method: :__when_module_TODO,  # #open [#007.N.4]
          },
          sdef: {
            method: :__when_sdef_TODO,  # #open [#007.N.3]
          },
          def: {
            method: :_write_using_placeholders,
            name_part: :_name_part_for_method,
          },
        }
      end.call

      def initialize
        super
        __init_writer
      end

      def context_by= _
        NOTHING_
      end

      attr_writer(
        :location,
        :structured_node,
        :buffers,
      )

      def execute
        @_behavior = THESE___.fetch @structured_node._node_type_
        send @_behavior.fetch :method
      end

      def _write_using_placeholders

        @_.write_range :keyword
        __write_name_part
        @_.write_component :any_body_expression  # popular name, yay
        @_.write_range :end
        ACHIEVED_  # #spot3.1
      end

      def __write_name_part
        send @_behavior.fetch :name_part
      end

      def __write_body_part
        send @_behavior.fetch :body_part
      end

      def __name_part_for_class
        @_.write_component :module_identifier_const
      end

      def _name_part_for_method

        if @location.operator
          self._COVER_ME__easy_but_needs_coverage__
        else
          @_.write_terminal :name, :method_name
        end

        @_.write_component :args
      end

      def __init_writer
        @_ = CrazyTownUnparseMagnetics_::String_via_StructuredNode::Writer.new(
          structured_node: @structured_node,
          buffers: @buffers,
        )
      end

    # -
    # ==

    # ==
    # ==
  end
end
# #abstracted.
