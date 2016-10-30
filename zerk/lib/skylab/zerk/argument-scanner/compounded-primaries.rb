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

        h = @_box.h_
        op_a = @_operations
        until argument_scanner.no_unparsed_exists

          pair = argument_scanner.pair_via_match_head_against_primaries_hash h
          if ! pair
            ok = pair
            break
          end

          _d = pair.value_x
          _sym = pair.name_symbol

          _operation = op_a.fetch _d

          ok = _operation.parse_primary_at_head _sym
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

        st = op.to_primary_normal_name_stream

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

        begin
          sym = st.gets
          sym || break
          see[]
          redo
        end while above
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
