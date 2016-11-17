module Skylab::TestSupport

  class Slowie

    class Models_::HashBasedSyntax

      # (this will probably move to [ze])

      def initialize as, h, op
        @argument_scanner = as
        @hash = h
        @operation = op
        @_fetch = :__fetch_idempotently
        yield self if block_given?
      end

      def always_advance_scanner
        @_fetch = :__fetch_by_advancing
      end

      def parse_arguments

        ok = true

        if ! @argument_scanner.no_unparsed_exists

          @__matcher = @argument_scanner.matcher_for(
            :primary, :against_hash, @hash )

          begin
            ok = __parse_primary
            ok || break
          end until @argument_scanner.no_unparsed_exists
        end

        ok
      end

      def __parse_primary

        item = @__matcher.gets

        if item
          send ROUTES___.fetch( item.item_category_symbol ), item.value
        end
      end

      ROUTES___ = {
        item_that_is_primary_hash_value_based: :__parse_primary_normally,
      }

      def parse_present_primary sym
        _user_x = send @_fetch, sym
        @operation.parse_present_primary_for_syntax_front_via_branch_hash_value(
          _user_x )
      end

      def __parse_primary_normally m
        @operation.send m
      end

      def __fetch_by_advancing sym
        @argument_scanner.advance_one
        @hash.fetch sym
      end

      def __fetch_idempotently sym
        # NOTE - here we do NOT advance scanner head because it is assumed
        # that it is done by the operation when the below method is called
        @hash.fetch sym
      end

      def GET_INTRINSIC_PRIMARY_NORMALS  # a = @argument_scanner.added_primary_normal_name_symbols
        @hash.keys
      end

      attr_reader(
        :argument_scanner,
      )
    end
  end
end
# #pending-rename: make public and put in [ze]
# #history: abstracted from two operations
