module Skylab::Git

  module Actors__::Check_SCM

    class << self

      def line_oriented_via_arguments_ * a
        if a.length.zero?
          As_Line_Oriented_Actor__
        else
          st = Callback_::Polymorphic_Stream.via_array x_a
          o = As_Line_Oriented_Actor__.begin
          o.y = st.gets_one
          o.file_a = st.gets_one
          unless st.no_unparsed_exists
            o._process st
          end
          o.execute
        end
      end
    end  # >>

    # ==

    class As_Line_Oriented_Actor___

      class << self

        def [] y, file_a, * x_a
          o = self.begin
          o.file_a = file_a
          o.y = y
          if x_a.length.nonzero?
            o._process Callback_::Polymorphic_Stream.via_array x_a
          end
          o.execute
        end

        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize

        @be_verbose = false
        @error_exit_status = 1
        @system_conduit = nil
        @when_status_p = nil
      end

      def _process st
        @_st = st
        begin
          send st.gets_one
        end until st.no_unparsed_exists
        remove_instance_variable :@_st
        NIL_
      end

    private

      def be_verbose
        @be_verbose = @_st.gets_one ; nil
      end

      def system_conduit
        @system_conduit = @_st.gets_one ; nil
      end

      def when_status
        @when_status_p = @_st.gets_one ; nil
      end

    public

      attr_writer(
        :file_a,
        :y,
      )

      def execute

        @system_conduit ||= Home_.lib_.system

        self._ETC
      end
    end

    # ==

    class Session

      # interfacing with this as a "session" buys us room in the future
      # do to things with caching that might improve performance by
      # significant amounts for some large number of files

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @system_conduit = nil
      end

      attr_writer(
        :system_conduit,
      )

      def finish
        @system_conduit ||= Home_.lib_.system
        self
      end

      # --

      def check path, & oes_p
        Check___.new( path, @system_conduit, & oes_p ).execute
      end
    end

    # ==

    class Check___

      # what this does is run a "git status" (with particular options)
      # against one file and derives meaning from the *one* line of output
      # of that command. of the dozens and dozens of permutations this
      # status can produce, we distill it down to one bit: it's either
      # true or false; true if the file has no unversioned changes, and
      # false otherwise.
      #
      # the bulk of this, then, is dry (as in boring), rule-table-style
      # code derived directly from the "meaning table" at the manpage at
      # `man git-status`, a page that is absolutely required reading
      # as a prerequisite for understanding the code here.
      #
      # annoyingly, the output from the command is identical xx

      def initialize path, sc, & oes_p
        @_oes_p = oes_p
        @path = path
        @system_conduit = sc
      end

      def execute

        __send_and_receive_status

        s = @_serr.gets
        if s
          __when_errput s
        else
          __when_probably_output
        end
      end

      def __when_errput s

        # expect unversioned outside of directory

        if @_oes_p

          s.chomp!
          if %r(\Afatal: Not a git repository \(or any of the parent directories\): \.git$) =~ s
            s = "not in a git repository"
          end

          path = @path

          @_oes_p.call :error, :expression, :error_from_git do |y|

            y << "#{ s } - #{ pth path }"
          end
        end
        UNABLE_
      end

      def __when_probably_output

        s = @_sout.gets
        s_ = @_sout.gets
        s_ and self._UNEXPECTED_LINE
        @_wait.value.exitstatus.zero? or self._COVER_ME_nonzero_exitstatus_from_git

        if s
          __parse_the_one_line_of_output s
          send :"__when__#{ @_index_symbol }__and__#{ @_worktree_symbol }"
        else
          ACHIEVED_
        end
      end

      # -- follow along with the manpage

      def __parse_the_one_line_of_output s

        s.chomp!
        md = RX___.match s

        @_index_symbol = ADJ__.fetch md[ :X ]
        @_worktree_symbol = ADJ__.fetch md[ :Y ]
        @_the_rest = md[ :rest ]
        NIL_
      end

      ADJ__ = {
        ' ' => :unmodified,
        '?' => :untracked,
        '!' => :ignored,
        'A' => :added,
        'C' => :copied,
        'D' => :deleted,
        'M' => :modified,
        'R' => :renamed,
        'U' => :updated_but_unmerged,
      }

      letter = '[ !?ACDMRU]'

      RX___ = /\A(?<X>#{ letter })(?<Y>#{ letter }) (?<rest>.+)\z/m

      # (line 1 is covered by lines 8 & 9)

      # (line 2 is covered by lines 7, 8 & 9)

      # (line 3 is covered by lines 7, 8 & 9)

      def __when__deleted__and__unmodified  # line 4
        _deleted_from_index
      end

      def __when__deleted__and__modified
        _deleted_from_index
      end

      # (line 5 is covered by line 7, 8, & 9)

      # (line 6 is covered by line 7, 8 & 9)

      def __when__modified__and__unmodified  # line 7
        _index_and_work_tree_match
      end

      def __when__added__and__unmodified
        _index_and_work_tree_match
      end

      def __when__renamed__and__unmodified
        _index_and_work_tree_match
      end

      def __when__copied__and__unmodified
        _index_and_work_tree_match
      end

      def __when__unmodified__and__modified  # line 8
        _work_tree_changed_since_index
      end

      def __when__modified__and__modified
        _work_tree_changed_since_index
      end

      def __when__added__and__modified
        _work_tree_changed_since_index
      end

      def __when__renamed__and__modified
        _work_tree_changed_since_index
      end

      def __when__copied__and__modified
        _work_tree_changed_since_index
      end

      def __when__unmodified__and__deleted  # line 9
        _deleted_in_work_tree
      end

      def __when__modified__and__deleted
        _deleted_in_work_tree
      end

      def __when__added__and__deleted
        _deleted_in_work_tree
      end

      def __when__renamed__and__deleted
        _deleted_in_work_tree
      end

      def __when__copied__and__deleted
        _deleted_in_work_tree
      end

      # ~

      def _deleted_from_index
        _meaning 'deleted from index'
      end

      def _index_and_work_tree_match
        _meaning 'index and work tree match'
      end

      def _work_tree_changed_since_index
        _meaning 'file changed since index'
      end

      def _deleted_in_work_tree
        _meaning 'deleted in work tree'
      end

      # --- (that second of three sections)

      def __when__deleted__and__deleted
        _unmerged 'both deleted'
      end

      def __when__added__and__updated
        _unmerged 'added by us'
      end

      def __when__updated__and__deleted
        _unmerged 'deleted by them'
      end

      def __when__updated__and__added
        _unmerged 'added by them'
      end

      def __when__deleted__and__updated
        _unmerged 'deleted by us'
      end

      def __when__added__and__added
        _unmerged 'both added'
      end

      def __when__updated__and__updated
        _unmerged 'both modified'
      end

      # --- (that third of three sections)

      def __when__untracked__and__untracked
        _singular_reason 'file is not under version control'
      end

      def __when__ignored__and__ignored
        _singular_reason 'ignored'
      end

      # --

      def _singular_reason s
        if @_oes_p
          path = @path
          s.chomp!
          @_oes_p.call :error, :expression do |y|
            y << "#{ s } - #{ pth path }"
          end
        end
        UNABLE_
      end

      def _unmerged s  # not covered but meh
        _meaning 'unmerged'
      end

      def _meaning s

        if @_oes_p

          _ = Adjective__[ @_index_symbol ]
          __ = Adjective__[ @_worktree_symbol ]

          path = @path

          @_oes_p.call :error, :expression do |y|
            y << "#{ s } (#{ _ } in index and #{ __ } in tree) - #{ pth path }"
          end
        end

        UNABLE_
      end

      Adjective__ = -> sym do
        sym.id2name.gsub UNDERSCORE_, SPACE_
      end

      # --

      def __send_and_receive_status

        cmd_s_a = GIT_STATUS_HEAD___.dup

        dirname = ::File.dirname @path
        basename = ::File.basename @path

        cmd_s_a.push basename

        if DOT_ != dirname
          cmd_s_a.push( chdir: dirname )
        end

        _i, @_sout, @_serr, @_wait = @system_conduit.popen3( * cmd_s_a )

        NIL_
      end

      GIT_STATUS_HEAD___ = [
        'git', 'status',

        '--ignored',  # because we want them all

        '--untracked-files=all',  # read mangpage - takes more work..

        '-z',  # implies --porcelain; even *more* machine friendly

        '--',  # to separate the pathnames (e.g hypothetically if etc)
      ]
    end
  end
end
# #pending-rename: to "checker" or somesuch, at top level
