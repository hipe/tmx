module Skylab::BeautySalon

  class CrazyTownMagneticsForMainReport_::
      ChangedFile_via_HooksDefinition_via_Functions_and_Selector < Common_::MagneticBySimpleModel

    # because the interfaces of these magnets are so event-driven and
    # DSL-y, a "normal magnetic flow" is somewhat disrupted such that the
    # names of these magnets are more conceptual than direct.
    #
    # but meh. the interesting part is mostly behind us. this remainder of
    # the pipeline is quite straightforward:
    #
    #   - substitute a particular string for whatever string is there at a
    #     particular range. do this for a list of such changes, being sure
    #     that the substitutions don't corrupt your offsets.
    #
    #   - as a bit of a detail, we want our final output to be a diff,
    #     not the "after" file (but assume this could change). contrary
    #     to how this magnet is named, we initiate that work here..

    # -

      attr_writer(
        :code_selector,
        :listener,
        :receive_changed_file,
        :replacement_function,
      )

      def execute
        self
      end

      def flush_definition__ y, oo

        guy = nil

        user_function = @replacement_function.user_function

        # --

        oo.before_each_file do |potential_ast|

          NOTHING_  # hi.
        end

        @code_selector.on_each_occurrence_in oo do |tupling|

          s = user_function[ tupling ]

          ::String === s || self._COVER_ME__strange_result_from_user_function__

          ( guy ||= Guy___.new @receive_changed_file ).__push_ s, tupling

          NIL
        end

        oo.after_each_file do |potential_ast|

          if guy
            _ = guy ; guy = nil
            d = _.__flush_into_ y
            if d.zero?
              self._COVER_ME__zero_bytes_written_
            end
          end
        end

        NIL
      end
    # -

    # ==

    class Guy___

      def initialize rcf
        @receive = :__receive_initially
        @receive_changed_file = rcf
        @_stack = []
      end

      def __push_ s, tupling
        send @receive, s, tupling.node_loc.expression
      end

      def __receive_initially s, source_range

        @_source_buffer = source_range.source_buffer
        @receive = :__receive_normally
        _push_doohah s, source_range
      end

      def __receive_normally s, source_range

        sb = source_range.source_buffer
        @_source_buffer.object_id == sb.object_id || sanity
        _push_doohah s, source_range
      end

      def _push_doohah s, source_range
        @_stack.push [ ( source_range.begin_pos ... source_range.end_pos ), s ]
        NIL
      end

      def __flush_into_ y

        _bytes = OutputFile_via_ChangePieces___.call_by do |o|
          o.line_downstream_yielder = y
          o.receive_changed_file = remove_instance_variable :@receive_changed_file
          o.filesystem = ::File
          o.source_buffer = remove_instance_variable :@_source_buffer
          o.stack = remove_instance_variable :@_stack
        end

        _bytes  # hi. #todo
      end
    end

    # ==

    # ==

    class OutputFile_via_ChangePieces___ < Common_::MagneticBySimpleModel

      attr_writer(
        :filesystem,
        :line_downstream_yielder,
        :receive_changed_file,
        :stack,
        :source_buffer,
      )

      def execute

        __init_pieces

        __write_pieces_and_with_tmpfile do |io, sb|
          @receive_changed_file[ @line_downstream_yielder, io, sb ]
        end
      end

      def __write_pieces_and_with_tmpfile

        _ssr = Tempfile_sessioner___[ @filesystem ]

        _ssr.session do |io|
          d = 0
          @_pieces.each do |s|
            d += io.write s
          end
          io.flush
          _x = yield io, @source_buffer
          _x  # hi. #todo
        end
      end

      def __init_pieces

        @_scn = Common_::Scanner.via_array remove_instance_variable :@stack
        r, s = @_scn.gets_one

        @_pieces = []
        @_source = @source_buffer.source

        if r.begin.nonzero?
          _transfer_original 0 ... r.begin
        end

        if s.length.nonzero?
          _write_new s
        end

        until @_scn.no_unparsed_exists

          r_, s = @_scn.gets_one

          if r.end != r_.begin
            _transfer_original r.end ... r_.begin
          end

          if s.length.nonzero?
            _write_new s
          end

          r = r_
        end

        len = @_source.length
        if len != r.end
          _transfer_original r.end ... len
        end
        NIL
      end

      def _transfer_original r
        @_pieces.push @_source[ r ]
        NIL
      end

      def _write_new s
        @_pieces.push s ; nil
      end
    end

    # ==

    -> do

      # review: the "tmpfile sessioner" is for giving us a tmpfile for
      # a limited time that we don't have to think about locking (during)
      # or cleaning up (after). it's made to memoize. but let's not screw
      # ourselves if we use different filesystems in one runtime.

      x = nil ; memoized_id = nil
      reinit = -> fs do
        memoized_id = fs.object_id

        x = Home_.lib_.system_lib::Filesystem::TmpfileSessioner.define do |o|

          require 'tmpdir'
          o.tmpdir_path ::Dir.tmpdir

          o.using_filesystem fs

        end ; nil
      end
      Tempfile_sessioner___ = -> fs do
        if memoized_id != fs.object_id
          reinit[ fs ]
        end
        x
      end
    end.call

    # ==
    # ==
  end
end
# #born.
