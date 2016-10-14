module Skylab::SearchAndReplace

  class ThroughputMagnetics_::Throughput_Line_Stream_via_Throughput_Atom_Stream

    # chunk at each [#010] line while wrapping (mapping) it
    # in an ad-hoc structure that reflects particular metadata

    def initialize atom_st
      @atom_stream = atom_st
      @_current_match_index = nil
    end

    def execute

      @_state = :___gets

      Common_.stream do  # #[#032]
        send @_state
      end
    end

    def ___gets

      x = @atom_stream.gets
      if x
        _gets_line x
      else
        _done
      end
    end

    def _gets_line x

      @_atom_array = []
      @_atom_on_line_index = -1
      @_matches_begun_on_this_line_h = {}
      @_matches_ended_on_this_line_h = {}

      unless :match == x || :static == x
        @_atom_on_line_index += 1
        @_atom_array.push CONTINUING___.fetch @_current_context
      end

      begin
        @_atom_on_line_index += 1
        @_atom_array.push x
        _stay = send x
        _stay or break
        x = @atom_stream.gets
        if x
          redo
        end

        # when no more atoms at all, you are done. (special wrap-up):

        _maybe_close_match
        _done

        break
      end while nil

      __finish_line
    end

    CONTINUING___ = {
      match: :match_continuing,
      static: :static_continuing,
    }

    def __finish_line

      remove_instance_variable :@_atom_on_line_index
      _ = remove_instance_variable :@_atom_array
      _h = remove_instance_variable :@_matches_begun_on_this_line_h
      _h_ = remove_instance_variable :@_matches_ended_on_this_line_h

      # --

      Throughput_Line___.new _h, _h_, _
    end

    def _done
      remove_instance_variable :@atom_stream  # sanity
      @_state = :___nothing
      NOTHING_
    end

    def ___nothing
      NOTHING_
    end

  private  # implement our processing *of* the throughput syntax *with* our methods

    def match

      atom_on_line_index = @_atom_on_line_index

      d = _gets_one
      _gets_one  # 'orig' | 'repl'

      # --

      @_current_context = :match
      @_current_match_index = d
      @_matches_begun_on_this_line_h[ d ] = atom_on_line_index
      STAY__
    end

    def static

      _maybe_close_match
      @_current_context = :static
      STAY__
    end

    def content
      _gets_one  # (the content string)
      STAY__
    end

    def LTS_begin
      _gets_one  # (the content string (maybe empty) of the first half)
      STAY__
    end

    def LTS_continuing
      ::Kernel._K
    end

    def LTS_end
      BREAK__
    end

    # --

    def _maybe_close_match
      d = @_current_match_index
      if d
        @_current_match_index = nil
        @_matches_ended_on_this_line_h[ d ] = @_atom_on_line_index
      end
      NIL_
    end

    def _gets_one

      x = @atom_stream.gets
      @_atom_on_line_index += 1
      @_atom_array.push x
      x
    end

    # ==

    class Throughput_Line___  # has same-name counterpart

      def initialize h, h_, a
        @a = a
        @_etc = h
        @_etc_ = h_
      end

      def to_unstyled_bytes_string_  # #testpoint
        ThroughputMagnetics_::Unstyled_String_via_Throughput_Atom_Stream.new(
          Common_::Stream.via_nonsparse_array @a ).execute
      end

      def has_start_of_match d
        @_etc[ d ]
      end

      def has_end_of_match d
        @_etc_[ d ]
      end

      attr_reader(
        :a,
      )
    end

    # ==

    BREAK__ = false
    STAY__ = true
  end
end

# #history: rename & full rewrite of Line_sexp_array_stream_via_sexp_stream, Line_Sexp_Array_Stream_via_Newlines
