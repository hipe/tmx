module Skylab::Git

  module Check

    class << self

      def line_oriented_via_arguments__ a
        scn = Scanner_[ a ]
        o = As_Line_Oriented_Actor__.begin
        o.y = scn.gets_one
        o.file_a = scn.gets_one
        unless scn.no_unparsed_exists
          o._process scn
        end
        o.execute
      end
    end  # >>

    # ==

    class As_Line_Oriented_Actor__

      class << self

        def [] y, file_a, * x_a
          o = self.begin
          o.file_a = file_a
          o.y = y
          if x_a.length.nonzero?
            o._process Scanner_[ x_a ]
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

      def initialize( & p )

        @_listener = p  # nil OK
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

      def status_via_path path, & p  # experimental newer inerface for [dt]

        chk = _begin_check p, path
        chk.extend StructureBased__
        chk.execute
      end

      def check path, & p

        chk = _begin_check p, path
        chk.extend EmissionBased___
        chk.execute
      end

      def _begin_check p, path

        _p = p || @_listener  # nil OK
        Check__.new path, @system_conduit, & _p
      end
    end

    # ==

    class Check__

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

      def initialize path, sc, & p
        @_listener = p
        @path = path
        @system_conduit = sc
      end

      def execute

        __send_and_receive_status

        s = @_serr.gets
        if s
          when_errput_ s
        else
          __when_probably_output
        end
      end
    end  # re-opens

    module EmissionBased___

      def when_errput_ s

        # expect unversioned outside of directory

        if @_listener

          s.chomp!
          if %r(\Afatal: Not a git repository \(or any of the parent directories\): \.git$) =~ s
            s = "not in a git repository"
          end

          path = @path

          @_listener.call :error, :expression, :error_from_git do |y|

            y << "#{ s } - #{ pth path }"
          end
        end

        UNABLE_
      end
    end  # re-opens

    module StructureBased__

      def when_errput_ _s
        Not_versioned__[]  # meh
      end
    end

    class Check__  # #re-open

      def __when_probably_output

        s = @_sout.gets
        s_ = @_sout.gets
        s_ and self._UNEXPECTED_LINE
        @_wait.value.exitstatus.zero? or self._COVER_ME_nonzero_exitstatus_from_git

        if s
          __parse_the_one_line_of_output s
          send :"when__#{ @index_symbol }__and__#{ @worktree_symbol }"
        else
          when_no_status_line_
        end
      end

      # -- follow along with the manpage

      def __parse_the_one_line_of_output s

        s.chomp!
        md = RX___.match s

        @index_symbol = ADJ__.fetch md[ :X ]
        @worktree_symbol = ADJ__.fetch md[ :Y ]
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

      def when__deleted__and__unmodified  # line 4
        _deleted_from_index
      end

      def when__deleted__and__modified
        _deleted_from_index
      end

      # (line 5 is covered by line 7, 8, & 9)

      # (line 6 is covered by line 7, 8 & 9)

      def when__modified__and__unmodified  # line 7
        _index_and_work_tree_match
      end

      def when__added__and__unmodified
        _index_and_work_tree_match
      end

      def when__renamed__and__unmodified
        _index_and_work_tree_match
      end

      def when__copied__and__unmodified
        _index_and_work_tree_match
      end

      def when__unmodified__and__modified  # line 8
        _work_tree_changed_since_index
      end

      def when__modified__and__modified
        _work_tree_changed_since_index
      end

      def when__added__and__modified
        _work_tree_changed_since_index
      end

      def when__renamed__and__modified
        _work_tree_changed_since_index
      end

      def when__copied__and__modified
        _work_tree_changed_since_index
      end

      def when__unmodified__and__deleted  # line 9
        _deleted_in_work_tree
      end

      def when__modified__and__deleted
        _deleted_in_work_tree
      end

      def when__added__and__deleted
        _deleted_in_work_tree
      end

      def when__renamed__and__deleted
        _deleted_in_work_tree
      end

      def when__copied__and__deleted
        _deleted_in_work_tree
      end

      # ~

      def _deleted_from_index
        when_asymmetric_idiom_ :deleted_from_index
      end

      def _index_and_work_tree_match
        when_asymmetric_idiom_ :index_and_work_tree_match
      end

      def _work_tree_changed_since_index
        when_asymmetric_idiom_ :file_changed_since_index
      end

      def _deleted_in_work_tree
        when_asymmetric_idiom_ :deleted_in_work_tree
      end

      # --- (that second of three sections)

      def when__deleted__and__deleted
        _unmerged :both_deleted
      end

      def when__added__and__updated
        _unmerged :added_by_us
      end

      def when__updated__and__deleted
        _unmerged :deleted_by_them
      end

      def when__updated__and__added
        _unmerged :added_by_them
      end

      def when__deleted__and__updated
        _unmerged :deleted_by_us
      end

      def when__added__and__added
        _unmerged :both_added
      end

      def when__updated__and__updated
        _unmerged :both_modified
      end

      def _unmerged s  # not covered but meh
        when_asymmetric_idiom_ :unmerged
      end

      # --- (that third of three sections)

      def when__untracked__and__untracked
        when_symmetric_idiom_ :file_is_not_under_version_control
      end

      def when__ignored__and__ignored
        when_symmetric_idiom_ :ignored
      end
    end  # re-opens

    module StructureBased__  # #re-open

      def when_symmetric_idiom_ _
        Unversioned_changes__[]
      end

      def when_asymmetric_idiom_ _
        Unversioned_changes__[]
      end

      def when_no_status_line_
        No_unversioned_changes___[]
      end
    end

    Not_versioned__ = Lazy_.call do
      class NotVersioned____
        def is_versioned
          false
        end
        new
      end
    end

    Unversioned_changes__ = Lazy_.call do
      class UnversionedChanges____
        def is_versioned
          true
        end
        def has_unversioned_changes
          true
        end
        new
      end
    end

    No_unversioned_changes___ = Lazy_.call do
      class NoUnversionedChanges____
        def is_versioned
          true
        end
        def has_unversioned_changes
          false
        end
        new
      end
    end

    module EmissionBased___  # #re-open

      def when_no_status_line_
        ACHIEVED_
      end

      def when_symmetric_idiom_ sym
        if @_listener
          s = message_via_symbol sym
          path = @path
          s.chomp!
          @_listener.call :error, :expression do |y|
            y << "#{ s } - #{ pth path }"
          end
        end
        UNABLE_
      end

      def when_asymmetric_idiom_ sym

        if @_listener
          s = message_via_symbol sym
          _ = Adjective__[ @index_symbol ]
          __ = Adjective__[ @worktree_symbol ]

          path = @path

          @_listener.call :error, :expression do |y|
            y << "#{ s } (#{ _ } in index and #{ __ } in tree) - #{ pth path }"
          end
        end

        UNABLE_
      end

      Adjective__ = -> sym do
        sym.id2name.gsub UNDERSCORE_, SPACE_
      end
    end

    # ==

    class Check__  # re-open

      def message_via_symbol s
        s.id2name.gsub UNDERSCORE_, SPACE_
      end

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
