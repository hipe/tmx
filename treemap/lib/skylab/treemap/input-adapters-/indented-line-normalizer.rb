module Skylab::Treemap

  module Input_Adapters_::Indented_Line_Normalizer

    # produce a new stream that maps and reduces the upstream by the
    # following means and criteria:
    #
    # from the upstream (whose units will be treated as lines), here is the
    # means by which each line is mapped:
    #
    # each line will be split into three parts:
    #
    #   1) the zero or more characters of leading space or tab characters
    #
    #   2) the rest of the line (provided it has no aberrant line terminator
    #      characters)
    #
    #   3) zero or one line terminator sequence
    #
    # for (1) and (2) every line will have at least zero-length strings.
    # (that is to say, we never use nils, always use empty strings there
    # for such cases).
    #
    # typical lines will have either "\n" or "\r\n" for (3) but the use
    # of a line terminator (or consistent us of which form) is not enforced
    # by this facility.
    #
    # here is the criteria for how lines are reduced (excluded):
    #
    # where "skip" means "advance the stream until the unit you have does
    # not match this criteria":
    #
    # if this is the first line of input, skip a line that starts with
    # 'Run options: '
    #
    # skip any blank lines ever (where "blank" means a zero length string
    # for (2)).
    #
    # if the line has no indentation:
    #
    #   if the content starts with 'Finished in ',
    #     assert that the next line matches what is expected accordingly
    #     and so on to the end of input.
    #
    #   otherwise if the content starts with 'Pending:'
    #     (skip over this "pending" section accordingly)

    class << self

      def required_stream
        :raw_line_upstream
      end
    end  # >>

    my_proc = -> line_upstream do
      Build_indented_line_normalizer_via_line_object_upstream___[
        Build_line_object_upstream_via_line_upstream___[ line_upstream ] ]
    end

    define_singleton_method :call, my_proc
    define_singleton_method :[], my_proc

    Build_line_object_upstream_via_line_upstream___ = -> line_upstream do

      Common_::Scn.new do
        line_s = line_upstream.gets
        if line_s
          Models_::Node.new line_s, line_upstream.lineno
        end
      end
    end

    # ~ the boring parts:

    Build_indented_line_normalizer_via_line_object_upstream___ = -> st do

      run_opti_rx = /\ARun options: /

      main_p = nil
      p = -> do  # first line only

        o = st.gets
        if o
          if o.indent.length.zero? && run_opti_rx =~ o.content
            # skip until blank ssh..

            begin
              o = st.gets
              o or break
              if o.has_content
                redo
              end
              # ( otherwise node is blank )
              p = main_p
              o = p[]
              break
            end while nil
            o
          end
        end
      end

      finished_in_rx = /\AFinished in /
      pending_rx = /\APending:/

      main_p = -> do

        o = st.gets

        advance_over_pending_part = -> do

          begin  # advance to the first non-blank unit that has no indent

            o = st.gets
            o or break  # weird / meh

            if o.indent_length.nonzero?
              redo
            end

            if o.is_blank
              redo
            end
            break
          end while nil
        end

        begin

          o or break

          if o.is_blank
            o =  st.gets
            redo
          end

          if o.indent.length.zero?

            if finished_in_rx =~ o.content

              o_ = st.gets
              /\d examples?\b/ =~ o_.content or self._SANITY

              o__ = st.gets
              o__ and self._ETC
              o = nil

            elsif pending_rx =~ o.content

              advance_over_pending_part[]
              redo
            end
          end

          break
        end while nil
        o
      end

      Common_::Scn.new do
        p[]
      end
    end
  end
end
