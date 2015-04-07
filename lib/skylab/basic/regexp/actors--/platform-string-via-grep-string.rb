module Skylab::Basic

  module Regexp

    Actors__ = ::Module.new

    class Actors__::Platform_string_via_grep_string  # currently covered..

      # only by [sg]: seems like [bs] should use this too but where?

      # a hack/placeholder for this idea: try to convert a grep pattern
      # string ** for some unspecified set of distributions of grep **
      # to a platform regex string
      #
      # the reason we leave the result as a string and not go ahead and
      # build the platform regex is b.c we may be building a composite
      # regex from a list of grep strings.
      #
      # CAVEAT: this is not yet be cleaned out of all business
      # specifics it gained in its point of origin [sg]. it should
      # be as needed.
      #
      # currently this detect-transforms only these features:
      #
      #   • the grep word boundary feature only when it occurs at
      #     the beginning or end of the pattern string
      #
      #
      # explanation: the grep '\<' and '\>' is not exactly equivalent to
      # ONIGURUMA's '\b' - the former have directional polarity. to
      # achieve them in the latter we use zero-width assertions.

      Callback_::Actor.call self, :properties,
        :pattern_s

      def execute

        scn = Basic_.lib_.string_scanner @pattern_s

        @has_open_boundary = scn.skip BEGINNING_WORD_BOUNDARY__

        @content_start = scn.pos

        @content_width = scn.skip BODY__

        @has_close_boundary = if @content_width
          scn.skip ENDING_WORD_BOUNDARY__
        end

        if scn.eos?
          __flush
        else
          __error scn.rest
        end
      end

      BEGINNING_WORD_BOUNDARY__ = /\\</
      BODY__ = /(?:(?!\\[<>]).)*/
      ENDING_WORD_BOUNDARY__ = /\\>/

      def __error rest_s

        @on_event_selectively.call :error, :expression,
            :unable_to_convert_grep_regex do | y, o |

          y << "unexpected word boundary near #{ ick rest_s }"
        end
        UNABLE_
      end

      def __flush

        _inner_s = @pattern_s[ @content_start, @content_width ]

        _begin_s = if @has_open_boundary
          BEGINNING_WORD_BOUNDARY_RX_S__
        else
          # COMMON_SANITY_BEGINNING_BOUNDARY_RX_S__
          JUST_WHITESPACE_BEGINNING_BOUNDARY_RX_S__
        end

        if @has_close_boundary
          _end_s = ENDING_WORD_BOUNDARY_RX_S__
        end

        "(?<header>#{ _begin_s })(?<content>#{ _inner_s }#{ _end_s })"
      end

      # COMMON_SANITY_BEGINNING_BOUNDARY_RX_S__ = '(?:^|[ ]+)#[ ]+' used to ..

      BEGINNING_WORD_BOUNDARY_RX_S__ = '(?<![a-zA-Z0-9.])'

      ENDING_WORD_BOUNDARY_RX_S__ = '(?![a-zA-Z0-9.])'

      JUST_WHITESPACE_BEGINNING_BOUNDARY_RX_S__ = '(?:^|[ ]+)'
    end
  end
end
