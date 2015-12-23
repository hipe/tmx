module Skylab::SearchAndReplace

  module Magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream

        class String_Edit_Session___

          def initialize s, rx

            @_match_a = []
            @ruby_regexp = rx
            @string = s
            @_string_length = @string.length
            @_pos = 0

            @_done = @_string_length == @_pos
          end

          def set_path_and_ordinal path, d
            @ordinal = d
            @path = path ; nil
          end

          attr_reader(
            :ordinal,
            :path,
            :ruby_regexp,
            :string,
          )

          def has_at_least_one_match
            if @_match_a.length.zero? && ! @_done
              gets_match
            end
            @_match_a.length.nonzero?
          end

          def match_count

            _find_all_matches_if_necessary
            @_match_a.length
          end

          def match_at_index d

            if 0 > d
              _find_all_matches_if_necessary

            elsif ! @_done && @_match_a.length <= d
              __try_advance_to d
            end

            @_match_a[ d ]
          end

          def _find_all_matches_if_necessary
            if ! @_done
              nil while gets_match
            end
            NIL_
          end

          def __try_advance_to d
            stop_length = d + 1
            begin
              gets_match
              stop_length == @_match_a.length and break
            end while ! @_done
          end

          def gets_match
            if ! @_done
              md = @ruby_regexp.match @string, @_pos
              if md
                ___via_matchdata md
              else
                @_done = true
                @_pos = @_string_length
                NOTHING_
              end
            end
          end

          def ___via_matchdata md

            match_index = @_match_a.length
            match = Match___.new md, match_index, self
            @_match_a.push match
            @_pos = match.next_begin
            @_string_length == @_pos and @_done = true
            match
          end

          def line_number_of_byte_offset d
            # (etc for static strings a b-tree lookup would be "better" but meh)
            string_length = @string.length
            if -1 < d && d < string_length
              line_number = 0
              beg_pos = 0
              begin
                delim_pos = @string.index NEWLINE_, beg_pos
                if ! delim_pos
                  if d >= beg_pos  # don't act like `wc -l` - contrary to
                    # [#sg-020], if there are non-delimited trailing bytes
                    # and `d` is on that "line", we count it as a line.
                    line_number += 1
                  end
                  break
                end
                line_number += 1
                d <= delim_pos and break
                beg_pos = delim_pos + 1
              end while beg_pos < string_length
              line_number
            end
          end

          class Match___

            def initialize md, d, o

              @match_index = d
              @md = md
              @parent = o

              @begin, @next_begin = md.offset 0
            end

            def ordinal
              @match_index + 1
            end

            def first_line_number
              @parent.line_number_of_byte_offset @begin
            end

            def has_previous_match
              @match_index.nonzero?
            end

            def previous_match
              if @match_index.nonzero?
                @parent.match_at_index @match_index - 1
              end
            end

            def next_disengaged_match
              d = @match_index
              begin
                match = @parent.match_at_index( d += 1 )
                match or break
              end while match.replacement_is_engaged
              match
            end

            def next_engaged_match
              d = @match_index
              begin
                match = @parent.match_at_index( d += 1 )
                match or break
              end until match.replacement_is_engaged
              match
            end

            def has_next_match
              @next_match_existence_is_known ||= begin
                @has_next_match = next_match ? true : false
                true
              end
              @has_next_match
            end

            def next_match
              @parent.match_at_index @match_index + 1
            end

            def set_replacement_string x
              @replacement_is_engaged = true
              @replacement_string = x
              NIL_
            end

            def disengage_replacement
              @replacement_is_engaged = false
            end

            def to_replacement_segment_stream_proc
              Build_string_segment_proc_[ 0,
                @replacement_string.length,
                @replacement_string,
                Match_Segment_.new( @match_index, :replacement ) ]
            end

            attr_reader(
              :begin,
              :match_index,
              :next_begin,  # as opposed to "end" so you use "..." and not ".."
              :replacement_is_engaged,
              :replacement_string,
              :md,
            )
          end

          def to_line_stream
            Here__::Stream_Adapter___.new( self ).build_line_stream
          end

          # ~ context line streams (#note-105)

          def context_streams num_before, match_d, num_after

            _ = Here__::Build_context_streams___.new(
              num_before,
              match_d,
              num_after,
              @_match_a,
              @string )

            _.execute
          end

          class Segmented_Line_ < ::Array

            def to_flat_sexp  # #note-350
              y = []
              each do |seg|
                seg.write_sexp_to y
              end
              y
            end
          end

          Build_string_segment_proc_ = -> beg_pos, next_begin, string, cls do
            -> do
              if beg_pos < next_begin
                pos = string.index NEWLINE_, beg_pos
                if pos && pos < next_begin
                  seg = cls.new string[ beg_pos .. pos ], beg_pos
                  beg_pos = pos + 1
                else
                  seg = cls.new string[ beg_pos ... next_begin ], beg_pos
                  beg_pos = next_begin
                end
                seg
              end
            end
          end

          class Segment__

            def initialize s, d
              @string_index = d
              @string = s
              if s.length.nonzero? && DELIM_BYTE_ == s.getbyte( -1 )
                @has_delimiter = true
              end
              self
            end

            def members
              [ :has_delimiter, :is_in_match, :string, :string_index ]
            end

            attr_reader :has_delimiter, :string, :string_index

            def is_in_match
              false
            end

            def to_sexp
              write_sexp_to []
            end
          end

          class Normal_Segment_ < Segment__

            def write_sexp_to a
              a.push category, @string_index, @string
            end

            def category
              :normal
            end
          end

          class Match_Segment_ < Segment__

            alias_method :init_copy, :initialize
            protected :init_copy

            def initialize match_index, category
              @match_index = match_index
              @category = category
            end

            def members
              [ * super, :match_index ]
            end

            attr_reader :category, :match_index


            def write_sexp_to a
              a.push @category, @match_index, @string_index, @string
            end

            def is_in_match
              true
            end

            def new s, d
              dup.init_copy s, d
            end
          end

          DELIM_BYTE_ = NEWLINE_.getbyte 0

          Here__ = self

          NOTHING_ = nil  # in contrast with something
        end
  end
end
