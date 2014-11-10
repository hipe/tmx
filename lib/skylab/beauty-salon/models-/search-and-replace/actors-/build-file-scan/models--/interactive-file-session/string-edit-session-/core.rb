module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_file_scan

      class Models__::Interactive_File_Session

        class String_Edit_Session_

          def initialize * a
            @string, @ruby_regexp, @on_event_selectively = a
            @string_length = @string.length
            @match_a = []
            @pos = 0
            @done = @string_length == @pos
          end

          attr_reader :string

          def match_at_index d
            if 0 > d
              if ! @done
                nil while gets_match
              end
            elsif ! @done && @match_a.length <= d
              try_advance_to d
            end
            @match_a[ d ]
          end

        private

          def try_advance_to d
            stop_length = d + 1
            begin
              gets_match
              stop_length == @match_a.length and break
            end while ! @done
          end

        public

          def gets_match
            if ! @done
              md = @ruby_regexp.match @string, @pos
              if md
                build_and_store_match_via_matchdata md
              else
                @done = true
                @pos = @string_length
                nil
              end
            end
          end

        private

          def build_and_store_match_via_matchdata md
            match_index = @match_a.length
            match = Match__.new md, match_index, self
            @match_a.push match
            @pos = match.next_begin
            @string_length == @pos and @done = true
            match
          end

          class Match__

            def initialize *a
              @md, @match_index, @parent = a
              @begin, @next_begin = md.offset 0
            end

            def members
              [ :begin, :next_begin, :md, :match_index ]
            end

            attr_reader :begin, :next_begin, :md
              # we call it "next begin" and not "end"
              # to remind you to use "..." and not ".."

            attr_reader :match_index

            def previous_match
              if @match_index.nonzero?
                @parent.match_at_index @match_index - 1
              end
            end

            def next_engaged_match
              d = @match_index
              begin
                match = @parent.match_at_index( d += 1 )
                match or break
              end until match.replacement_is_engaged
              match
            end

            def next_match
              @parent.match_at_index @match_index + 1
            end

            attr_reader :replacement_is_engaged, :replacement_string

            def set_replacement_string x
              @replacement_is_engaged = true
              @replacement_string = x
              nil
            end

            def to_replacement_segment_scan_proc
              Build_string_segment_proc_[ 0,
                @replacement_string.length,
                @replacement_string,
                Match_Segment_.new( @match_index, :replacement ) ]
            end
          end

        public

          def to_line_scan
            Self_::Mixed_Scan_Agent__.new( self ).build_line_scan
          end

          # ~ context line scanners (#note-105)

          def context_scanners num_before, match_d, num_after

            Self_::Build_context_scanners__.new( num_before, match_d, num_after,
              @match_a, @string ).execute

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

          Self_ = self
        end
      end
    end
  end
end
