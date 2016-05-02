module Skylab::System

  module Filesystem

    class Pather  # :[#005].

      # a "conversion" is converting "/home/me/foo" to "~/foo", or
      # converting "/foo/bar/baz" to "./baz" (when present working directory
      # is "/foo/bar").
      #
      # we decide whether or not to do a conversion (and which conversion
      # to do) based on whether the would-be replacement path has fewer
      # *items* than the input path. ("/a/b", "a/b" and "~/b" each have 2
      # items.)
      #
      # the number of items that would be in the replacement path is:
      #
      #     glyph cost +
      #     length - N +
      #     length' - N
      #
      # or
      #     C + length + length' - 2N
      #
      # where:
      #
      #   • "glyph cost" is a constant for the number of items in the glyph
      #      (for now always 1 (for "~" or "." as appropriate). (for a
      #      special class of cases we adjust this down to zero #here-2.)
      #
      #   • "length" is how many items in the (absolute) HOME or PWD path
      #
      #   • "length'" is how many items in the argument path and
      #
      #   • N is the number of common leading items in the 2 paths.
      #
      # so for example if HOME path is "/home/momma"
      # and argument path is "/home/momma/foo":
      #
      #     length is 2, length' is 3, N is 2 so the would-be length is
      #     1 + 2 + 3 - 2*2 = 2
      #     the would-be length is 2, the current length is 3 so the
      #     substitution wins over the argument.
      #
      # but in PWD path /one/two/three/four
      # and argument path /one/two/five/six
      #
      #     length is 4, length' is 4, N is 2 so
      #     1 + 4 + 4 - 2*2 = 5
      #     the would-be length 5 is longer than the argument length
      #     so we do *not* convert to:
      #
      #         ./../../five/six

      def initialize home_path, pwd_path

        a = []

        if home_path  # (home precedes pwd as mentioned #here and as covered)
          a.push Home_Converter___.new home_path
        end

        if pwd_path
          a.push PWD_Converter___.new pwd_path
        end

        @_converters = a
      end

      def call path  # assume nonzero length string

        if FILE_SEPARATOR_BYTE == path.getbyte( 0 )

          ar = Argument_Representation___.new path

          a = nil

          @_converters.each do |cvrtr|
            ticket = cvrtr._ticket_for ar
            ticket or next
            ( a ||= [] ).push ticket
          end

          if a

            conversion = a.reduce do |m, x|

              # in case of tie, leave the incumbent as the winner per
              # order #here and the test that says home should win over pwd

              x.would_be_length < m.would_be_length ? x : m
            end

            if conversion.would_be_length < ar.length
              conversion.assemble
            else
              path
            end
          else
            path
          end
        else
          path
        end
      end

      # ==

      Converter__ = ::Class.new

      ( Home_Converter___ = ::Class.new Converter__ )::GLYPH = '~'

      ( PWD_Converter___ = ::Class.new Converter__ )::GLYPH = '.'

      Conversion__ = ::Class.new

      # == comment this section out and see the change
      #      (exactly one test covers it at writing)

      class PWD_Converter___

        def _ticket_for ar
          ti = super
          if ti
            # if we found a conversion that can be made and we would have
            # any leading DOT_DOT_ items, don't lead with the single dot #here-2
            if ti.N < length
              ETC___.new ti, ar, self
            else
              ti
            end
          end
        end
      end

      class ETC___ < Conversion__

        def initialize ti, ar, cvrtr
          @AR = ar
          @converter = cvrtr
          @N = ti.N
          @would_be_length = ti.would_be_length - 1
        end

        def assemble  # (compare with other)

          buffer = DOT_DOT_.dup

          ( @converter.length - @N - 1 ).times do
            buffer << ::File::SEPARATOR << DOT_DOT_
          end

          s_a = @AR.string_array
          @N.upto( @AR.length - 1 ) do |d|
            buffer << ::File::SEPARATOR << s_a.fetch( d )
          end

          buffer
        end
      end

      # ==

      class Conversion__

        def initialize ar, cvrtr
          @AR = ar
          @converter = cvrtr
        end

        def assemble

          buffer = "#{ @converter.class::GLYPH }"

          ( @converter.length - @N ).times do
            buffer << ::File::SEPARATOR << DOT_DOT_
          end

          s_a = @AR.string_array
          @N.upto( @AR.length - 1 ) do |d|
            buffer << ::File::SEPARATOR << s_a.fetch( d )
          end

          buffer
        end

        def execute
          __calculate_N
          if @N.zero?
            NOTHING_
          else
            @would_be_length = 1 + @converter.length + @AR.length - ( 2 * @N )
            self
          end
        end

        def __calculate_N

          # we avoid counting all the items in arg if we don't have to (crazy)

          len = @converter.length
          _min = if @AR.has_more_items_than len
            len
          else
            @AR.items_count
          end

          # (same algorithm as in [#ba-002]:)

          s_a = @converter.string_array
          s_a_ = @AR.string_array

          deepest_index = nil
          _min.times do |d|
            if s_a.fetch( d ) == s_a_.fetch( d )
              deepest_index = d
              next
            end
            break
          end

          @N = if deepest_index
            deepest_index + 1
          else
            0
          end ; nil
        end

        attr_reader(
          :would_be_length,
          :N,
        )
      end

      # ==

      class Converter__

        def initialize path
          s_a = path.split ::File::SEPARATOR
          s_a.first.length.zero? or self._SANITY  # these paths must be absoulte
          s_a.shift
          @length = s_a.length
          @string_array = s_a
        end

        def _ticket_for ar
          Conversion__.new( ar, self ).execute
        end

        attr_reader(
          :length,
          :string_array,
        )
      end

      # ==

      class Argument_Representation___

        def initialize path
          @_done = false
          @_length = 0
          @string_array = []

          scn = Home_.lib_.string_scanner path

          @_st = -> do

            _x = scn.getch
            _x == ::File::SEPARATOR or self._SANITY
            @_length += 1
            if scn.eos?
              # the path was trailing a separator.
              @string_array.push EMPTY_S_
              @_done = true
              false
            else
              s = scn.scan RX___
              @string_array.push s
              if scn.eos?
                @_done = true
                false
              else
                true
              end
            end
          end
        end

        RX___ = /[^#{ ::Regexp.escape ::File::SEPARATOR }]*/

        def has_more_items_than num
          if @_done
            @_length > num
          else
            _calculate_if_has_more_items_than num
          end
        end

        def length
          until @_done
            _calculate_if_has_more_items_than @_length
          end
          @_length
        end

        def _calculate_if_has_more_items_than num
          st = @_st
          begin
            _stay = st.call
            if _stay
              if @_length > num
                yes = true
                break
              end
              redo
            end
            yes = @_length > num
            break
          end while nil
          yes
        end

        def items_count
          @_length
        end

        attr_reader(
          :string_array,
        )
      end
    end
  end
end
# #tombstone: absolute path hack rx
