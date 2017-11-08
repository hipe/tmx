# frozen_string_literal: true

module Skylab::BeautySalon

  class CrazyTownReportMagnetics_::FilePathUpstream_via_WholeWord <
      Common_::MagneticBySimpleModel

    # an "adapter"-like almost-drop-in replacment magnet intended to help
    # "scale-ify" our approach out to thousands of documents. without this,
    # against a corpus of any moderate size it becomes laggy at best (and
    # unusable at worst) to parse every single file in hundreds or thousands
    # of files just to find a relatively small number of features being
    # searched for.
    #
    # one approach against a large corpus is of course to sub-divide it
    # into smaller trees and do them one at a time. but if you find yourself
    # needing to make lots of little changes corpus-wide against a large
    # corpus, the sub-dividing technique is not practical for everyday use.
    #
    # the subject exposes a different approach: the large input corpus is
    # filtered down to a smaller stream of files using [#sy-042.2] "find
    # piped thru grep". grep is (of course) good at finding particular
    # strings in files. (for our purposes we want to find just the names of
    # the files that contain some string.) then it is this filtered stream
    # that we run our heavy machinery against.
    #
    # the buy-in cost is this: it must be that we can filter down the large
    # set of files to a usefully smaller set of files with a string pattern
    # expressed as a grep pattern.
    #
    # for typical user method names and most userland class/module names,
    # we can typically employ the subject technique usefully.
    #
    #   - fgrep (or `grep -F`) is faster than grep/egrep for plain fixed-
    #     string searches; however this can cast too wide a net (and using
    #     the slower, more powerful variant doesn't "feel" too slow yet.)

    # -

      def initialize
        @_mutex_for_dirs = nil
        @__mutex_for_fixed_string = nil
        @__mutex_for_name_pattern = nil
        super
      end

      def add_dir s
        ( @dirs ||= begin
          remove_instance_variable :@_mutex_for_dirs  # ick/meh
          []
        end ).push s ; nil
      end

      def have_dirs dirs
        remove_instance_variable :@_mutex_for_dirs
        @dirs = dirs ; nil
      end

      def set_whole_word_match_fixed_string s
        remove_instance_variable :@__mutex_for_fixed_string
        @whole_word_match_fixed_string = s ; nil
      end

      def set_name_pattern s
        remove_instance_variable :@__mutex_for_name_pattern
        @name_pattern = s
      end

      attr_writer(
        :piper,
        :spawner,
        :process_waiter,
        :listener,
      )

      def execute
        ok = __resolve_find_command
        ok &&= __resolve_grep_command
        ok && __make_the_magic_happen
      end

      def __make_the_magic_happen

        ::Skylab::System::Grep::EXPERIMENT.call_by do |o|
          o.find_command = remove_instance_variable :@__find_command
          o.grep_command = remove_instance_variable :@__grep_command
          o.piper = remove_instance_variable :@piper
          o.spawner = remove_instance_variable :@spawner
          o.process_waiter = remove_instance_variable :@process_waiter
          o.listener = @listener
        end
      end

      # -- resolve grep command

      def __resolve_grep_command
        if __resolve_sanitized_name_pattern
          __do_resolve_grep_command
        end
      end

      def __do_resolve_grep_command

        _grep = @_lib::Grep.with(
          # ! :fixed_string_pattern  # (we want whole word match so we can't use this one)
          :grep_extended_regexp_string, remove_instance_variable( :@__sanitized_name_pattern ),
          :freeform_options, ['--files-with-matches'],
        ).finish

        _store :@__grep_command, _grep
      end

      def __resolve_sanitized_name_pattern

        # (whitelist version: /\A[[:alnum:]_]+\z/)

        if @whole_word_match_fixed_string.length.zero?
          _express_error( :unsanitary_name_pattern ) { "name pattern cannot be the empty string." }
        else
          bad_char = @whole_word_match_fixed_string[ /[^[:alnum:]_]/ ]
          if bad_char
            _express_error :unsanitary_name_pattern do |y|
              y << "currently, your name pattern must contain only letters, numbers and underscores"
              y << "(bad character: #{ ick_mixed bad_char })"
            end
          else
            _fixed_s = remove_instance_variable :@whole_word_match_fixed_string
            @__sanitized_name_pattern = "\\b#{ _fixed_s }\\b".freeze
            ACHIEVED_
          end
        end
      end

      # -- resolve find command

      def __resolve_find_command

        @_lib = Home_.lib_.system_lib

        _find = @_lib::Find.with(
          :paths, remove_instance_variable( :@dirs ),
          :filename, remove_instance_variable( :@name_pattern ),
        )
        _store :@__find_command, _find
      end

      define_method :_express_error, DEFINITION_FOR_THE_METHOD_CALLED_EXPRESS_ERROR_

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    # ==
    # ==
  end
end
# #history-A.1: xx
# #born.
