module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::CopulaAssertion  # notes in [#042]. #[#026].

      class << self
        alias_method :via_two_, :new
        undef_method :new
      end  # >>

      def initialize stem, _choices
        @_stem = stem
      end

      def to_line_stream & p
        ToLineStream___.new( p, @_stem ).execute
      end

      # ==

      class ToLineStream___

        def initialize p, stem
          @__listener = p
          @_stem = stem
        end

        def execute

          @asset_bytes_for_actual, @asset_bytes_for_expected, @LTS =
            @_stem.to_three_pieces

          o   = LooksLike__::Should_match_string_head[ self, & @__listener ]
          o ||= LooksLike__::Should_raise[ self ]
          o ||= LooksLike__::Should_equal[ self ]
          o.to_line_stream
        end

        def render_actual
          @_stem.add_parens_if_maybe_necessary @asset_bytes_for_actual
        end

        attr_reader(
          :asset_bytes_for_actual,
          :asset_bytes_for_expected,
          :LTS,
        )
      end

      RegexpBased__ = ::Class.new

      LooksLike__ = ::Module.new

      # ==

      class LooksLike__::Should_match_string_head < RegexpBased__

        # explained at #note-1

        class << self

          def call o, & l

            md = Models_::String.match_quoted_string_literal o.asset_bytes_for_expected
            if md
              s = Models_::String.unescape_quoted_string_literal_matchdata md do |*a, &p|
                # no matter what the emission is, downgrade it to an info. we never fail
                # because of whatever happens here, we just keep moving down the chain.
                a[0] = :info
                l[ * a, & p ] ; :_dt_unreliable_
              end
              if s
                md_ = SIMPLY_THIS__.match s
                if md_
                  new md_, o
                end
              else
                # move on to the more literal interpretation, but assume we emitted
                UNABLE_
              end
            end
          end

          alias_method :[], :call
        end  # >>

        def to_line_stream

          _source = ::Regexp.escape @matchdata[ :head ]

          _bytes = "%r(\\A#{ _source })"  # yeah?

          _line = "#{ @client.render_actual }.should match #{ _bytes }#{ @LTS }"

          Common_::Stream.via_item _line
        end
      end

      # ==

      class LooksLike__::Should_raise < RegexpBased__

        # (regex id defined further down)

        def to_line_stream

          const, fullmsg, msgfrag = @matchdata.captures

          _rx = if fullmsg
            "\\A#{ ::Regexp.escape fullmsg }\\z".inspect
          else
            "\\A#{ ::Regexp.escape msgfrag }".inspect
          end

          s_a = []
          y = ::Enumerator::Yielder.new do |s|
            s_a.push ( s << @LTS )
          end

          y << "_rx = ::Regexp.new #{ _rx }"
          s_a.push @LTS
          y << "begin"
          y << "  #{ @client.asset_bytes_for_actual }"
          y << "rescue #{ const } => e"
          y << "end"
          s_a.push @LTS
          y << "e.message.should match _rx"

          Stream_[ s_a ]
        end
      end

      # ==

      class LooksLike__::Should_equal < RegexpBased__

        class << self
          alias_method :call, :new
          alias_method :[], :new
        end  # >>

        def initialize o
          super nil, o
        end

        def to_line_stream
          __ = @client.render_actual
          _ = "#{ __ }.should eql #{ @client.asset_bytes_for_expected }#{ @LTS }"
          Common_::Stream.via_item _
        end
      end

      # ==

      class RegexpBased__

        class << self
          def call o
            md = self::RX.match o.asset_bytes_for_expected
            if md
              new md, o
            end
          end
          alias_method :[], :call
          private :new
        end  # >>

        def initialize md, o
          @client = o  # eew/meh
          @LTS = o.LTS
          @matchdata = md
        end
      end

      # ==

      # e.g "NoMethodError: undefined method `wat` ..", i.e
      # the ".." (literally those two characters) is part of the pattern

      cnst = '[A-Z][A-Za-z0-9_]'
      LooksLike__::Should_raise::RX = /\A
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
