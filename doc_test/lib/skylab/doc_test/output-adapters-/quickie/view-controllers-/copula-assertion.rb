module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::CopulaAssertion  # #[#026]

      def initialize common_para, _choices
        @_common = common_para
      end

      def to_line_stream

        @_actual_code_string, @_expected_code_string, @_LTS = @_common.to_three_pieces

        @_md = SHOULD_RAISE_ERROR_MAGIC_PATTERN_RX__.match @_expected_code_string

        if @_md
          self._FUN
        else
          Common_::Stream.via_item ___assemble_line
        end
      end

      def ___assemble_line
        "#{ @_actual_code_string }.should eql #{ @_expected_code_string }#{ @_LTS }"
      end

      def _EG_FUN

        const, fullmsg, msgfrag = @_md.captures

        _rx = if fullmsg
          "\\A#{ ::Regexp.escape fullmsg }\\z".inspect
        else
          "\\A#{ ::Regexp.escape msgfrag }".inspect
        end

        s_a = []
        y = ::Enumerator::Yielder.new do |s|
          s_a.push ( s << @_LTS )
        end

        y << "_rx = ::Regexp.new #{ _rx }"
        y << "-> do"
        y << "  #{ @_actual_code_string }"
        y << "end.should raise_error( #{ const }, _rx )"

        Common_::Stream.via_nonsparse_array s_a
      end

      # ==

      # e.g "NoMethodError: undefined method `wat` ..", i.e
      # the ".." (literally those two characters) is part of the pattern

      cnst = '[A-Z][A-Za-z0-9_]'
      SHOULD_RAISE_ERROR_MAGIC_PATTERN_RX__ = /\A
        [ ]*
        (?<const> #{ cnst }*(?:::#{ cnst }*)* ) [ ]* : [ ]+
        (?:
          (?<fullmsg> .+ [^.] \.? ) |
          (?: (?<msgfrag> .* [^. ] ) [ ]* \.{2,} )
        ) \z
      /x
    end
  end
end
# #history: rename-and-rewrite of "proto predicate"
