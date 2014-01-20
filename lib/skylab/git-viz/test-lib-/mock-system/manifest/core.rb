module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Manifest

      def initialize y
        @y = y
      end

      def process_strings a
        Respond_.new( @y, a ).respond
      end

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

        def initialize y, s_a
          @s_a = s_a
          super y, Response_.new
        end

        def respond
          ec = prepare
          ec ||= reduce
          @response.set_exit_code ec || SUCCESS_
          @response
        end

      private

        def prepare
          ec, @request = Manifest::Prepare_.new( @y, @s_a, @response ).prepare
          ec
        end

        def reduce
          @cache ||= build_command_IO_cache
          Manifest::Reduce_.new( @y, @cache, @request, @response ).reduce
        end

        def build_command_IO_cache
          Mock_Command_IO_Cache_.new
        end
      end

      class Response_
        def initialize
          @statement_s_a_a = []
        end
        attr_reader :exit_code
        def statement_count
          @statement_s_a_a.length
        end
        def gets_statement_string_a
          @statement_s_a_a.shift
        end
        def set_exit_code ec
          @exit_code = ec ; nil
        end
        def add_iambicly_structured_statement * x_a
          @statement_s_a_a.push x_a ; nil
        end
      end

      GENERAL_ERROR_ = 3 ; PROCEDE_ = nil ; SUCCESS_ = 0
    end
  end
end
