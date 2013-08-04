module Skylab::SubTree

  class API::Actions::My_Tree::Traversal_

    MetaHell::FUN::Fields_[ :client, self, :method, :absorb, :field_i_a,
      [ :out_p, :sep, :do_verbose_lines, :info_p ] ]

    def initialize * a
      absorb( * a )
      @curr_a = [] ; @matrix_a = [] ; @sep ||= SEP_
      @glyph_set = Headless::CLI::Tree::Glyph::Sets::WIDE
    end

    def puts line, extra_x=nil
      a = line.split @sep ; xtra_x = nil
      a.reduce [] do |seen_a, s|  # note this effectively skips blank lines!
        seen_a << s
        idx = ( 0 ... @curr_a.length ).detect { |i| @curr_a[i] != seen_a[i] }
        if idx
          if idx < seen_a.length
            ( @curr_a.length - idx ).times { @curr_a.pop } # pop the curr_a
            do_push = true        # stack down to a place where it matches
          end                     # else seen_a is already covered by curr_a
        elsif @curr_a.length != seen_a.length
          do_push = true          # seen_a is one level deeper than curr_a
        end                       # else they are identical
        extra_x and xtra_x = a.length == seen_a.length ? extra_x : nil
        if do_push                # then seen_a is one level under curr_a
          @curr_a << seen_a.last
          row seen_a, xtra_x
        else
          xtra_x and fail "sanity - extra info on a redundant row?"
        end
        seen_a
      end
      nil
    end

    def flush_notify  # to say you are done adding lines
      row nil
      nil
    end

  private

    def row seen_a, extra_x=nil
      if seen_a
        @do_verbose_lines and say_row( seen_a, extra_x )
        min_a = ::Array.new seen_a.length
        seen_a.empty? or min_a[ -1 ] = [ seen_a.last, extra_x ].compact * ' '
        @matrix_a << min_a
        pipe_d = seen_a.length - 2             # the imainary pipe is last nil
        d = @matrix_a.length - 1
      else                                     # a flush run
        pipe_d = -1                            # the imaginary pipe would go
        d = @matrix_a.length                   # off the chart
      end
      sub_flush d, pipe_d
      if @matrix_a.length.nonzero? and @matrix_a.first.first  # if flushable
        loop do                                # flush each contiguous row
          @out_p[ @matrix_a.shift * ' ' ]      # starting from the first one
          @matrix_a.first && @matrix_a.first.first or break
        end
      end
      nil
    end

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

    Headless::CLI::Tree::Glyphs.each do |glyph|
      m = glyph.normalized_glyph_name
      define_method m do @glyph_set[ m ] end
      private m
    end  # blank crook pipe separator tee
  end
end
