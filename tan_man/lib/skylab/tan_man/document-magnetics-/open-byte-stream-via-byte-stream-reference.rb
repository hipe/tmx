module Skylab::TanMan

  class DocumentMagnetics_::OpenByteStream_via_ByteStreamReference < Common_::MagneticBySimpleModel

    # an "open byte stream" under this facility is a composite structure
    # wrapping an open native IO handle (or the like) along with a few
    # metadata relevant to the client pipeline. (the TL;DR: is the the NOTE below.)
    #
    # this can be though of as an experimental extension to the [#ba-062.3]
    # "byte stream reference" stack.
    #
    # all such subjects are constructed from a "byte stream reference"
    # ("BSR"). in fact this subject was originally called "sanitized byte
    # stream reference", a name that still holds salience now.
    #
    # if the argument BSR is path-based, it leads to an IO that is opened
    # with the appropriate mode flags (read-only, write-only or read-write
    # as appropriate to the subject arguments).
    #
    # on any IO in our pipeline (that is, one arrived at as above or one we
    # received as an argument wrapped in a BSR), we attempt to acquire a
    # lock.
    #
    # "primitive" BSR's (e.g string-based or array-based) on the other hand,
    # are wrapped as-is.
    #
    # the successful result is structure-like that wraps the final, normal
    # BSR (exposed as `sanitized_byte_stream_reference`) and simple boolean
    # metadata about whether this resource is a locked IO and more broadly
    # whether this resource is associated with filesystem. (it may be the
    # case that these two booleans are entirely concomitant.)
    #
    # there are at least two possible points of failure: one is a failure
    # to open the file (when path-based BSR), the other is failure to
    # acquire the lock (when applicable). the behavior of such failure is
    # the responsibilities of their respective dedicated performers.
    #
    # NOTE the most significant provision of all this is this: **"whoever"
    # creates the subject instance assumes the responsibility of eventually
    # closing it and releasing its lock, as pertinent.**
    #
    # in keeping with its name, once you have closed the corresponding
    # native filehandle (as applicable), it is strongly recommended that
    # you release (discard) the subject object as well (deleting all
    # references). the only real purpose of the subject is to act as a
    # reminder that you have a resource that needs to be relased eventually.
    #
    # (also: commit message at #born does a better job of justifing this.)

    # -

      def initialize
        @_mutex_for_direction = nil
        super
      end

      def be_for_read_write
        remove_instance_variable :@_mutex_for_direction
        @is_readable = true ; @is_writeable = true ; nil
      end

      def be_for_write_only
        remove_instance_variable :@_mutex_for_direction
        @is_readable = false ; @is_writeable = true ; nil
      end

      def be_for_read_only
        remove_instance_variable :@_mutex_for_direction
        @is_readable = true ; @is_writeable = false ; nil
      end

      def byte_stream_reference= bsr
        @_unsanitized_BSR = bsr
      end

      attr_writer(
        :filesystem,
        :listener,
      )

      def execute

        if __shape_is_primitive

          __use_primitive

        elsif __shape_is_of_path

          __locked_IO_BSR_via_path
        else
          __resolve_locked_IO_BSR_via_IO
        end
      end

      # -- D: when path

      def __locked_IO_BSR_via_path

        if __resolve_non_locked_IO_via_digraph_path
          _locked_IO_BSR_via_non_locked_IO
        end
      end

      def __resolve_non_locked_IO_via_digraph_path

        _ = Home_::DocumentMagnetics_::IO_via_ExistingFilePath.call(
          remove_instance_variable( :@_unsanitized_BSR ).path,
          @is_writeable,
          @is_readable,
          @filesystem,
          & @listener
        )
        _store :@_non_locked_IO, _
      end

      def __shape_is_of_path
        :path == @_unsanitized_BSR.shape_symbol
      end

      # -- C: when IO

      def __resolve_locked_IO_BSR_via_IO

        @_non_locked_IO =
          remove_instance_variable( :@_unsanitized_BSR ).BYTE_STREAM_IO_FOR_LOCKING

        _locked_IO_BSR_via_non_locked_IO
      end

      def _locked_IO_BSR_via_non_locked_IO

        if __resolve_locked_IO_via_non_locked_IO
          __locked_IO_BSR_via_locked_IO
        end
      end

      def __locked_IO_BSR_via_locked_IO

        _ = Home_::DocumentMagnetics_::ByteStreamReference_via_Locked_IO.call(
          remove_instance_variable( :@__locked_IO ),
          @is_writeable,
          @is_readable,
        )

        @sanitized_byte_stream_reference = _
        @is_lockable_and_locked = true
        @filesystem_is_involved = true
        _finish
      end

      def __resolve_locked_IO_via_non_locked_IO

        _io = remove_instance_variable :@_non_locked_IO
        _ = Home_::DocumentMagnetics_::Locked_IO_via_IO[ _io ]
        _store :@__locked_IO, _
      end

      # -- B: when primitive

      def __use_primitive
        @sanitized_byte_stream_reference = remove_instance_variable :@_unsanitized_BSR
        @is_lockable_and_locked = false
        @filesystem_is_involved = false
        _finish
      end

      def __shape_is_primitive
        @_unsanitized_BSR.BYTE_STREAM_REFERENCE_SHAPE_IS_PRIMITIVE
      end

      # -- A: support

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def _finish
        remove_instance_variable :@filesystem
        freeze
      end

      # --

      def close_stream_and_release_lock_  # assume @is_lockable_and_locked
        @sanitized_byte_stream_reference.CLOSE_BYTE_STREAM_IO  # (nil)
      end

      attr_reader(
        :filesystem_is_involved,
        :is_lockable_and_locked,
        :is_readable,
        :is_writeable,
        :sanitized_byte_stream_reference,
      )
    # -

    # ==
    # ==
  end
end
# #born: abstracted from what is currently "dot file" core file
