module Skylab::Common

  module Stream::CompoundStream

    # this is a years (and years) old file rewritten fully anew to
    # realize the bold dream of [#016.1] "baseless" streaming..
    # the problem is described in the document. this is the solution.

    class << self
      def define
        o = Builder___.new
        yield o
        o.__finish
      end
    end  # >>

    # ==

    class Builder___

      def initialize
        @_stream_proc_array = []
        @stream_class = Stream
      end

      def add_item x
        @_stream_proc_array.push -> do
          @stream_class.via_item x
        end ; nil
      end

      def add_stream st
        @_stream_proc_array.push -> { st } ; nil
      end

      def add_stream_by & st_p
        @_stream_proc_array.push st_p ; nil
      end

      def __finish
        CustomStream___.new(
          remove_instance_variable( :@_stream_proc_array ),
          @stream_class,
        )
      end
    end

    # ==

    class CustomStream___

      include Stream::InstanceMethods

      def initialize st_p_a, cls
        if st_p_a.length.zero?
          _close
        else
          @_stack = st_p_a.reverse
          _st_p = @_stack.pop
          @_stream = _st_p.call
          @_gets = :_main
          @stream_class = cls
        end
      end

      def gets
        send @_gets
      end

      def _main
        x = @_stream.gets
        if x
          x
        elsif @_stack.length.zero?
          remove_instance_variable :@_stream
          remove_instance_variable :@_stack
          _close
        else
          _st_p = @_stack.pop
          @_stream = _st_p.call
          _main  # RECURSE (no tail call here :P )
        end
      end

      def _close
        @_gets = :_nothing ; freeze ; NOTHING_
      end

      def _nothing
        NOTHING_
      end

      # --

      def new_by & p

        # (for now, when you map, lose the class association. but say hello.
        #  one day we might try to achieve something hackier, or not #todo)

        Stream.by -> { self._HELLO }, & p
      end
    end

    # ==
  end
end
# #history: full rewrite after many many years. #tombstone-A: had doc-test
