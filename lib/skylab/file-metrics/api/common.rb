module Skylab::FileMetrics

  module API
    module Common
    end

    class RuntimeError < ::RuntimeError
    end

    class SystemError < ::SystemCallError
    end
  end

  module API::Common::ModuleMethods

    def run *a
      new(* a ).run
    end
  end

  module API::Common::InstanceMethods

  protected

    def initialize *a
      @ui, @req = a
    end

    def error msg
      @ui.err.puts msg
      false
    end

    -> do  # `count_lines`
      noop = -> _ { } ; vp = nil
      define_method :count_lines do |file_a, label=nil|
        filter_a = []
        plus, minus = if ! @req.fetch( :info_volume ) then [ noop, noop ] else
          [ vp[ 'include' ], vp[ 'exclude' ] ]
        end
        if @req[:count_blank_lines] then plus[ :blank_lines ] else
          minus[ :blank_lines ]
          filter_a << "grep -v '^[ \t]*$'"
        end
        if @req[:count_comment_lines] then plus[ :comment_lines ] else
          filter_a << "grep -v '^[ \t]*#'"
        end
        label ||= '.'
        count = if filter_a.length.zero?
          linecount_using_wc file_a, label
        else
          linecount_using_grep_chain file_a, filter_a, label
        end
        # (no `collapse_and_distribute` here, caller might customize its call)
        count
      end

      noun_h = build_noun_h = nil

      vp = -> verb_stem do
        -> noun_ref do
          noun_h ||= build_noun_h[ ]

        end
      end

      build_noun_h = -> do
        {
          blank_lines:   Headless::NLP::EN::POS::Noun[ 'blank line' ],
          comment_lines: Headless::NLP::EN::POS::Noun[ 'comment line' ]
        }
      end

    end.call

    def linecount_using_grep_chain file_a, filter_a, label
      cmd_tail = "#{ filter_a * ' | ' } | wc -l"
      file_a.reduce( linecount_class.new label ) do |coun, file|
        cmd = "cat #{ shellescape_path file } | #{ cmd_tail }"
        if @req[:show_commands] || @req.fetch( :trace_volume )
          @ui.err.puts cmd
        end
        rs = %x{ #{ cmd } }
        cnt = linecount_class.new file
        if rs =~ /\A[[:space:]]*(\d+)[[:space:]]*\z/
          cnt.count = $1.to_i
        else
          cnt.notice = "(parse failed - #{ rs })"
        end
        coun << cnt
        coun
      end
    end

    def linecount_class
      self.class.const_get :LineCount, false  # meh
    end

    def linecount_using_wc file_a, label
      # (this hackery deserves explanation: we assume the following: there
      # is one corresponding output line from `wc` for each argument (treated
      # as input file) (the stream to which that line was written will be
      # either stdout or stderr depending on whether an error was encountered
      # (e.g "No such file or directory")). Additionally there is one final
      # "X total" line (where 'X' is the sum of etc) IFF there were more than
      # one argument to `wc`. (Hence there will always be either one line
      # of output or greater than two lines of output, never two.)
      # (the above is tracked with [#001])
      #
      # Now, on top of all that, we pipe all this to `sort -g`
      # (--general-numeric-sort), which doesn't mangle the position of our
      # "X total" line only because that line always has the greatest number,
      # hence always ends up at the end (where it started) after sorting!)
      #

      count = linecount_class.new label
      file_a.length.zero? and return count  # we usu. avoid return, 2 easy here
      cmd = "wc -l #{ file_a.map(& method(:shellescape_path )) * ' '} | sort -g"
      if @req[:show_commands] || @req.fetch( :debug_volume )
        @ui.err.puts cmd
      end
      line_a = `#{ cmd }`.split "\n"  # [#004] backticks might change
      if line_a.length.zero?
        raise SystemError, 'never'
      else
        one = 1 == file_a.length
        range = if one then 0..0 else 0..-2 end
        line_a[ range ].reduce count do |coun, line|
          if ! ( /\A *(\d+) (.+)\z/ =~ line )  # [#002]
            raise SystemError, "expecting integer token - #{ line }"
          end
          coun << linecount_class.new( $2, $1.to_i )
          coun
        end
        if ! one
          if ! ( /\A *(\d+) total\z/ =~ line_a.last )
            raise SystemError, "expecting total line - #{ line_a.last }"
          end
          count.count = $1.to_i  # here is [#001] - let wc to the addition
        end
      end
      count
    end

    define_method :shellescape_path, & FUN.shellescape_path
    protected :shellescape_path

    def rndr_tbl count, out, sexp
      if count.zero_children?
        out.puts "(table has no rows)"
        false
      else
        field_a = count.first_child.class.members
        mani = Services::Table::Manifold.new sexp do |mn|
          mn.hdr = -> m do
            m.to_s.split( '_' ).map(& :capitalize ) * ' '
          end
          mn.add_fields count.first_child.class.members  # did we forget any?
        end
        row_a = [ mani.build_header_row ]
        row_a.concat count.each_child.map(& mani.method( :build_row ) )
        wat = count.summary_rows
        row_a.concat count.summary_rows.map(& mani.method( :build_row ) )
        Models::Table.new( row_a ).render( out )
      end
    end
  end
end
