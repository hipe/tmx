module Skylab::TMX

  class CLI

    module HelpScreen  # should be spliced into ancient

      class ForBranch

        class << self
          def express_into io
            yield new io
          end
          private :new
        end  # >>

        def initialize io
          @_boundary = :__first_boundary
          @_express_blank_line = io.method :puts
          @out = io
        end

        def operation_description_hash h

          a = []
          max = 0
          h.keys.each do |sym|
            name = Common_::Name.via_variegated_symbol sym
            len = name.as_slug.length
            max = len if max < len
            a.push name
          end
          @__max_name_width = max
          @__names = a
          @__operation_description_hash = h
          NIL
        end

        def usage program_name

          _boundary

          line_buffer = "usage: #{ program_name }"
          st = _to_operation_name_stream
          one = st.gets
          if one
            line_buffer << " { " << one.as_slug
            begin
              nm = st.gets
              nm || break
              line_buffer << PIPEY___ << nm.as_slug
              redo
            end while above
            line_buffer << " }"
          end
          line_buffer << " [opts]"
          @out.puts line_buffer
          NIL
        end

        def description_by & user_p

          _boundary

          p = -> line do
            p = @_express_blank_line
            @out.puts "description: #{ line }"
          end

          _y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end

          user_p[ _y ]
          NIL
        end

        def express_operation_descriptions_against branch_client

          _boundary

          @out.puts "operations:"

          two_spaces = "  "

          fmt = "#{ two_spaces }%#{ @__max_name_width }s"

          indent_with_spaces = fmt % nil

          subsequent_line = -> line do
            @out.puts "#{ indent_with_spaces }#{ two_spaces }#{ line }"
          end

          buff = ""
          p = nil

          first_line = -> line do
            buff << two_spaces
            buff << line
            @out.puts buff
            p = subsequent_line
          end

          y = ::Enumerator::Yielder.new do |line|
            p[ line ]
          end

          h = @__operation_description_hash

          item = -> nm do
            buff = fmt % nm.as_slug
            p = first_line
            _m = h.fetch nm.as_variegated_symbol
            branch_client.send _m, y
          end

          subsequent_boundary = -> do
            buff.clear
            @_express_blank_line[]
          end

          boundary = -> do
            boundary = subsequent_boundary
          end

          st = _to_operation_name_stream
          begin
            nm = st.gets
            nm || break
            boundary[]
            item[ nm ]
            redo
          end while nil
          NIL
        end

        def _to_operation_name_stream
          Stream_[ @__names ]
        end

        def _boundary
          send @_boundary
        end

        def __first_boundary
          @_boundary = :__subsequent_boundary
        end

        def __subsequent_boundary
          @out.puts
        end

        # ==

        PIPEY___ = ' | '
      end
    end
  end
end
