# frozen_string_literal: true

module Skylab::System

  class Grep  # [#017] (presently no content in document)

    # -
      PARAMS___ = Attributes_actor_.call( self,
        do_ignore_case: [ :known_known, :optional ],
        freeform_options: :optional,
        grep_extended_regexp_string: [ :custom_interpreter_method, :optional ],
        fixed_string_pattern: [ :custom_interpreter_method, :optional ],
        ignore_case: [ :flag_of, :do_ignore_case, :optional, ],
        path: [ :singular_of, :paths, :optional, ],
        paths: :optional,
        ruby_regexp: [ :custom_interpreter_method, :optional ],
        system_conduit: :optional,
      )

      class << self

        def against_mutable_ a, & p
          if a.length.nonzero? || block_given?
            o = new( & p )
            o.__init_via_iambic a
            o.execute
          else
            self
          end
        end

        private :new
      end  # >>

      def initialize & p
        @_has_fixed_string_pattern = nil
        @_has_grep_extended_regexp_string = nil
        @_has_ruby_regexp = nil
        @_any_p = p
      end

      def __init_via_iambic x_a
        PARAMS___.init self, x_a
        @system_conduit ||= Home_.lib_.open3
        NIL_
      end

    private

      def ruby_regexp=
        _maybe_accept :__do_accept_ruby_regexp
      end

      def __do_accept_ruby_regexp s
        @ruby_regexp = s
        @_has_ruby_regexp = true ; ACHIEVED_
      end

      def grep_extended_regexp_string=
        _maybe_accept :__do_accept_grep_extended_regexp_string
      end

      def __do_accept_grep_extended_regexp_string s
        @grep_extended_regexp_string = s
        @_has_grep_extended_regexp_string = true ; ACHIEVED_
      end

      def fixed_string_pattern=  # #not-covered (worked once)
        _maybe_accept :__do_accept_fixed_string_pattern
      end

      def __do_accept_fixed_string_pattern s
        @fixed_string_pattern = s
        @_has_fixed_string_pattern = true ; ACHIEVED_
      end

      def _maybe_accept m
        s = gets_one
        if s
          send m, s
        else
          ACHIEVED_
        end
      end

    public

      # -- normalization of state

      def execute
        _ok = ___resolve_regexp
        _ok && freeze
      end
      alias_method :finish, :execute  # #todo

      def ___resolve_regexp

        if @_has_fixed_string_pattern
          @_has_grep_extended_regexp_string && argument_error
          @_has_ruby_regexp && argument_error
          __resolve_regexp_via_fixed_string_pattern

        elsif @_has_grep_extended_regexp_string
          # prefer this over ruby even if one is set?
          __resolve_regexp_via_egrep_string

        elsif @_has_ruby_regexp
          __resolve_regexp_via_ruby_regexp

        else
          argument_error
        end
      end

      def __resolve_regexp_via_ruby_regexp

          opts = Basic_[]::Regexp.options_via_regexp @ruby_regexp
          xtra_i_a = nil
          if opts.is_multiline
            ( xtra_i_a ||= [] ).push :MULTILINE
          end
          if opts.is_extended
            ( xtra_i_a ||= [] ).push :EXTENDED
          end

        if xtra_i_a
          ___when_no_support_for_ruby_regexp_options xtra_i_a.freeze
        else

          if ! @do_ignore_case
            @do_ignore_case = Common_::KnownKnown[ opts.is_ignorecase ]
          end

          @_use_as_pattern = @ruby_regexp.source

          @_E_or_F = E_OPTION__

          ACHIEVED_
        end
      end

      def ___when_no_support_for_ruby_regexp_options i_a

        p = @_any_p
        if p
          p.call :error, :regexp_option_not_supported do

            Common_::Event.inline_not_OK_with(
              :non_convertible_regexp_options,
              :option_symbols, i_a,
              :regexp, @ruby_regexp,
            )
          end
        end
        UNABLE_
      end

      def __resolve_regexp_via_egrep_string

        __default_to_not_ignoring_case

        @_E_or_F = E_OPTION__

        _store :@_use_as_pattern, @grep_extended_regexp_string
      end

      def __resolve_regexp_via_fixed_string_pattern


        if @do_ignore_case
          if @do_ignore_case.value
            self._COVER_ME__cannot_ignore_case_with_fixed_string__
          else
            _do_resolve_etc_fixed
          end
        else
          _do_not_ignore_case
          _do_resolve_etc_fixed
        end
      end

      def _do_resolve_etc_fixed

        @_E_or_F = F_OPTION___

        _store :@_use_as_pattern, @fixed_string_pattern
      end

      def __default_to_not_ignoring_case
        if ! @do_ignore_case
          _do_not_ignore_case
        end
      end

      def _do_not_ignore_case
        @do_ignore_case = Common_::KnownKnown.falseish_instance
      end

      # -- command building & execution

      def to_output_line_content_stream

        cmd = to_command
        if cmd
          line_content_stream_via_command cmd
        else
          cmd
        end
      end

      def to_command_string
        _of_command :command_string
      end

      def to_command_tokens
        _of_command :command_tokens
      end

      def _of_command m
        cmd = to_command
        if cmd
          cmd.send m
        else
          cmd
        end
      end

      def to_command

        cmd = Home_::Command.begin

        cmd.push GREP___, @_E_or_F

        if @do_ignore_case.value
          cmd.push IGNORE_CASE_OPTION__
        end

        a = @freeform_options
        if a
          cmd.concat a
        end

        cmd.push @_use_as_pattern

        a_ = @paths
        if a_
          cmd.concat a_
        end

        cmd.close
      end

      E_OPTION__ = '-E'
      F_OPTION___ = '--fixed-strings'
      GREP___ = 'grep'.freeze
      IGNORE_CASE_OPTION__ = '--ignore-case'.freeze

      def line_content_stream_via_command cmd

        _tokens = cmd.command_tokens ; cmd = nil

        thread = nil
        p = -> do

          _, o, e, thread = @system_conduit.popen3( * _tokens )

          main_p = -> do
            s = o.gets
            if s
              s.chop!
              s
            else
              p = -> { s }
              s
            end
          end

          err_s = e.gets
          if err_s && err_s.length.nonzero?
            o.close
            p = -> { UNABLE_ }
            ___when_system_error err_s
          else
            p = main_p
            p[]
          end
        end

        Common_::Stream.define do |o|
          o.upstream_as_resource_releaser_by do
            if thread && thread.alive?
              thread.exit
            end
            ACHIEVED_
          end
          o.stream_by do
            p[]
          end
        end
      end

      def ___when_system_error err_s

        p = @_any_p
        if p
          p.call :error, :system_call_error do
            Common_::Event.inline_not_OK_with :system_call_error,
              :message, err_s, :error_category, :system_call_error
          end
        end
        UNABLE_
      end

      def _store ivar, x  # DEFINITION_FOR_THE_METHOD_CALLED_STORE_
        if x
          instance_variable_set ivar, x ; ACHIEVED_
        else
          x
        end
      end
    # -

    # ==

    class EXPERIMENT < Common_::MagneticBySimpleModel

      # this is :[041.2]: the pipe-find-to-grep experiment

      # this is a new take on an old algorithm.
      #
      # we began this thinking we could pipe the output of a find command
      # into a grep command. the new innovative game mechanic was that we
      # would manage our own IPC (system pipes) rather than use `open3`.
      #
      # then when attempting this, we re-learned that `grep` doesn't work
      # this way. it can take a stream of *content* from standard input,
      # not filenames. nonetheless it behooves us to manage our own pipes
      # so we have a better understanding of what they are and how they work.
      #
      # why not just send a very large list of files to grep on the input
      # buffer (would-be command line)? there is a size limit to the number
      # of bytes an input buffer can be in a shell. notwithstanding, it's
      # inelegant (if not impossible) to pass thousands of filenames to a
      # shell command. so:
      #
      # given a fixed "page size" N, load a `grep` command up with 1-N paths
      # that were produced by a long-running `find` command process. our
      # result is a stream, each item of whose is each result line from each
      # such grep command. once one grep process exhausts, that process is
      # closed and a next grep command is loaded up with another "page" of
      # paths from the find command. this sequence is repeated until the
      # find command exhausts.
      #
      # these pages of items are in effect concatted together ("flat map")
      # so that it is impossible to tell from the caller's perspective where
      # one page ends and the next starts.
      #
      #   - this is roughly the algorithm behind [sea]. however here we
      #     over-the-top with managing our own pipes rather than rely on
      #     `open3`.
      #
      #   - this is more or less well-covered, but currently the covering
      #     happens all in [bs], its only client.

      def initialize
        @_use_page_size = nil
        super
      end

      def page_size= d
        0 < d || sanity
        @_use_page_size = d - 1 ; d
      end

      attr_writer(
        :find_command,
        :grep_command,
        :spawner,
        :piper,
        :process_waiter,
        :listener,
      )

      def execute

        @_use_page_size or self.page_size = 30

        processer = Home_::Command::Processer.define do |o|
          o.will_chop_all_stdout_lines  # could weirdly be made optional for grep
          o.spawner = remove_instance_variable :@spawner
          o.piper = remove_instance_variable :@piper
          o.process_waiter = remove_instance_variable :@process_waiter
          o.listener = @listener
          o.be_abstract
        end

        find_processer = processer.redefine do |o|
          o.will_peek_ahead_by_one
        end

        @__grep_processer = processer.redefine do |o|
          o.OK_error_code = GREP_ERROR_OK___
        end

        @__grep_command_head =
          remove_instance_variable( :@grep_command ).to_command_tokens

        pcs = find_processer.process_via_command_tokens(
          remove_instance_variable( :@find_command ).to_command_tokens )

        if pcs
          __hand_written_map_expand pcs
        end
      end

      def __hand_written_map_expand pcs

        # == BEGIN
        # necessary on Ubuntu-like but prob not on OS X, #history-B.1
        pcs = __traverse_the_stream_and_sort_the_files(pcs)
        # == END

        p = nil ; ok = nil ; reached_end_successfully = false
        close = -> { p = nil ; NOTHING_ }
        close_with_failure = -> { ok = false ; close[] }
        close_with_success = -> { ok = true ; close[] }
        load_it_up = -> path do
          tox = [ * @__grep_command_head, path ]
          countdown = @_use_page_size
          loop_ok = true
          until countdown.zero?
            path = pcs.gets_one_stdout_line
            if path
              tox.push path
              countdown -= 1
              next
            end
            if pcs.was_OK
              reached_end_successfully = true
            else
              loop_ok = false
            end
            pcs = nil ; break
          end
          if loop_ok
            @__grep_processer.process_via_command_tokens tox
          else
            close_with_failure[]  # fail immedately after emission, despite N
          end
        end
        sub_pcs = nil ; upper = nil
        lower = -> do
          x = sub_pcs.gets_one_stdout_line
          if x
            x
          elsif reached_end_successfully
            close_with_success[]
          elsif sub_pcs.was_OK
            sub_pcs = nil ; ( p = upper )[]  # :#here
          else
            close_with_failure[]
          end
        end
        upper = -> do
          begin

            path = pcs.gets_one_stdout_line

            if ! path  # when you enounter the last upstream path, done.
              ok = pcs.was_OK ; pcs = nil ; close[] ; break
            end

            sub_pcs = load_it_up[ path ]
            if ! sub_pcs  # if this failed, it errored. stop.
              close[] ; break
            end

            x = sub_pcs.gets_one_stdout_line
            if x  # descend into the other state only when you know you should
              p = lower ; break  # otherwise call stack gets huge from calls #here1
            end

            _was_ok = sub_pcs.was_OK ; sub_pcs = nil
            if ! _was_ok  # at exhaustion always check and then immediately
              close_with_failure[] ; break  # propagate failures
            end

            # the *sub*-process produced no results but did not fail

            if reached_end_successfully  # if it was the last page, done.
              close_with_success[] ; break
            end

            redo  # sub-process was OK and there might be another page. try again
          end while above
          x
        end
        p = upper
        FunctionalProcess___.define do |o|
          o.gets_by do
            p[]
          end
          o.was_OK_by do
            case ok
            when true ; true
            when false ; false
            else ; sanity
            end
          end
        end
      end

      def __traverse_the_stream_and_sort_the_files pcs
        lines = []
        sanity = 1000
        count = 0
        begin
          line = pcs.gets_one_stdout_line
          if not line
            reached_end_successfully = pcs.was_OK
            break
          end
          if sanity == count
            raise "reached #{sanity} files. streaming would be better"
          end
          count += 1
          lines.push line
          redo
        end while above
        lines = Home_.services.maybe_sort_filesystem_paths lines  # #history-B.1
        ProcessFacade___.new(lines, reached_end_successfully)
      end
    end

    # ==

    class ProcessFacade___
      # This is just for when we are on Ubuntu-like and the process that
      # produces filesystem names doesn't do it in order so we have to
      # exhaust the stream (process) and sort the files then pretend like
      # we are a process

      def initialize(lines, reached_end_successfully)
        @_the_stream = Common_::Stream.via_nonsparse_array(lines)
        @was_OK = reached_end_successfully
      end

      def gets_one_stdout_line
        return @_the_stream.gets
      end

      attr_reader :was_OK
    end

    # ==

    class FunctionalProcess___ < Common_::SimpleModel

      # (implements public API [#sy-041.3])

      def gets_by & p
        @__gets_by = p ; nil
      end

      def was_OK_by & p
        @__was_OK_by = p ; nil
      end

      def gets_one_stdout_line
        @__gets_by.call
      end

      def was_OK
        @__was_OK_by.call
      end
    end

    # ==

    GREP_ERROR_OK___ = 1  # when grep gives us this exitstatus (but it didn't
    # write anything to stderr), it means nothing was found, which is OK
    # according to us. (some filetrees will have no matches.)

    # ==
    # ==
  end
end
# #history-B.1: target Ubuntu not OS X
# #history-A.2: extract process stuff out to [sy]
# #history-A.1: spike the pipe-find-to-grep experiment
