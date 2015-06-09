module Skylab::FileMetrics

  module API::Common

    RuntimeError = ::Class.new ::RuntimeError

    SystemError = ::Class.new ::SystemCallError

    module ModuleMethods

      def run * x_a
        new( * x_a ).run
      end
    end

    module InstanceMethods
    private

      def initialize ui, req
        @ui = ui ; @req = req
      end

      def error msg
        @ui.err.puts msg
        UNABLE_
      end

      def build_find_files_command path_a

        FM_.lib_.system.filesystem.find(
          :paths, path_a,
          :ignore_dirs, @req[ :exclude_dirs ],
          :filenames, @req[ :include_names ],
          :freeform_query_infix_words, %w'-not -type d',
          :as_normal_value, IDENTITY_
        ) do | i, *_, & ev_p |
          if :info != i
            error ev_p.call
          end
        end
      end

      def stdout_lines_via_command_args a
        y = []
        x = _synchronously_write_into_via_four y, * _four_via_command_args( a )
        x && y
      end

      def stdout_lines_via_command_string s
        y = []
        x = _synchronously_write_into_via_four y, * _four_via_command_string( s )
        x && y
      end

      def stdout_lines_into_from_command_args y, a
        _synchronously_write_into_via_four y, * _four_via_command_args( a )
      end

      def stdout_line_stream_via_args a
        _asynchronous_stdout_stream_via_four( * _four_via_command_args( a ) )
      end

      def _four_via_command_args a
        FM_::Library_::Open3.popen3( * a )
      end

      def _four_via_command_string s
        FM_::Library_::Open3.popen3 s
      end

      def _asynchronous_stdout_stream_via_four _, o, __, ___

        # a placeholder for the idea of it

        p = -> do
          o.gets
        end

        Callback_.stream do
          p[]
        end
      end

      def _synchronously_write_into_via_four y, _, sout, serr, _

        tsa_limit = ( @tsa_limit ||= 0.33 )  # tsa = time since activity

        er = nil
        select = LIB_.select
        select.timeout_seconds = 5.0  # exaggerated amount for fun

        num_souts = 0
        did_filler_activity = false

        # (this block is all just a UI nicety - 'TSA' - time since activity)
        select.heartbeat tsa_limit do
          if num_souts.zero?
            @ui.err.write '.'
          else
            @ui.err.write( '*' * num_souts )
            num_souts = 0
          end
          did_filler_activity ||= true
        end

        select.on sout do |line|
          num_souts += 1
          line.chomp!
          y << line
        end

        select.on serr do |line|
          line.chomp!
          er ||= true
          @ui.err.puts "(unexpected errput - #{ line }\")"
        end

        select.select

        if did_filler_activity
          @ui.err.write " done.\n"
        end

        ! er
      end

      # <-

    -> do  # `count_lines`

      noop = -> _ { } ; build_prattle_space = nil

      define_method :count_lines do |file_a, label=nil|
        filter_a = []
        if @req.fetch :info_volume
          incl, excl, prattle = build_prattle_space[]  # sorry - fun custom hack
        else
          incl = excl = noop
        end
        if @req[:count_blank_lines] then incl[ :blank_lines ] else
          excl[ :blank_lines ]
          filter_a << "grep -v '^[ \t]*$'"
        end
        if @req[:count_comment_lines] then incl[ :comment_lines ] else
          excl[ :comment_lines ]
          filter_a << "grep -v '^[ \t]*#'"
        end
        if prattle
          cp = prattle.conjunction_phrase
          @ui.err.puts "(#{ cp.string })"
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

      # (this is not worth the space, but it's so goddamned fun!)
      # with axes/categories of { including | exluding } x { A | B },
      # produce programatically all the permutations of utterances:
      # "including A and B", "including A and excluding B", "excluding A and B"
      # and at least 1 other..
      # this is either (#todo use [#cb-050]) or ( :+[#cb-056] )

      build_prattle_space = -> do
        noun_h = { blank_lines: 'blank line', comment_lines: 'comment line' }
        verb_h = { include: 'include', exclude: 'exclude' }
        interface = LIB_.proxy_lib.nice :conjunction_phrase
        -> do
          predicate_box = Callback_::Box.new
          predicate_box_ = predicate_box.algorithms

          aggregate = -> verb_sym, noun_sym do

            predicate_box_.if_has_name verb_sym, -> vp do
              vp << noun_h.fetch( noun_sym )
              nil
            end, -> box, k do
              x = EN_verb_phrase[
                v: verb_h.fetch( k ),
                np: noun_h.fetch( noun_sym ) ]
              x.np.n.number = :plural  # just greasing the wheels
              x.v.markedness = nil
              x.v.tense = :progressive
              box.add k, x
              nil
            end

            nil
          end
          cp = nil
          [  -> sym { aggregate[ :include, sym ] },  # `incl`
             -> sym { aggregate[ :exclude, sym ] },  # `excl`
             interface.new(                          # `prattle`
              conjunction_phrase: -> do
                cp ||= LIB_.EN_conjuction_phrase predicate_box.to_value_stream.to_a
              end )
          ]
        end
      end.call
    end.call

    def linecount_using_grep_chain file_a, filter_a, label

      cmd_tail = "#{ filter_a * ' | ' } | wc -l"

      file_a.reduce( linecount_class.new label ) do |coun, file|

        cmd = "cat #{ shellescape_path file } | #{ cmd_tail }"

        if @req[:show_commands] || @req.fetch( :trace_volume )
          @ui.err.puts cmd
        end
        rs = -> do
          lines = stdout_lines_via_command_string cmd
          lines or break
          lines * EMPTY_S_
        end.call
        rs or break
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

      count = linecount_class.new label
      if file_a.length.zero?
        count
      else
        __linecount_using_wc_of_nonzero_length_file_list count, file_a
      end
    end

    def __linecount_using_wc_of_nonzero_length_file_list count, file_a

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

      cmd = "wc -l #{
        file_a.map( & method( :shellescape_path ) ) * SPACE_
      } | sort -g"

        # we would build this as a tokenized array but for the pipe

      if @req[ :show_commands ] || @req.fetch( :debug_volume )
        @ui.err.puts cmd
      end

      line_a = stdout_lines_via_command_string cmd  # (was [#004])

      if ! line_a || line_a.length.zero?
        raise ::SystemError, 'never'
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

    define_method :shellescape_path, LIB_.shellescape_path
    private :shellescape_path

    def rndr_tbl out, count, design
      if count.zero_children?
        out.puts "(table has no rows)"  # last ditch fallback.
        false
      else
        Library_::Table::Render[ out, count.each_child, [ design,
          -> d do  # grease wheels
            d.the_rest count.first_child.class.members  # did we forget any?
            d.hdr do |sym|  # hack a header from the field id as a default
              sym.to_s.split( '_' ).map(& :capitalize ) * ' '
            end
          end
        ] ]
      end
    end

    # ->
    end
  end
end
