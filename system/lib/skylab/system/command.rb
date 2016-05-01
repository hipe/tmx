module Skylab::System

  Sessions_ = ::Module.new

  module Sessions_::Janus_Command

    # a "janus command" is an abstraction that wraps an array of strings
    # intended to be used as a system command (that is, anything that you
    # might enter at the shell) while hiding its particular soultion to
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

    class << self

      def begin
        Open__.__begin
      end
    end  # >>

    class Open__

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
        Closed___.new _tok_a
      end
    end

    class Closed___

      def initialize tok_a  # assume frozen

        @_frozen_tokens = tok_a
        # we don't freeze self because we lazy-memoize
      end

      def open
        Open__.__via @_frozen_tokens
      end

      def command_string
        @_command_s ||= ___assemble_command_string
      end

      def ___assemble_command_string

        Require_shellwords_[]

        @_frozen_tokens.map do |s|
          Shellwords_.shellescape s
        end.join( SPACE_ ).freeze
      end

      def command_tokens
        @_frozen_tokens
      end
    end

    Lazy_ = Callback_::Lazy

    Require_shellwords_ = Lazy_.call do
      # (for all other uses in [sy] it "looks better" not to use this one..)
      Shellwords_ = Home_.lib_.shellwords ; nil
    end
  end
end
