module Skylab::Basic

  module String

    module Small_Procs__

    Build_proc_for_string_begins_with_string = -> haystack_string do
      len = haystack_string.length
      -> needle_string do
        if needle_string.length <= len
          haystack_string[ 0, needle_string.length ] == needle_string
        end
      end
    end

    Build_proc_for_string_ends_with_string = -> needle_string do
      len = needle_string.length
      -> haystack_string do
        (( idx = haystack_string.rindex needle_string )) and
          idx == haystack_string.length - len
      end
    end

      Build_reverse_scanner = -> string, byte do

        end_ = string.length
        if end_.zero?
          Common_::Scn.the_empty_stream
        else
          Common_::Scn.new do
            case 0 <=> end_
            when -1
              begin_ = end_ - 1
              begin
                _is = byte == string.getbyte( begin_ )
                if _is

                  x = string[ ( begin_ + 1 ) ... end_ ]
                  end_ = begin_
                  break
                end

                if begin_.zero?  # happens only w/ "relative" looking strings
                  x = string[ 0 ... end_ ]
                  end_ = -1
                  break
                end

                begin_ -= 1
                redo
              end while nil
              x
            when 0
              end_ = -1
              EMPTY_S_
            when 1
              NIL_
            end
          end
        end
      end

      class Paragraph_string_via_message_lines < Common_::Actor::Monadic

        # transform an array of strings into one "paragraph" string that
        # "looks normal" pursuant to these rules:
        #
        # this string never ends with any provided trailing line separator.
        #
        # if you have multiple trailing newlines in any of your items, what
        # happens is undefined.
        #
        # IFF multiple items:
        #
        #   • each item will have a period added IFF certain criteria
        #     are met (see code).
        #
        #   • each item will be *separatated* (not terminated)
        #     by a newline (added as necessary).

        def initialize s_a
          @st = Common_::Polymorphic_Stream.via_array s_a
        end

        def execute
          if @st.no_unparsed_exists
            NOTHING_
          else
            ___when_at_least_one
          end
        end

        def ___when_at_least_one
          @_s = @st.gets_one
          if @st.no_unparsed_exists
            ___when_exactly_one
          else
            __when_more_than_one
          end
        end

        def ___when_exactly_one
          @_s.chomp!
          @_s
        end

        def __when_more_than_one

          buffer = ""

          s = remove_instance_variable :@_s

          begin
            md = Classify_termination___[ s ]
            is_last = @st.no_unparsed_exists

            if md[ :line_terminator ]

              # when the received item has a terminating newline,
              # assume the client manages its own punctuation.

              if is_last
                s.chomp!  # final lines never have these
                buffer << s
                break
              end
              buffer << s
            else

              buffer << s
              if ! md[ :punctuation ]
                buffer << PERIOD_
              end
              if is_last
                break
              end
              buffer << NEWLINE_
            end
            s = @st.gets_one
            redo
          end while nil

          buffer
        end
      end

      rx = /(?<punctuation>[.?!])?(?<line_terminator>\r?\n)?\z/

      Looks_like_sentence = -> s do
        rx.match( s )[ :punctuation ]
      end

      Classify_termination___ = -> s do
        rx.match s
      end

      PERIOD_ = '.'
    end
  end
end
