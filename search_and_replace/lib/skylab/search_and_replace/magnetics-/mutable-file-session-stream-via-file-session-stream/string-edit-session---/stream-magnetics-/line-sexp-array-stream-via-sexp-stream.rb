self._MIGHT_CHOP  # #todo

module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

    class String_Edit_Session___

      class Stream_Magnetics_::Line_sexp_array_stream_via_sexp_stream < Callback_::Actor::Monadic

        # each item of this stream is an array of [#012] tagged sexp nodes.
        # each such array represents a would-be output line: the upstream is
        # "chunked" such that each chunk is zero or more non-newline nodes
        # tailed by zero or one newline node (and at least one node total!)
        #
        # each item from this stream is one-to-one with with a would-be
        # output line of the "file" after replacements have been applied.
        # the subject exists so that line-oriented rendering agents can
        # operate in terms of lines and not nodes (i.e they don't have to
        # do this map-reduce themselves).
        #
        # our result shape is arrays-of-sexps and not lines so that
        # downstream (i.e "client") expression agents can (for e.g) give
        # special highlighting to the matched or replaced spans of text.

        def initialize x
          @_x_st = x
        end

        def execute
          st = remove_instance_variable :@_x_st
          Callback_.stream do
            a = nil
            begin
              x = st.gets
              x or break
              ( a ||= [] ).push x
              if :newline_sequence == x.first
                break
              end
              redo
            end while nil
            a
          end
        end
      end
    end
  end
end
