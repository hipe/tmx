module Skylab::Brazen

  class CLI_Support::Table::Actor

    Models_ = ::Module.new

    class Models_::Argument_Matrix

      def initialize
        @_x_a_a = []
      end

      # ~ readers

      def accept_by
        @_x_a_a.each do | x_a |
          yield x_a
        end
        NIL_
      end

      # ~ muators

      def begin_row
        a = []
        @_x_a_a.push a
        @_current_row = a
        NIL_
      end

      def accept_argument x, d
        @_current_row[ d ] = x
        NIL_
      end

      def finish_row
        remove_instance_variable :@_current_row
        NIL_
      end
    end
  end
end
