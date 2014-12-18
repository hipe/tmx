module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::Manifest_Entry

          def initialize top_path, & oes_p
            @on_event_selectively = oes_p
            @top_path = top_path
          end

          attr_reader :path, :tagging_a, :top_path

          def members
            [ :get_absolute_path, :path, :tagging_a, :top_path ]
          end

          def get_absolute_path
            "#{ @top_path }#{ FILE_SEP_ }#{ @path }"
          end

          def any_new_valid_via_mutable_line line
            if SKIPPABLE_RX__ !~ line
              attempt_any_new_valid_via_mutable_line line
            end
          end
          SKIPPABLE_RX__ = /\A[[:space:]]*(?:\z|#)/

          def attempt_any_new_valid_via_mutable_line line

            md = LINE_AND_POST_LINE_RX__.match line
            path, post_path_content = md.captures
            if post_path_content
              via_both path, post_path_content
            else
              _new path
            end
          end

          LINE_AND_POST_LINE_RX__ = /\A

            [[:space:]]*  (?<path> [^[:space:]]+ )

            (?: [[:space:]]+ (?<post_path_content> .+ )? )?

          \z/mx  # against any nonblank string this regex will never fail

          def via_both path, post_path_content

            post_path_content.chomp!  # hashtag says no

            st = TestSupport_._lib.hashtag.value_peeking_stream post_path_content
            tagging_a = nil

            x = st.gets
            while x

              case x.symbol_i
              when :hashtag
                tagging_a ||= []
                tagging_a.push bld_tagging( x, st )

              when :string

              else
                fail "unexpected: '#{ x.symbol_i }'"
              end

              x = st.gets
            end

            _new path, tagging_a
          end

          def bld_tagging x, st

            _sym = x.get_stem_s.gsub( DASH_, UNDERSCORE_ ).intern

            _val_s = if st.peek_for_value
              st.gets  # skip the colon
              st.gets.to_s
            end

            Tagging__.new _sym, _val_s
          end

          def _new path, tagging_a=nil
            otr = dup
            otr._set path, tagging_a
            otr.freeze
          end

          protected def _set path, tagging_a=nil
            @path = path
            @tagging_a = tagging_a
            nil
          end

          class Tagging__

            def initialize i, x
              @normal_name_symbol = i
              @value_x = x
              freeze
            end

            attr_reader :normal_name_symbol, :value_x

            def members
              [ :normal_name_symbol, :value_x ]
            end
          end
        end
      end
    end
  end
end