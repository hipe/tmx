module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    class Strategies___::Downstream_First_Receiver < Argumentative_strategy_class_[]

      SUBSCRIPTIONS = [
        :arity_for,
        :produce_downstream_element
      ]

      PROPERTIES = [
        :argument_arity, :one, :property, :write_lines_to,
      ]

      def initialize( * )
        @_was_provided_by_user = false
        super
      end

      def initialize_dup _

        # do not carry these across the dup boundary:
        #   ( @_result_proc, @_was_provided_by_user, @_yielder_x )

        super
        @_was_provided_by_user = false
      end

      def receive__write_lines_to__argument x

        id_o = Brazen_::Collection::Byte_downstream_identifier_via_mixed[ x ]

        if id_o

          @_was_provided_by_user = true

          @_result_proc = -> do
            # when an output context is provided, result in that
            x
          end

          _accept_BDI id_o
          KEEP_PARSING_
        end
      end

      def produce_downstream_element

        if ! @_was_provided_by_user
          __establish_default_downstream_context
        end

        self
      end

      def __establish_default_downstream_context

        io = Brazen_.lib_.string_IO.new

        _id = Brazen_::Collection::Byte_Downstream_Identifier.via_stream io

        _accept_BDI _id

        @_result_proc = -> do  # when no output context is provided explicitly
          io.string
        end
        NIL_
      end

      def _accept_BDI id_o

        # the "gotcha" at [#ba-046] explains what the newline logic is about

        yld = id_o.to_minimal_yielder  # just throw id_o away

        if :line_list == id_o.shape_symbol  # for now..
          @_yielder_x = yld
        else
          @_yielder_x = ::Enumerator::Yielder.new do | line |
            yld << "#{ line }#{ NEWLINE_ }"
          end
        end

        NIL_
      end

      def << x

        @_yielder_x << x
        self
      end

      def appropriate_result
        @_result_proc[]
      end
    end
  end
end
