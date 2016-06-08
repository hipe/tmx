module Skylab::SearchAndReplace

  module Magnetics_::ReadOnly_FileSession_Stream_via_FileSession_Stream  # 1x

    class << self
      def [] up, & p
        Sessioner___.new up, & p
      end
    end  # >>

    class Sessioner___

      def initialize up, & oes_p

        @__prototype = Session___.new(
          up.ruby_regexp,
          & oes_p )
      end

      def produce_file_session_via_ordinal_and_path d, path
        @__prototype.new d, path
      end
    end

    class Session___

      def initialize rx, & p

        @ruby_regexp = rx

        @_oes_p = p
        freeze
      end

      def new d, path
        dup.___init_copy d, path
      end

      def ___init_copy d, path
        @ordinal = d
        @path = path
        freeze
      end

      attr_reader(
        :ordinal,
        :path,
        :ruby_regexp,
      )

      def to_read_only_match_stream
        to_read_only_match_stream_when_multi_line
      end

      # -

        def to_read_only_match_stream_when_multi_line
          match = Read_Only_Match___.new @path
          whole_file = ::File.read @path
          line_number = 1
          last_begin = 0
          beg_pos = 0
          with_match = -> md do

            this_begin, next_begin = md.offset 0

            # advance current line number
            d = whole_file.index NEWLINE_, last_begin
            while d && d < this_begin
              line_number += 1
              d = whole_file.index NEWLINE_, d + 1
            end
            last_begin = this_begin

            # find any leading string between match and beginning of line
            d = this_begin
            while d.nonzero?
              d -= 1
              if NEWLINE_CHAR__ == whole_file.getbyte( d )
                d += 1
                break
              end
            end
            if d < this_begin
              before_match = whole_file[ d ... this_begin ]
            end

            # find any trailing string between match and end of line
            # don't bother if final character of match is the delimiter
            d = whole_file.index NEWLINE_, ( next_begin - 1 )
            if d && d >= next_begin
              after_match = whole_file[ next_begin .. d ]
            end

            beg_pos = next_begin
            match.dup_via line_number, before_match, md, after_match
          end
          p = -> do
            md = @ruby_regexp.match whole_file, beg_pos
            if md
              with_match[ md ]
            else
              p = EMPTY_P_
              nil
            end
          end
          Common_.stream do
            p[]
          end
        end

        NEWLINE_CHAR__ = NEWLINE_.getbyte 0

        def __to_read_only_match_stream_when_single_line__  # #open [#007]
          io = ::File.open @path, ::File::CREAT | ::File::RDONLY
          line_number = 0
          rx = @ruby_regexp
          Common_.stream do
            while line = io.gets
              line_number += 1
              md = rx.match line
              if md
                x = match.dup_via md, line_number, line
                break
              end
            end
            x
          end
        end

        class Read_Only_Match___

          # one way to make this expressable under a textual context would be
          # to implement `express_into_under` here. but because this node is
          # the frontier for [#ze-010] custom view (controllers) we use that
          # means instead.

          def initialize path
            @path = path
            freeze
          end

          def dup_via * a
            dup.___init_copy a
          end

          def ___init_copy a
            @lineno, @before_match, @md, @after_match = a
            freeze
          end

          def to_line_stream
            to_line_stream_under THE_PASS_THRU_EXPAG___
          end

          def to_line_stream_under expag
            otr = dup
            otr.extend Line_Stream_via_Match___
            otr.expag = expag
            otr.execute
          end

          attr_reader(
            :lineno,
            :md,
            :path,
          )
        end

        module THE_PASS_THRU_EXPAG___ ; class << self
          def map_match_line_stream st
            st
          end
        end ; end

        module Line_Stream_via_Match___  # #[#sl-003]

          # effect these three aspects while streaming the lines of a match:
          #
          #   • the match may span multiple lines
          #
          #   • express any `@before_match` and `@after_match` before
          #     the first and after last lines respectively (the same
          #     line when one line).
          #
          #   • map thru the expag for styling before the above behavior.

          # #open [#009] this probably duplicates efforts of the edit session
          # (but then why is its logic unrecognizable? maybe it's fine..)

          attr_writer(
            :expag,
          )

          def execute

            _st = Home_.lib_.basic::String.line_stream @md[ 0 ]
            @_st = @expag.map_match_line_stream _st
            @_p = method :___gets_first_line

            Common_.stream do
              @_p.call
            end
          end

          def ___gets_first_line
            first_line = @_st.gets
            if first_line
              second_line = @_st.gets
              if second_line
                @_line_on_deck = second_line
                @_p = method :___gets_subsequent_line
                "#{ @before_match }#{ first_line }"
              else
                _close
                "#{ @before_match }#{ first_line }#{ @after_match }"
              end
            else
              _close
            end
          end

          def ___gets_subsequent_line

            line_after = @_st.gets
            if line_after
              s = @_line_on_deck
              @_line_on_deck = line_after
              s
            else
              _close
              "#{ @_line_on_deck }#{ @after_match }"
            end
          end

          def _close
            @_p = EMPTY_P_
            NOTHING_
          end
        end
      # -
    end  # session
  end  # magnetic
end
