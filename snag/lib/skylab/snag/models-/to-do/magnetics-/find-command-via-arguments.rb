module Skylab::Snag

  class Models_::ToDo

    module Magnetics_::FindCommand_via_Arguments  # 1x (was [#032] try to unify)

      # assume @filename_patterns, @paths, @patterns
      # (but sanity-check their arities anyway)

      def execute

        ok = __sanity_checks
        ok &&= __resolve_pattern_string_for_grep
        ok && __build
      end

      def __sanity_checks

        ok = @filename_patterns.nil? || @filename_patterns.length.nonzero?
        ok &&= @paths.length.nonzero?
        ok && @patterns.length.nonzero?
      end

      def __resolve_pattern_string_for_grep

        @pattern_string_for_grep = @patterns * PIPE_FOR_GREP___  # :+#security - this is a hole
        ACHIEVED_
      end

      PIPE_FOR_GREP___ = '\|'  # that's two characters

      def __build

        Home_.lib_.system.find.with(

          :filenames, @filename_patterns,

          :paths, @paths,

          :trusted_strings,
            [ @pattern_string_for_grep, '{}', '+' ],

          :freeform_query_postfix_words,
            [ '-exec', 'grep', '--line-number',
              '--with-filename', @pattern_string_for_grep, '{}', '+' ],

          :freeform_query_infix_words,
            COMMON___,

          & @listener )
      end

      COMMON___ = %w( -type f ).freeze
    end
  end
end
