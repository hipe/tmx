module Skylab::Snag

  class Models_::To_Do

    module Actors_::Build_the_find_command  # (was [#032] try to unify)

      # assume @filename_pattern_s_a, @path_s_a, @pattern_s_a
      # (but sanity-check their arities anyway)

      def execute

        ok = __sanity_checks
        ok &&= __resolve_pattern_string_for_grep
        ok && __build
      end

      def __sanity_checks

        ok = @filename_pattern_s_a.nil? || @filename_pattern_s_a.length.nonzero?
        ok &&= @path_s_a.length.nonzero?
        ok && @pattern_s_a.length.nonzero?
      end

      def __resolve_pattern_string_for_grep

        @pattern_string_for_grep = @pattern_s_a * PIPE_FOR_GREP___  # :+#security - this is a hole
        ACHIEVED_
      end

      PIPE_FOR_GREP___ = '\|'  # that's two characters

      def __build

        Snag_.lib_.system.filesystem.find.new_with(

          :filenames, @filename_pattern_s_a,

          :paths, @path_s_a,

          :trusted_strings,
            [ @pattern_string_for_grep, '{}', '+' ],

          :freeform_query_postfix_words,
            [ '-exec', 'grep', '--line-number',
              '--with-filename', @pattern_string_for_grep, '{}', '+' ],

          :freeform_query_infix_words,
            COMMON___,

          & @on_event_selectively )
      end

      COMMON___ = %w( -type f ).freeze
    end
  end
end
