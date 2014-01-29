module Skylab::GitViz

  class Test_Lib_::Mock_System::Fixture_Server

    class Responder__

      def initialize y
        @cache = Test_Lib_::Mock_System::Mock_Command_IO_Cache_.new
        @callbacks = Callbacks__.new
        @y = y
      end

      class Callbacks__ < GitViz::Lib_::Callback_Tree
        def initialize
          super response_started: :handler  # #todo:next-commit this is a listener not a handler
        end
      end

      def on_manifest_added &p
        @cache.on_item_added( & p )
      end

      def on_response_started &p
        @callbacks.set_handler :response_started, p ; nil
      end

      def process_strings a
        Respond__.new( @y, @cache, @callbacks, a ).respond
      end

      def clear_cache_for_manifest_pathname pn
        @cache.clear_cache_for_item_tuple( Fixture_Server::Manifest_, pn,
          method( :when_cleared_cache_for_item_tuple ),
        -> err do
          when_error_for_clear_cache_for_man_pn pn, err
        end )
      end
    private
        # (fix the below indents whenever you get a chance to)
        def when_cleared_cache_for_item_tuple man_han
          @y << "#{ prefix }cleared #{ man_han.manifest_pathname } #{
            }from the cache (#{ man_han.manifest_summary })"
          PROCEDE_
        end
        def when_error_for_clear_cache_for_man_pn pn, err
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

      def prefix
        PREFIX__
      end
      PREFIX__ = '  • '.freeze

      class Respond__ < Response_Agent_

        def initialize y, cache, callbacks, s_a
          @cache = cache ; @callbacks = callbacks; @s_a = s_a
          response = Response__.new
          callbacks.call_handler :response_started, response do end
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
          ec, @request = Fixture_Server::Prepare_.
            new( @y, @s_a, @callbacks, @response ).prepare
          ec
        end

        def reduce
          Fixture_Server::Reduce_.
            new( @y, @cache, @request, @callbacks, @response ).reduce
        end
      end

      class Response__
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
    end
  end
end
