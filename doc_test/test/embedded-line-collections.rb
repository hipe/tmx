module Skylab::DocTest::TestSupport

  module Embedded_Line_Collections  # :[#022].

    def self.[] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___ ; nil
    end

    # this file facilities the parsing of "embedded lines collections"
    # (ELC's) in a file. this is an ad-hoc facility made only to support
    # the testing of implementation sub-systems of the subject sidesystem.
    # (although superficially it has aspects that resemble the core functions
    # of the subject sidesystem, these similarities are indeed only
    # superficial.)
    #
    # as a historical note, this "format" and interface is a distillation
    # and rewriting of years of similar solutions that were much worse.
    #
    #   • the way (and only way) an ELC is expressed is with this
    #     pseudopattern:
    #
    #       1) a line ending in ":",
    #
    #       2) (zero or more blank lines may exist and are skipped)
    #
    #       3) THEN if any next line has one or more leading tab-or-space
    #          characters before a "content" character (non-whitespace),
    #          this line serves as the first line of the ELC. (this
    #          leading whitespace determines the ELC margin which will
    #          be removed from each line in the ELC.)
    #
    #       4) we add to the ELC each additional line whose content starts
    #          somewhere after the margin. also blank lines are added to the
    #          ELC. the first line that has content that starts before the
    #          margin (or when we run out of lines), this ends the ELC.
    #
    #       5) once the ending has been found to the ELC, we remove trailing
    #          blank lines from it.
    #
    #   • as such, there is a limit to the shape of "document" you can
    #     express in such an ELC:
    #
    #       • it can't have zero lines
    #       • the first line can't have a margin
    #       • the last line must have some content.
    #
    #   • always you access a collection of "embedded lines" by using
    #     a regex for matching the last line before the embedded lines.
    #
    #   • the regex does not act as a "key". you can use any regex that
    #     matches one such line and your result will be the first embedded
    #     lines collection whose identifying line matches the regex.
    #
    #   • as an implementation detail, each collection is discovered
    #     lazily, as more are needed to try and find a match for the
    #     provided regex.
    #
    #   • everything is memoized lazily such that no file (abspath)
    #     is ever read more than once. as a precaution, the ELC lines
    #     will be frozen (so they cannot for example be chomped).
    #
    #   • ISSUE: at present, the opened file will never close..

    module ModuleMethods___

      def in_file & p
        yes = true ; x = nil
        define_method :_ELC_path_for_in_file do
          if yes
            yes = false
            x = instance_exec( & p )
          end
          x
        end
      end
    end

    module InstanceMethods___

      def _ELC_line_stream_after rx

        Common_::Stream.via_nonsparse_array __ELC_lines_after rx
      end

      def __ELC_lines_after rx

        _ELC_file.line_array_via_regex rx
      end

      def _ELC_close_if_necessary
        _ELC_file.close_if_necessary
      end

      def _ELC_file
        ___ELC_file_via_path _ELC_path_for_in_file
      end

      -> do
        cache = {}
        define_method :___ELC_file_via_path do |path|
          cache.fetch path do
            x = File___.new ::File.open( path, ::File::RDONLY )
            cache[ path ] = x
            x
          end
        end
      end.call
    end

    # ==

    class File___

      def initialize line_stream

        @_cache = []
        @_line = line_stream.gets
        @line_stream = line_stream
        @_hot = true
      end

      def line_array_via_regex rx

        if @_hot
          col = __lookup rx
        end

        if ! col
          col = __seek_in_cache rx
        end

        col.lines
      end

      def close_if_necessary
        if @_hot
          @_hot = false
          @line_stream.close  # eek/meh
        end
        NIL_
      end

      def __seek_in_cache rx

        @_cache.detect do |col|
          col.identifying_string =~ rx
        end
      end

      def __lookup rx

        line = remove_instance_variable :@_line
        st = @line_stream

        begin
          line or break

          md = COLON_RX___.match line
          if ! md
            line = st.gets
            redo
          end

          identifying_s = md.pre_match  # not always used

          begin  # skip these leading blank lines
            line = st.gets
            line or break
            if BLANK_RX_ =~ line
              redo
            end
          end while nil

          line or break

          md = INDENTED_RX__.match line
          if ! md
            # (happens when there is a tail colon that is NOT for an ELC)
            redo   # redo with current line!
          end

          # NOW we've got the identifying string AND one or more ELC lines!

          cache = []

          current_indent_level = -> do
            md.offset( 0 ).last
          end

          indent_level = current_indent_level[] ; md = nil

          accept_curent_line = -> do
            r = indent_level .. -1
            -> do
              cache.push line[ r ].freeze
            end
          end.call

          accept_curent_line[]
          line = st.gets

          begin
            line or break  # NOTE the file can end here

            if BLANK_RX_ =~ line
              md = INDENTED_RX__.match line
              if md
                indent_level_ = current_indent_level[]
                if indent_level_ < indent_level
                  ::Kernel._RIDE_THIS
                  cache.push NEWLINE_  # assumes #spot-2 (frozen)
                else
                  ::Kernel._RIDE_THIS
                  accept_curent_line[]
                end
              else
                cache.push line.freeze  # sure why not
              end
              line = st.gets
              redo
            end

            md = INDENTED_RX__.match line
            _this_line_is_in = if md
              indent_level_ = current_indent_level[]
              if indent_level_ < indent_level
                ::Kernel._RIDE_THIS
                false
              else
                true
              end
            else
              false
            end

            if _this_line_is_in
              accept_curent_line[]
              line = st.gets
              redo
            end

            break  # current line is nil or the next ordinary line
          end while nil

          while BLANK_RX_ =~ cache.last
            cache.pop
          end

          cache.freeze
          col = Collection___.new identifying_s, cache.freeze
          cache = nil ; identifying_s = nil

          @_cache.push col

          if rx =~ col.identifying_string
            @_line = line
            break
          end
          col = nil

          if line
            redo
          end

          break
        end while nil

        if col
          col
        else
          raise ___say_not_found rx
        end
      end

      def ___say_not_found rx
        "no ELC matching /#{ rx.source }/ across #{ @_cache.length } ELC's"
      end

      BLANK_RX_ = Home_::BLANK_RX_
      COLON_RX___ = /:$/
      INDENTED_RX__ = /\A[\t ]+(?=[^[:space:]])/
    end

    # ==

    class Collection___

      def initialize identifying_string, lines
        @identifying_string = identifying_string
        @lines = lines
      end

      attr_reader(
        :identifying_string,
        :lines,
      )
    end
  end
end
