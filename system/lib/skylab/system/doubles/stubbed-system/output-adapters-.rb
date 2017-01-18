module Skylab::System

  module Doubles::Stubbed_System
    # -
      Output_Adapters_ = ::Module.new

      class Output_Adapters_::OGDL_esque

        def initialize io, first_sym
          @io = io
          io.write "#{ first_sym }\n"
        end

        def write x, field_name_sym, type_sym

          send :"__write__#{ type_sym }__", x, field_name_sym
          NIL_
        end

      private

        # ~ level 1

        def __write__number__ x, name_sym

          # meh for now

          @io.write "#{ INDENT__ }#{ name_sym } #{ x }\n"
          NIL_
        end

        def __write__string__ s, name_sym

          _write_string_stream(
            Common_::Stream.via_item( s ), name_sym, INDENT__ )
        end

        def __write__string_array__ a, name_sym

          _write_string_stream(
            Common_::Stream.via_nonsparse_array( a ), name_sym, INDENT__ )
        end

        # ~ end

        def _write_string_stream st, name_sym, margin

          @io.write "#{ margin }#{ name_sym }"  # no newline yet

          s = st.gets
          if s

            margin_ = "#{ INDENT__ }#{ margin }"

            s_ = st.gets

            if s_

              @io.write NEWLINE_

              __write_first_string s, margin_

              s = s_
              begin
                __write_additional_string s, margin
                s = st.gets
                s or break
                redo
              end while nil
            else
              __write_only_string s, margin_
            end

            @io.write NEWLINE_
          end
        end

        def __write_first_string s, margin
          _write_string false, s, margin
        end

        def __write_additional_string s, margin
          _write_string true, s, margin
        end

        def __write_only_string s, margin

          # for aesthetics, when there is only one string render it on the
          # same line as its parent node unless it contains a real newline

          if s.include? NEWLINE_

            @io.write NEWLINE_
            _write_string false, s, margin

          else
            _write_string false, s, SPACE_
          end
        end

        def _write_string is_addtnl, s, margin

          if s.length.zero? || COMPLEX_RX___ =~ s
            __write_quoted_string is_addtnl, s, margin
          else
            _write_simple_string is_addtnl, s, margin
          end
        end

        COMPLEX_RX___ = /['" \t\r\n()]/

        def __write_quoted_string is_addtnl, s, margin
          s = s.dup
          s.gsub! ESC_RX___ do
            "\\#{ $~[ 0 ] }"
          end

          if NL_RX___ =~ s
            __write_multiline_escaped_string is_addtnl, s, margin
          else
            _write_simple_string is_addtnl, "\"#{ s }\"", margin
            NIL_
          end
        end

        ESC_RX___ = /[\\"]/
        NL_RX___ = /[\n\r]/

        def _write_simple_string is_addtnl, s, margin

          if is_addtnl
            @io.write COMMA___
          else
            @io.write margin
          end
          @io.write s
          NIL_
        end

        COMMA___ = ", "

        def __write_multiline_escaped_string is_addtnl, string, margin

          st = Basic_[]::String::LineStream_via_String[ string ]

          s = st.gets
          if s
            @io.write "#{ margin }\"#{ s }"
            begin
              s = st.gets
              s or break
              @io.write "#{ margin }#{ s }"
              redo
            end while nil
            @io.write "    \""
          end
          NIL_
        end

        INDENT__ = '  '.freeze

      public

        def flush
          ACHIEVED_
        end
      end
    # -
  end
end
