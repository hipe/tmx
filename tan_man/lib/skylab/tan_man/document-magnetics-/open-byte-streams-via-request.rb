module Skylab::TanMan

  class DocumentMagnetics_::OpenByteStreams_via_Request < Common_::MagneticBySimpleModel  # 1x

    # (the task of determining whether to make 1 or 2 open bytestreams
    # from the 1 or 2 unsanitized BSR's is complicated enough to warrant
    # its own work here. successful result is array of 1 or 2 open streams)

    # -
      def initialize
        @__mutex_for_exe = nil
        super
      end

      def for_one_or_two_QKs__ a
        _for_one_to_two_BSRs a.map { |qk| qk.value_x }
      end

      def for_qualified_knownness_and_direction__ qkn, dir_sym

        _will_execute_for_this_lone_bsr Mags_[]::
          ByteStreamReference_via_QualifiedKnownness_and_ThroughputDirection.call(
            qkn, dir_sym )
      end

      def these_two_byte_stream_references__ bsr, bsr_
        _for_one_to_two_BSRs [ bsr, bsr_ ]
      end

      def only_this_byte_stream_reference__ bsr

        _will_execute_for_this_lone_bsr bsr  # hi.
      end

      def _will_execute_for_this_lone_bsr bsr

        @__lone_BSR = bsr
        _will_execute_by :__execute_for_lone_BSR
      end

      def _for_one_to_two_BSRs a

        @__these = a
        _will_execute_by :__execute_for_one_or_two
      end

      attr_writer(
        :is_read_write_not_read_only,
        :filesystem,
        :listener,
      )

      def _will_execute_by m
        remove_instance_variable :@__mutex_for_exe
        @_execute = m
      end

      def execute
        send @_execute
      end

      def __execute_for_one_or_two
        a = remove_instance_variable :@__these
        if 2 == a.length
          __execute_for_two( * a )
        else
          __finish_by_making_one_one_way_stream( * a )  # #cov3.1
        end
      end

      def __execute_for_two in_ref, out_ref

        # part of what the subject does is "downgrade" path-based references
        # to open IO references. we do NOT want to open two separate IOs to
        # the same path (one read-only, one write-only); rather, we want to
        # detect that they are two references to the same resource for two
        # different purposes, and open a single IO that is read-write. whew!

        # this idea applies similarly to references around strings and
        # arrays: if it is the same resource it should be the same
        # reference, a reference that "knows" it is for two purposes.
        # (the performer does nothing special for primitives anyway except
        # pass them through, marking them as non-lockable.)

        @is_read_write_not_read_only || self._SANITY__readme__
        # what determined that we want 2 refs is #spot2.1 (isomorphic)

        if in_ref.is_same_waypoint_as out_ref

          __finish_by_making_one_two_way_stream in_ref
        else
          __finish_by_making_two_one_way_streams in_ref, out_ref
        end
      end

      def __finish_by_making_one_two_way_stream in_ref

        _use_ref = in_ref.to_TWO_WAY_byte_stream_reference

        obs = _open_stream_by do |o|
          o.be_for_read_write
          o.byte_stream_reference = _use_ref
        end

        obs and _finish obs
      end

      def __finish_by_making_two_one_way_streams in_ref, out_ref  # #cov2.5

        ibs = _open_stream_by do |o|
          o.byte_stream_reference = in_ref
          o.be_for_read_only
        end

        if ibs

          obs = _open_stream_by do |o|
            o.byte_stream_reference = out_ref
            o.be_for_write_only
          end

          if obs
            _finish ibs, obs
          end
        end
      end

      def __finish_by_making_one_one_way_stream only_ref

        obs = _open_stream_by do |o|
          o.be_for_read_only
          o.byte_stream_reference = only_ref
        end

        obs and _finish obs
      end

      # --

      def __execute_for_lone_BSR

        _bsr = remove_instance_variable :@__lone_BSR

        obs = _open_stream_by do |o|

          if @is_read_write_not_read_only
            o.be_for_read_write
          else
            o.be_for_read_only
          end

          o.byte_stream_reference = _bsr
        end

        obs and _finish obs
      end

      def _open_stream_by

        Mags_[]::OpenByteStream_via_ByteStreamReference.call_by do |o|  # 1x
          yield o
          o.filesystem = @filesystem
          o.listener = @listener
        end
      end

      def _finish * open_streams
        (1..2).include? open_streams.length || self._SANITY
        open_streams.freeze
      end
    # -

    # ==
    # ==
  end
end
# #born: abstracted from "dot file" core to focus on making single IO reference from I&O
