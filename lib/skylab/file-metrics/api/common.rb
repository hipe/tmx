module Skylab::FileMetrics

  module API::Common
  end

  class API::Common::RuntimeError < ::RuntimeError
  end

  class API::Common::SystemError < ::SystemCallError
  end

  module API::Common::ModuleMethods

    def run *a
      new(* a ).run
    end
  end

  module API::Common::InstanceMethods

  private

    def initialize ui, req
      @ui, @req = ui, req
    end

    def error msg
      @ui.err.puts msg
      false
    end

    def build_find_files_command path_a
      FileMetrics::Library_::Find.valid -> c do
        c.concat_paths path_a
        c.concat_skip_dirs @req[:exclude_dirs]
        c.concat_names @req[:include_names]
        c.extra = '-not -type d'
      end, method( :error )
    end

    # `stdout_lines` - write each (chomped) line of stdout that results from
    # executing `command_string` on the system to `y` using `<<`.
    # any stdout data is written to our own selfsame stream, decorated.
    # result is true if no stderr data was written, false if it was.

    def stdout_lines command_string, y
      tsa_limit = ( @tsa_limit ||= 0.33 )  # tsa = time since activity
      FileMetrics::Library_::Open3.popen3 command_string do |_, sout, serr|
        er = nil
        select = Lib_::Select[]
        select.timeout_seconds = 5.0  # exaggerated amount for fun

        num_souts = 0
        did_filler_activity = false

        -> do
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
        end.call

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
    end

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
        interface = Lib_::Proxy_lib[].nice :conjunction_phrase
        -> do
          predicate_box = Lib_::Open_box[]
          aggregate = -> verb_sym, noun_sym do
            predicate_box.if? verb_sym, -> vp do
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
                cp ||= Lib_::EN_conjuction_phrase[ predicate_box.values ]
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
          stdout_lines cmd, ( lines = [] ) or break
          lines * ''
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
      stdout_lines cmd, ( line_a = [] )  # (was #004)
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

    define_method :shellescape_path, Lib_::Shellescape_path[]
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
  end
end
