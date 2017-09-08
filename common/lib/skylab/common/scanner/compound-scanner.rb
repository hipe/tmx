module Skylab::Common

  module Scanner::CompoundScanner

    # because we liked the one we made for `Stream` so much, we made our own

    class << self
      def define
        o = Builder___.new
        yield o
        o.__finish
      end
    end  # >>

    # ==

    class Builder___

      def initialize
        @_scanner_proc_array = []
      end

      def add_scanner st
        @_scanner_proc_array.push -> { st } ; nil
      end

      def add_scanner_by & p  # #covered-by [bs] (thru [pl])
        @_scanner_proc_array.push p
      end

      def __finish
        CustomScanner___.new(
          remove_instance_variable( :@_scanner_proc_array ),
        )
      end
    end

    # ==

    class CustomScanner___

      def initialize st_p_a
        if st_p_a.length.zero?
          @no_unparsed_exists = true
          freeze
        else
          @_stack = st_p_a.reverse
          _st_p = @_stack.pop
          @_scanner = _st_p.call
          _advance
        end
      end

      def gets_one
        x = head_as_is
        advance_one
        x
      end

      def head_as_is  # assume ! no_unparsed_exists
        @_scanner.head_as_is
      end

      def advance_one  # assume ! no_unparsed_exists
        @_scanner.advance_one
        _advance
      end

      def _advance
        while @_scanner.no_unparsed_exists
          st_p = @_stack.pop
          if st_p
            @_scanner = st_p[]
            next
          end
          __close
          break
        end
        NIL
      end

      def __close
        remove_instance_variable :@_scanner
        remove_instance_variable :@_stack
        @no_unparsed_exists = true
        freeze ; nil
      end

      attr_reader(
        :no_unparsed_exists,
      )
    end

    # ==
  end
end
# #history: rewrite of primordial "scanner" to become compound scanner
