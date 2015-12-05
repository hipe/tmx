module Skylab::Git

  class Models_::Stow

    class Models_::File_Patch

      # the foppish gimmick that necessitates around half the code in this
      # project is that of presenting ordinary text files as if they were
      # patches that create those files.
      #
      # the subject renders a file in such a way, while modeling each such
      # line of the patch in a structured way so that it can be expressed
      # either in color or in black and white later down in the pipeline.

      class << self

        def any * _3, & p

          new( _3, & p ).__to_OK
        end

        private :new
      end  # >>

      def initialize _3, & p

        @file_relpath, @stow_path, rsc = _3

        @system_conduit, @filesystem = rsc.to_a

        @on_event_selectively = p
      end

      def to_patch_item_stream

        Callback_::Stream.via_nonsparse_array @_item_a
      end

      def __to_OK

        # (sadly this is probably equivalent to one line of shell)

        _, o, e, w = @system_conduit.popen3 'file', '--brief', @file_relpath,
          chdir: @stow_path

        s = e.gets
        if s
          self._COVER_ME
        end

        s = o.gets
        s.chop!  # might fail
        s_ = o.gets

        if s_
          self._COVER_ME
        end

        d = w.value.exitstatus

        if d.nonzero?
          self._COVER_ME
        end

        if ASCII_RX___ =~ s

          __finish
        else
          @on_event_selectively.call :info, :emission, :skipping do | y |
            y << "# skipping #{ @file_relpath }: #{ s }"
          end
          NIL_
        end
      end

      ASCII_RX___ = /\AASCII\b/

      def __finish

        item_a = __build_item_array
        instance_variables.each do | ivar |
          remove_instance_variable ivar
        end

        @_item_a = item_a
        freeze
      end

      def __build_item_array

        _path = ::File.expand_path @file_relpath, @stow_path

        io = @filesystem.open _path

        item_a = [ nil, nil, nil ]
        begin
          line = io.gets
          line or break
          item_a.push Add_Line___.new( line )
          redo
        end while nil

        item_a[ 0 ] = DEV_NULL_ITEM___
        item_a[ 1 ] = After___.new @file_relpath
        item_a[ 2 ] = Chunk_Header___.new item_a.length - 3
        item_a
      end

      class Item__

        def to_styled_line

          content, nl = Newline_divmod___[ to_non_styled_line ]
          _content_ = Stylify__[ self.class::STYLE, content ]
          "#{ _content_ }#{ nl }"
        end

        def to_non_styled_line
          @bw_
        end

        def category_symbol
          self.class::CATEGORY
        end
      end

      Newline_divmod___ = -> do

        rx = /\A

          (.*[^\r\n]|)

          ([\r\n]*)

        \z/mx

        -> s do

          rx.match( s ).captures
        end
      end.call

      Stylify__ = -> do
        p = nil
        -> s_a, s do
          p ||= Home_.lib_.brazen::CLI_Support::Styling::Stylify
          p[ s_a, s ]
        end
      end.call

      File_Info__ = ::Class.new Item__

      class Before___ < File_Info__

        def initialize path

          @bw_ = "--- #{ common_init_ path }\n".freeze
        end

        def is_before
          true
        end

        LETTER = 'a'
      end

      class After___ < File_Info__

        CATEGORY = :file_info

        def initialize path

          @bw_ = "+++ #{ common_init_ path }\n".freeze
        end

        def is_before
          false
        end

        LETTER = 'b'
      end

      class File_Info__

        CATEGORY = :file_info
        STYLE = [ :strong, :red ]

        attr_reader(
          :path,
        )

        def common_init_ path

          @path, s = Path_divmod___[ path ]

          if s
            ::File.join self.class::LETTER, @path
          else
            @path
          end
        end
      end

      Path_divmod___ = -> do

        # if the path *looks* relative, split it up into a stem and some string

        sep = ::File::SEPARATOR
        sep_d = sep.getbyte 0

        -> path do

          if sep_d == path.getbyte( 0 )

            [ path ]

          else
            d = path.index sep
            if d
              d_ = d + 1
              [ path[ d_ .. -1 ], path[ 0, d_ ] ]
            else
              [ path, EMPTY_S_ ]
            end
          end
        end
      end.call

      class Chunk_Header___ < Item__

        CATEGORY = :chunk_header
        STYLE = [ :cyan ]

        attr_reader(
          :insertions_count,
        )

        def initialize d

          @insertions_count = d

          @bw_ = "@@ -0,0 +1,#{ d } @@\n".freeze
        end

        def deletions_count
          0
        end
      end

      DEV_NULL_ITEM___ = Before___.new '/dev/null'

      class Add_Line___ < Item__

        CATEGORY = :add
        STYLE = [ :green ]

        def initialize s
          @bw_ = "+#{ s }"
        end
      end
    end
  end
end
