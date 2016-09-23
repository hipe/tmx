module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::CopulaAssertion  # #[#026]

      class << self
        alias_method :via_two_, :new
        undef_method :new
      end  # >>

      def initialize stem, _choices
        @_stem = stem
      end

      def to_line_stream

        @_actual_code_string, @_expected_code_string, @_LTS = @_stem.to_three_pieces

        yes = nil
        yes ||= __looks_like_should_match_string_head
        yes ||= __looks_like_should_raise
        yes || __looks_like_should_equal

        send @_stream_via_looks_like_this
      end

      # #todo - break the above into a mini plugin pattern: put them all in
      #         and array of platform modules and etc

      def __looks_like_should_raise
        __looks_like :__stream_for_should_raise, SHOULD_RAISE_ERROR_MAGIC_PATTERN_RX__
      end

      def __looks_like_should_match_string_head

        lib = Models_::String
        md = lib.match_quoted_string_literal @_expected_code_string
        if md
          s = lib.unescape_quoted_string_literal_matchdata md
          md_ = SIMPLY_THIS__.match s
          if md_
            @__string_head_matchdata = md_
            @_stream_via_looks_like_this = :__stream_for_string_head
            ACHIEVED_
          end
        end
      end

      def __looks_like_should_equal
        @_stream_via_looks_like_this = :__stream_for_should_equal
        NIL_
      end

      def __looks_like m, rx

        md = rx.match @_expected_code_string
        if md
          @_stream_via_looks_like_this = m
          @_md = md
          ACHIEVED_
        else
          UNABLE_
        end
      end

      # --

      def __stream_for_should_raise

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
        s_a.push @_LTS
        y << "begin"
        y << "  #{ @_actual_code_string }"
        y << "rescue #{ const } => e"
        y << "end"
        s_a.push @_LTS
        y << "e.message.should match _rx"

        Common_::Stream.via_nonsparse_array s_a
      end

      def __stream_for_string_head

        _source = ::Regexp.escape @__string_head_matchdata[ :head ]

        _bytes = "%r(\\A#{ _source })"  # yeah?

        _line = "#{ _actual }.should match #{ _bytes }#{ @_LTS }"

        Common_::Stream.via_item _line
      end

      def __stream_for_should_equal

        _ = "#{ _actual }.should eql #{ @_expected_code_string }#{ @_LTS }"

        Common_::Stream.via_item _
      end

      def _actual
        @_stem.add_parens_if_maybe_necessary @_actual_code_string
      end

      def _stream_via_array s_a
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

      SIMPLY_THIS__ = /\A(?<head>.+)\.\.\z/
    end
  end
end
# #history: rename-and-rewrite of "proto predicate"
