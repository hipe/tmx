module Skylab::SubTree

  class Output_Adapters_::Continuous

    class Traversal

      Attributes_actor_ = Home_.lib_.fields::Attributes::Actor

      Attributes_actor_.call( self,
        do_verbose_lines: nil,
        sep: nil,
      )

      def initialize

        @curr_a = []
        @do_verbose_lines = false
        @matrix_a = []
      end

      def process_polymorphic_stream_passively st  # #[#fi-022]
        super && normalize
      end

      def normalize
        @glyph_set ||= Home_.lib_.basic::Tree.unicode::GlyphSets::WIDE
        @sep ||= SEP_
        KEEP_PARSING_
      end

    private

      def output_proc=

        p = gets_one_polymorphic_value

        case p.arity
        when 3     ; __resolve_downstream_proc_via_arity_of_three p
        when 2     ; __resolve_downstream_proc_via_arity_of_two p
        when 1, -1 ; __resolve_downstream_proc_via_arity_of_one_or_glob p
        else       ; __when_strange_arity
        end
      end

      def __resolve_downstream_proc_via_arity_of_three p  # glyphs, slug, extra

        @down_p = -> row_a do
          node = row_a.pop
          p[ row_a, * node.to_a ] ; nil
        end

        KEEP_PARSING_
      end

      def __resolve_downstream_proc_via_arity_of_two  # glyphs-slug, extra

        @down_p = -> row_a do
          node = row_a.pop
          slug, extra_a = node.to_a
          _x = "#{ "#{ row_a * SPACE_ } " if row_a.length.nonzero? }"
          p[ "#{ _x }#{ slug }", extra_a ] ; nil
        end

        KEEP_PARSING_
      end

      def __resolve_downstream_proc_via_arity_of_one_or_glob p  # glyphs-slug-extra

        @down_p = -> row_a do
          node = row_a.pop
          _x = "#{ "#{ row_a * SPACE_ } " if row_a.length.nonzero? }"
          p[ "#{ _x }#{ node.to_a.compact * SPACE_ }" ] ; nil
        end

        KEEP_PARSING_
      end

      def __when_strange_arity p
        raise ::ArgumentError, "unsupported `down_p` arity - #{ p.arity }"
      end

    public


      def puts line, extra_x=nil

        # the same as `line.chomp.split( @sep )` but less memory. meh

        a = [] ; d = 0 ; len = line.length ; last = len - 1 ; sep = @sep

        begin
          d_ = line.index sep, d
          if d_
            a.push line[ d ... d_ ]
            d = d_ + 1
            redo
          elsif len.zero?
            break
          else

            if NEWLINE_BYTE_ == line.getbyte( last )
              if last.zero?
                break
              end
              last -= 1
            end

            a.push line[ d .. last ]
            break
          end
        end while nil

        self.<<( a, extra_x )  # eew
      end

      NEWLINE_BYTE_ = NEWLINE_.getbyte 0

      # <-

    def << a, extra_x=nil

      xtra_x = nil

      a.reduce [] do |seen_a, s|  # note this effectively skips blank lines!

        seen_a.push s

        idx = ( 0 ... @curr_a.length ).detect do | d |
          @curr_a[ d ] != seen_a[ d ]
        end

        if idx
          if idx < seen_a.length
            ( @curr_a.length - idx ).times { @curr_a.pop } # pop the curr_a

            do_push = true        # stack down to a place where it matches
          end                     # else seen_a is already covered by curr_a
        elsif @curr_a.length != seen_a.length
          do_push = true          # seen_a is one level deeper than curr_a
        end                       # else they are identical

        if extra_x
          xtra_x = a.length == seen_a.length ? extra_x : nil
        end

        if do_push                # then seen_a is one level under curr_a
          @curr_a.push seen_a.last
          row seen_a, xtra_x
        else
          xtra_x and fail "sanity - extra info on a redundant row?"
        end

        seen_a
      end
      nil
    end

    def puts_with_free_cel line, any_free_cel
      puts line, any_free_cel
    end

    def flush  # to say you are done adding lines
      row nil
      ACHIEVED_
    end

  private

    def row seen_a, extra_x=nil

      if seen_a

        @do_verbose_lines and say_row( seen_a, extra_x )

        len = seen_a.length
        min_a = ::Array.new len

        if len.nonzero?
          min_a[ -1 ] = Branch_or_Leaf___.new( seen_a.last, extra_x )
        end

        @matrix_a.push min_a
        pipe_d = len - 2                       # the imaginary pipe is last nil
        d = @matrix_a.length - 1

      else                                     # a flush run
        pipe_d = -1                            # the imaginary pipe would go
        d = @matrix_a.length                   # off the chart
      end

      sub_flush d, pipe_d

      if @matrix_a.length.nonzero? and @matrix_a.first.first  # if flushable

        loop do                                # flush each contiguous row
          @down_p[ @matrix_a.shift ]            # starting from the first one
          @matrix_a.first && @matrix_a.first.first or break
        end
      end
      nil
    end

    Branch_or_Leaf___ = ::Struct.new :slug, :extra_x

    def sub_flush d, pipe_d

      while (( d -= 1 )) >= 0                  # from bottom row to top
        cel_a = @matrix_a[ d ]
        crook_d = cel_a.length - 2             # this is where the 'L' would go
        case pipe_d <=> crook_d
        when  0                                # pipe and crook in same
          crook_d >= 0 and cel_a[ crook_d ] ||= tee  # spot which makes a tee
        when -1
          idx = ( 0 ... cel_a.length ).detect( & cel_a.method( :[] ) ) || -1
          pipe_d >= 0 and cel_a[ pipe_d ] ||= pipe
          ( pipe_d + 1 ... [ idx, crook_d ].min ).each do |dd|
            cel_a[ dd ] = blank
          end
          crook_d >= 0 and cel_a[ crook_d ] ||= crook
        end
      end
      nil
    end

    def say_row seen_a, extra_x
      @info_p[ "(adding row: #{ seen_a.inspect }#{ '..' if extra_x })" ]
    end

  private

    Home_.lib_.basic::Tree.unicode::Glyphs.each_value do | g |

      m = g.normalized_glyph_name

      define_method m do
        @glyph_set[ m ]
      end
    end  # blank crook pipe separator tee

    # ->

    end
  end
end
