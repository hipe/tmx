module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Manifest

      def initialize y
        @cache = Mock_Command_IO_Cache_.new
        h = Handlers__.new
        @handlers = h
        @y = y
      end

      class Handlers__ < GitViz::Lib_::Handlers
        def initialize
          super response_started: nil
        end
      end

      def on_manifest_added &p
        @cache.on_item_added( & p )
      end

      def on_response_started &p
        @handlers.set :response_started, p ; nil
      end

      def process_strings a
        Respond_.new( @y, @cache, @handlers, a ).respond
      end

      def clear_cache_for_manifest_pathname pn
        @cache.clear_cache_for_item_tuple Manifest::Handle, pn, -> man_han do
          @y << "#{ prefix }cleared #{ man_han.manifest_pathname } #{
            }from the cache (#{ man_han.manifest_summary })"
          PROCEDE_
        end, -> err do
          x, inside, i = err.to_a
          short = -> cls do
            cls.name.split( '::' )[ -2..-1 ] * '::'
          end
          _msg = if inside
            "there is no cached #{ short[ inside ] } for #{ i } #{ pn }"
          else
            "there is nothing cached of #{ i } #{ short[ x ] }"
          end
          @y << "#{ prefix }(#{ _msg }. nothing to do)"
          GENERAL_ERROR_
        end
      end

      def prefix
        PREFIX__
      end
      PREFIX__ = '  • '.freeze

      class Agent_
        def initialize y, response
          @response = response ; @y = y ; nil
        end
        def bork s
          @response.add_iambicly_structured_statement :error, s
          GENERAL_ERROR_
        end
      end

      class Respond_ < Agent_

        def initialize y, cache, handlers, s_a
          @cache = cache ; @handlers = handlers ; @s_a = s_a
          response = Response_.new
          handlers.call :response_started, response do end
          super y, response
        end

        def respond
          ec = prepare
          ec ||= reduce
          @response.set_result_code ec || SUCCESS_
          @response
        end

      private

        def prepare
          ec, @request = Manifest::Prepare_.
            new( @y, @s_a, @handlers, @response ).prepare
          ec
        end

        def reduce
          Manifest::Reduce_.
            new( @y, @cache, @request, @handlers, @response ).reduce
        end
      end

      class Response_
        def initialize
          @result_code = nil
          @statement_s_a_a = []
        end
        attr_reader :result_code
        def statement_count
          @statement_s_a_a.length
        end
        def gets_statement_string_a
          @statement_s_a_a.shift
        end
        def set_result_code ec
          @result_code = ec ; nil
        end
        def add_iambicly_structured_statement * x_a
          @statement_s_a_a.push x_a ; nil
        end

        def flatten_via_flush
          y = [] ; ec = @result_code and y.push :result_code, ec
          while (( s_a = @statement_s_a_a.shift ))
            y.push :statement, s_a.length
            y.concat s_a
          end
          y.map!( & :to_s )
          y
        end
      end

      GENERAL_ERROR_ = 3
      MANIFEST_PARSE_ERROR_ = 36  # 3 -> m 9 -> p
      PROCEDE_ = nil
      Responder = self  # shh.. our little secret
      SUCCESS_ = 0
    end
  end
end
