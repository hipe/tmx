module Skylab::MyTree

  class API::Actions::Tree::Tree  # will likely be moved [#mt-004]
    # extend Headless::Parameter::Definer

    include Headless::Parameter::Controller::InstanceMethods

    def flush                     # tell it you are not adding more lines
      row nil
      nil
    end

    def puts line, extra=nil
      a = line.split separator
      use_extra = nil
      a.reduce [] do |seen, s|    # note this effectively skips blank lines!
        seen.push s
        idx = (0 ... @current.length).detect { |i| @current[i] != seen[i] }
        if idx
          if idx < seen.length
            (@current.length - idx).times { @current.pop } # pop the current ..
            push = true           # stack down to a place where it matches seen
          end                     # else seen is already covered by current
        elsif @current.length != seen.length
          push = true             # seen is one level deeper than current
        end                       # else they are identical
        if extra
          use_extra = a.length == seen.length ? extra : nil
        end
        if push                   # then seen is one level under current
          @current.push seen.last
          row seen, use_extra
        elsif use_extra
          fail "sanity - had extra info on a redundant row"
        end
        seen
      end
    nil
    end

  private

    # (note: `do_verbose_lines` is so verbose we recommend you only use
    # it when you are troubleshooting the flushing behavior. it's neat
    # to see, once.)

    def initialize request_client, do_verbose_lines
      init_headless_sub_client request_client
      @current = []
      @glyph_set = Headless::CLI::Tree::Glyph::Sets::WIDE
      @matrix = []
      @do_verbose_lines = do_verbose_lines
    end

    def row seen, extra=nil
      if seen
        if @do_verbose_lines
          emit :info, "(adding row: #{ seen.inspect }#{ '..' if extra })"
        end
        minimal = ::Array.new seen.length
        seen.empty? or minimal[-1] = [seen.last, extra].compact.join(' ')
        @matrix.push minimal
        pipe = seen.length - 2                 # the imainary pipe is last nil
        y = @matrix.length - 1
      else # the flush run
        pipe = -1                              # the imaginary pipe would go
        y = @matrix.length                     # off the chart
      end
      while (y -= 1) >= 0                      # from bottom row to top
        row = @matrix[y]
        crook = row.length - 2                 # this is where the 'L' would go
        case pipe <=> crook
        when  0                                # pipe and crook in same spot,
          row[crook] ||= self.tee if crook >= 0  # which makes a tee
        when -1
          trueish = (0 ... row.length).detect { |x| row[x] } || -1
          row[pipe] ||= self.pipe if pipe >= 0
          (pipe + 1 ... [trueish, crook].min).each { |x| row[x] = self.blank }
          row[crook] ||= self.crook if crook >= 0
        end
      end
      if ! @matrix.empty? and @matrix.first.first # empty when nothing to flush
        loop do                                # flush each contiguous row
          emit :out, @matrix.shift.join(' ')   # starting from the first one
          @matrix.first && @matrix.first.first or break
        end
      end
      nil
    end

    Headless::CLI::Tree::Glyphs.each do |glyph|
      # blank crook pipe separator tee
      n = glyph.normalized_glyph_name
      define_method( n ) { @glyph_set[ n ] }
    end
  end
end
