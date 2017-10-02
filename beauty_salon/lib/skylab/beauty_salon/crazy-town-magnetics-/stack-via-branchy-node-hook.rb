module Skylab::BeautySalon

  class CrazyTownMagnetics_::Stack_via_BranchyNodeHook < Common_::MagneticBySimpleModel

    # for reports that want it, maintain a stack (or something like it),
    # avoiding creating extraneous objects when there is no listener for
    # "branchy" nodes. see [#021.E]

    # for no particular reason except living dangerously, this is written
    # to be re-used across files..

    # -

      attr_writer(
        :branchy_node_hook,
      )

      def execute

        if @branchy_node_hook

          @__grammar_symbol_feature_branch = Home_::CrazyTownMagnetics_::
              SemanticTupling_via_Node.structured_nodes_as_feature_branch

          @_thing_cache = {}
          @for_file = :__for_file_when_listener
        else
          @for_file = :__for_file_when_no_listener
        end

        self
      end

      def for_file__ wast, & p
        send @for_file, wast, & p
      end

      def __for_file_when_listener wast

        _same_for_file do
          path = wast.path
          @CURRENT_FILE = path
          @branchy_node_hook[ FileStackFrame___.new( path ) ]
          @in_stack_frame = :__in_stack_frame_when_listener
          yield
        end
      end

      def __for_file_when_no_listener _
        _same_for_file do
          @in_stack_frame = :__in_stack_frame_when_no_listener
          yield
        end
      end

      def _same_for_file
        prev = @for_file
        @for_file = nil
        @current_depth_offset = 0
        yield
        @current_depth_offset.zero? || fail
        @current_depth_offset = nil
        @for_file = prev ; nil
      end

      def in_stack_frame__ p, n
        send @in_stack_frame, n, & p
      end

      def __in_stack_frame_when_listener n

        _same_in_stack_frame do

          _sn = __some_structured_node_for n

          _sf = ItemStackFrame___.new @current_depth_offset, _sn

          @branchy_node_hook[ _sf ]

          yield

          NIL
        end
      end

      def __some_structured_node_for n
        k = n.type
        _cls = @_thing_cache.fetch k do
          x = @__grammar_symbol_feature_branch.some_structured_node_class_for__ k
          @_thing_cache[ k ] = x
          x
        end
        _cls.via_node_ n
      end

      def __in_stack_frame_when_no_listener _
        _same_in_stack_frame do
          yield
        end
      end

      def _same_in_stack_frame
        @current_depth_offset += 1
        yield
        @current_depth_offset -= 1 ; nil
      end

      attr_reader(
        :CURRENT_FILE,  # (not covered, but useful in debugging)
      )

    # -

    # ==

    class ItemStackFrame___

      def initialize d, sn
        @depth = d
        @structured_node = sn
        freeze
      end

      def to_description
        @structured_node.to_description
      end

      attr_reader(
        :depth,
        :structured_node,
      )
    end

    # ==

    class FileStackFrame___

      def initialize path
        @path = path ; freeze
      end

      def to_description
        "file: #{ @path }"
      end

      def depth
        0
      end
    end

    # ==
    # ==
  end
end
# extracted from sibling
