# frozen_string_literal: true

module Skylab::System

  module Command

    # this node is a melting pot of a variety of related concerns (whose
    # work spans years):
    #
    #   - a "command" is a frozen array of frozen strings or similar
    #
    #   - a "process" (here) is an abstraction representing a wrapping
    #     of (something like) a input IO handle, output IO handle,
    #     a process ID, ..

    class << self

      def begin
        OpenCommand__.__begin
      end
    end  # >>

    # ==

    class Processer < Common_::SimpleModel

      # NOTE - our name is not a typo. this is a "processER", not a
      # processOR. a "widgeter" is something that makes widgets. a
      # "processER" is something that makes processes. sorry.

      def initialize
        @_is_abstract = false
        @OK_error_code = nil
        @_will_chop = false
        @_will_peek_ahead_by_one = false
        super
      end

      def redefine  # compare self::DEFINITION_FOR_THE_METHOD_CALLED_STORE
        otr = dup
        otr.__be_not_abstract
        yield otr
        otr.freeze
      end

      def freeze
        if ! @_is_abstract
          @__process_prototype = __flush_this_one_lyfe
        end
        super
      end

      def __flush_this_one_lyfe
        GetsyProcess___.define do |o|
          o.OK_error_code = remove_instance_variable :@OK_error_code
          o.process_waiter = remove_instance_variable :@process_waiter
          o.will_chop = remove_instance_variable :@_will_chop
          o.will_peek = remove_instance_variable :@_will_peek_ahead_by_one
          o.listener = @listener
        end
      end

      def USE_REAL_LIFE_RESOURCES
        @spawner = ::Kernel
        @piper = ::IO
        @process_waiter = ::Process ; nil
      end

      def will_chop_all_stdout_lines
        @_will_chop = true
      end

      def will_peek_ahead_by_one
        @_will_peek_ahead_by_one = true
      end

      def be_abstract
        @_is_abstract = true
      end

      def __be_not_abstract
        @_is_abstract = false
      end

      attr_writer(
        :spawner,
        :piper,
        :OK_error_code,
        :process_waiter,
        :listener,
      )

      def procure_nothing_via_dir_and_command_tokens chdir, tox
        pcs = process_via_dir_and_command_tokens chdir, tox
        line = pcs.gets_one_stdout_line
        if line
          cover_me
        elsif pcs.was_OK
          ACHIEVED_
        else
          cover_me
        end
      end

      def process_via_command_tokens tox
        _process_via tox
      end

      def process_via_dir_and_command_tokens chdir, tox
        _process_via tox do |opts|
          opts[ :chdir ] = chdir
        end
      end

      def _process_via tox

        out_read, out_write = @piper.pipe
        err_read, err_write = @piper.pipe

        opts = {
          in: '/dev/null',  # avoid accidentally blocking on our own STDIN
          out: out_write,
          err: err_write,
        }

        yield opts if block_given?

        pid = @spawner.spawn( * tox, opts )

        out_write.close
        err_write.close

        @__process_prototype.__dup_.__init_ out_read, err_read, pid
      end
    end

    # ==

    class GetsyProcess___ < Common_::SimpleModel

      alias_method :__dup_, :dup ; public :__dup_

      def will_chop= yes
        @_gets = if yes
          :__gets_plus_chop
        else
          :_gets_normally
        end ; yes
      end

      attr_writer(
        :OK_error_code,
        :process_waiter,
        :will_peek,
        :listener,
      )

      def __init_ out_read, err_read, pid

        @_out_read = out_read ; @_err_read = err_read ; @__PID = pid
        if remove_instance_variable :@will_peek
          s = send @_gets
          if s
            @__string_on_deck = s
            @__gets_on_deck = @_gets
            @_gets = :__gets_via_payback
            self
          end
        else
          self
        end
      end

      def gets_one_stdout_line
        send @_gets
      end

      def was_OK
        send @_was_OK
      end

      def __gets_via_payback
        @_gets = remove_instance_variable :@__gets_on_deck
        remove_instance_variable :@__string_on_deck
      end

      def __gets_plus_chop
        s = _gets_normally
        if s
          s.chop! ; s
        end
      end

      def _gets_normally
        s = @_out_read.gets
        if s
          s
        else
          _close_out_read
          __check_for_stderr_or_exitstatus
        end
      end

      def __check_for_stderr_or_exitstatus
        s = @_err_read.gets
        if s
          __when_stderr_message s
        else
          _close_err_read
          __check_for_exitstatus
        end
      end

      def __when_stderr_message line
        io = remove_instance_variable :@_err_read
        lines = []
        countdown = 3  # ick/meh - we'd rather close the IO now.
        begin
          line.chop!
          lines.push line
          countdown -= 1
          countdown.zero? && break
          line = io.gets
        end while line
        io.close
        d = _flush_unexpected_exitstatus
        if d
          lines.last << " (exitstatus: #{ d })"
        end
        @listener.call :error, :expression, :system_error do |y|
          lines.each do |s|
            y << s
          end
        end
        @_was_OK = :__false ; nil
      end

      def __check_for_exitstatus
        d = _flush_unexpected_exitstatus
        if d
          self._COVER_ME__nonzero_exitstatus__
        else
          @_gets = :_COVER_ME__nothing__
          @_was_OK = :__true
          remove_instance_variable :@listener
          NOTHING_
        end
      end

      def CLOSE_EARLY  # [sli]
        _close_out_read
        _close_err_read
        _d = _flush_exitstatus
        _d && fail
        NIL
      end

      def _flush_unexpected_exitstatus
        d = _flush_exitstatus
        if d.nonzero?
          if @OK_error_code && @OK_error_code == d
            NOTHING_  # covered in [bs]
          else
            d
          end
        end
      end

      def _flush_exitstatus
        _pid = remove_instance_variable :@__PID
        remove_instance_variable( :@process_waiter ).wait _pid
        $?.exitstatus  # yuck ..
      end

      def _close_err_read
        _close_read :@_err_read
      end

      def _close_out_read
        _close_read :@_out_read
      end

      def _close_read ivar
        _x = remove_instance_variable( ivar ).close
        _x.nil? || sanity
      end

      def __false
        false
      end

      def __true
        true
      end
    end

    # ==

    class ThinlyWrappedProcess < Common_::SimpleModel

      class << self
        def via_five in_, out, err, wait, command
          define do |o|
            o.in = in_
            o.out = out
            o.err = err
            o.wait = wait
            o.command = command
          end
        end
      end  # >>

      def pid= pid
        @wait = ProcessWaiter___.new pid ; pid
      end

      attr_accessor(
        :command,
        :err,
        :in,
        :out,
        :wait,
      )
    end

    # ==

    class ProcessWaiter___  # trying to make our own `::Process::Waiter` because ???

      def initialize pid
        @pid = pid
        @_value = :__value_initially
      end

      def value
        send @_value
      end

      def __value_initially
        ::Process.wait @pid  # result is same pid
        @__value = $?  # EEW - `::Process::Status`
        @_value = :__value_normally
        send @_value
      end

      def __value_normally
        @__value
      end
    end

    # ==

    # a "janus command" is an abstraction that wraps an array of strings
    # intended to be used as a system command (that is, anything that you
    # might enter at the shell) while hiding its particular solution to
    # a general problem:
    #
    # for reasons we prefer to send system commands to the system as an
    # array of tokens rather than as a shell-encoded string - unencoded
    # data is generally easier to work with both when writing and (some)
    # reading. however, if we want to output the string as a debugging
    # command to the user (or possibly for certain other execution
    # scenarios..) it is necessary that the command be as one long escaped
    # string whose tokens have each been escaped by
    # `Shellwords.shellescape` as necessary.
    #
    # the subject node is an abstraction that produces either or both
    # above surface forms from the same underlying data, insulating the
    # user knowing whether the strings are encoded on the way in or on
    # the way out.
    #
    #
    #
    # ## "open" and "closed" state
    #
    # conceptually the command is in one of two states, either "open"
    # or "closed". the open command you can write to but not read and the
    # closed command you can read but not write to.
    #
    # we say "conceptually" because our implementation makes the above
    # itself an abstraction: there is a dedicated class for each state.
    #
    # at present, an open command can be closed only once (rendering the
    # open command as a frozen empty object), but this may be changed.
    #
    # a closed command can be "re-opened" however, which spawns-off a new
    # open structure which has mutable dups of the two arrays.
    #
    #
    #
    # ## the name..
    #
    # ..is originally in reference the greek god "janus" whose two heads
    # suggested the two arrays we originally maintained internally (one
    # escaped and one not).

    # ==

    class OpenCommand__

      class << self

        def __begin
          new._init_by []
        end

        def __via frozen_tokens
          _mutable_a = frozen_tokens.dup
          new._init_by _mutable_a
        end

        private :new
      end  # >>

      def _init_by a
        @_tokens = a
        self
      end

      undef_method :clone
      undef_method :dup

      # -- edit

      # `concat` and `push` are intended to be used for a command that may
      # be [#sl-023] dup-mutated. this being shared, possibly long-running
      # data, we ensure that the strings frozen, POSSIBLY FREEZING THE
      # ARGUMENT STRINGS THEMSELVES (because meh) as necessary. this is
      # to avoid unintentional (or intentional) mutation of the strings
      # after they have been passed in to the "edit session": these strings
      # will be sent into to the system directly, so such a situation could
      # be nasty.

      def push * a
        if 1 == a.length
          _maybe_freeze_and_push_item a.first
        else
          concat a
        end
        self
      end

      def concat s_a
        s_a.each do |s|
          _maybe_freeze_and_push_item s
        end
        self
      end

      def _maybe_freeze_and_push_item s
        if ! s.frozen?
          s.freeze
        end
        push_item s
        NIL_
      end

      def push_item s

        # this method does not take the extra precaution of freezing the
        # string so it should only be used on a command whose execution
        # will occur "immediately"

        @_tokens.push s
        NIL_
      end

      # --

      def close

        _tok_a = remove_instance_variable( :@_tokens ).freeze
        freeze  # sanity - no more writes
        ClosedCommand___.new _tok_a
      end
    end

    # ==

    class ClosedCommand___

      def initialize tok_a  # assume frozen

        tok_a.frozen? || no
        @command_tokens = tok_a
        # we don't freeze self because we lazy-memoize
      end

      def open
        OpenCommand__.__via @command_tokens
      end

      def command_string
        @_command_s ||= ___assemble_command_string
      end

      def ___assemble_command_string

        Require_shellwords_[]

        @command_tokens.map do |s|
          Shellwords_.shellescape s
        end.join( SPACE_ ).freeze
      end

      attr_reader(
        :command_tokens,
      )
    end

    # ==

    Require_shellwords_ = Lazy_.call do
      # (for all other uses in [sy] it "looks better" not to use this one..)
      Shellwords_ = Home_.lib_.shellwords ; nil
    end

    # ==
    # ==
  end
end
# #history-A.1: spike an import of other things
