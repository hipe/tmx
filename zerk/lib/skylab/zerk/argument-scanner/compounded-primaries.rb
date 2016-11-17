module Skylab::Zerk

  module ArgumentScanner

    class CompoundedPrimaries

      # form one parsing syntax by merging multiple operation *instances* SOMEHOW

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      def initialize
        @_box = Common_::Box.new
        @_operations = []
        yield self
        @_box.freeze
        @_operations.freeze
        freeze
      end

      # -- parse-time

      def parse_against argument_scanner

        ok = ACHIEVED_

        matcher = argument_scanner.matcher_for(
          :primary, :against_hash, @_box.h_ )

        op_a = @_operations
        until argument_scanner.no_unparsed_exists

          item = matcher.gets

          if ! item
            ok = item
            break
          end

          if item.is_the_no_op_branch_item
            next
          end

          _d = item.value
          _sym = item.branch_item_normal_symbol
          ok = op_a.fetch( _d ).syntax_front.parse_present_primary _sym
          ok || break
        end
        ok
      end

      # -- define-time

      def add_operation op

        if block_given?
          options = OperationOptions___.new
          yield options
          not_these_mutable_hash = options.not_these_mutable_hash
        end

        sym = nil

        operation_offset = @_operations.length
        @_operations.push op

        see_normally = -> do
          @_box.add sym, operation_offset
        end

        if not_these_mutable_hash
          see = -> do
            had = not_these_mutable_hash.delete sym
            if had
              if not_these_mutable_hash.length.zero?
                see = see_normally
              end
            else
              see_normally[]
            end
          end
        else
          see = see_normally
        end

        _syntax_front = op.syntax_front

        _syntax_front.GET_INTRINSIC_PRIMARY_NORMALS.each do |sym_|
          sym = sym_
          see[]
        end

        if not_these_mutable_hash && not_these_mutable_hash.length.nonzero?
          self._PRIMARIES_were_expressed_that_were_not_present_in_any_operation
        end

        NIL
      end

      # ==

      class OperationOptions___

        def not * sym_a
          h = ( @not_these_mutable_hash ||= {} )
          sym_a.each do |sym|
            h[ sym ] = true
          end ; nil
        end

        attr_reader(
          :not_these_mutable_hash,
        )
      end

      # ==
    end
  end
end
