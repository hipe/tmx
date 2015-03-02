module Skylab::SubTree

  class Output_Adapters_::Continuous

    class Traversal

      Callback_::Actor.methodic self, :properties,
        :sep,
        :do_verbose_lines

      def initialize & edit_p
        @curr_a = []
        @do_verbose_lines = false
        @matrix_a = []

        instance_exec( & edit_p )

        @glyph_set ||= SubTree_.lib_.CLI_lib.tree.glyph_sets_module::WIDE
        @sep ||= SEP_
      end

      def accept_selective_listener_proc oes_p
        @on_event_selectively = oes_p ; nil
      end

    private

      def output_proc=

        p = iambic_property

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

      # <-

    def puts line, extra_x=nil
      self.<<( line.split( @sep ), extra_a )
    end

    def << a, extra_x=nil
      xtra_x = nil
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

    def puts_with_free_cel line, any_free_cel
      puts line, any_free_cel
    end

    def flush  # to say you are done adding lines
      row nil ; nil
    end

  private

    def row seen_a, extra_x=nil
      if seen_a
        @do_verbose_lines and say_row( seen_a, extra_x )
        len = seen_a.length
        min_a = ::Array.new len
        len.zero? or min_a[ -1 ] = Node_.new( seen_a.last, extra_x )
        @matrix_a << min_a
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
    #
    Node_ = ::Struct.new :slug, :extra_x

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

    SubTree_.lib_.CLI_lib.tree.glyphs.each_const_value do |glyph|
      m = glyph.normalized_glyph_name
      define_method m do
        @glyph_set[ m ]
      end
    end  # blank crook pipe separator tee

    # ->

    end
  end
end
