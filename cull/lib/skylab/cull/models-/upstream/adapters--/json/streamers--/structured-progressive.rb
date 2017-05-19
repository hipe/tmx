module Skylab::Cull

  module Models_::Upstream

    class Adapters__::JSON

      class Streamers__::Structured_progressive

        class << self

          def [] fh, & oes_p
            new( fh, & oes_p ).execute
          end
        end

        def execute
          Common_::Stream.define do |o|
            o.upstream_as_resource_releaser_by do
              @fh.close
              ACHIEVED_
            end
            o.stream_by do
              @p[]
            end
          end
        end

        def initialize fh, & oes_p
          @fh = fh
          @p = -> do

            line = fh.gets
            md = OPEN_RX___.match line
            ender_rx = /\A#{ ::Regexp.escape md[ :space ] }\}(?<comma>,)?$/
            @first_open_line = line
            line_cache = []

            Home_.lib_.load_JSON_lib

            @p = -> do
              begin
                line = fh.gets
                line or break  # won't happen in well-structured documents

                if ender_rx =~ line
                  is_last = ! $~[ :comma ]
                  break
                else
                  line_cache.push line
                  redo
                end
              end while nil

              if line_cache.length.zero?
                self._BEHAVIOR_IS_NOT_DEFINED  # do we make an empty entity?
              elsif is_last
                __last_result line_cache
              else
                __pre_last_result line_cache
              end
            end

            @p[]
          end
        end

        OPEN_RX___ = /\A(?<space>[ \t]*)\{$/

        def __pre_last_result line_cache,
          line = @fh.gets
          @first_open_line == line or unexpected line
          result line_cache
        end

        def __last_result line_cache
          line = @fh.gets
          line_ = @fh.gets
          CLOSE__ == line  or unexpected line
          line_.nil? or unexpected line
          @p = EMPTY_P_
          result line_cache
        end

        CLOSE__ = "]\n"

        def result line_cache
          string = "{#{ line_cache.join EMPTY_S_ }}"
          line_cache.clear
          Models_::Entity_.via_structured_hash(
            ::JSON.parse( string, OPTIONS___ ) )
        end

        OPTIONS___ = { symbolize_names: true }.freeze
      end
    end
  end
end
