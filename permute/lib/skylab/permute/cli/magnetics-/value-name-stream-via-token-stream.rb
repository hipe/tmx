module Skylab::Permute

  module CLI

    class Magnetics_::ValueNameStream_via_TokenStream < Common_::Monadic

      def initialize ts, & p
        @token_stream = ts
        @on_event_selectively = p
      end

      def execute

        st = remove_instance_variable :@token_stream
        if ::Array.try_convert st
          # while debugging it's easier to pass arrays around
          st = Common_::Stream.via_nonsparse_array st
        end

        cat_bx = Common_::Box.new

        cat = Category__.new st.gets.value, st.gets.value

        cat_bx.add cat.name_string, cat

        @_bx = cat_bx
        @_col = @_bx.to_collection
        @_st = st

        ok = true
        begin

          pair_for_name = st.gets
          pair_for_name or break

          pair_for_value = st.gets

          _m = THESE___.fetch pair_for_name.name_symbol

          ok = send _m, pair_for_value.value, pair_for_name.value

          ok or break
          redo
        end while nil

        ok && __finish
      end

      THESE___ = {
        long_switch: :__on_long_switch,
        short_switch: :__on_short_switch,
      }

      def __on_short_switch value_s, short_category_s

        _qkn = Common_::QualifiedKnownKnown.via_value_and_symbol(
          short_category_s, :category_letter )

        cat_o = Home_.lib_.brazen::Magnetics::Item_via_OperatorBranch::FYZZY.call_by do |o|

          o.qualified_knownness = _qkn

          o.item_stream_proc = @_col.method :to_entity_stream

          o.string_via_item_by do |item|
            item.name.as_slug
          end

          o.levenshtein_number = -1

          o.listener = @on_event_selectively
        end

        if cat_o
          cat_o.string_array.push value_s
          KEEP_PARSING_
        else
          cat_o
        end
      end

      def __on_long_switch value_s, long_partial_catgory_s

        _qkn = Common_::QualifiedKnownKnown.via_value_and_symbol(
          long_partial_catgory_s, :category_letter )

        cat_o = Home_.lib_.brazen::Magnetics::Item_via_OperatorBranch::FYZZY.call_by do |o|

          o.qualified_knownness = _qkn

          o.item_stream_proc = @_col.method :to_entity_stream

          o.string_via_item_by do |item|
            item.name.as_slug
          end

          o.levenshtein_number = -1

          o.listener = -> * do
            NOTHING_  # hi.
          end
        end

        if cat_o
          cat_o.string_array.push value_s

        else

          cat_o = Category__.new long_partial_catgory_s, value_s
          @_bx.add cat_o.name_string, cat_o
        end
        KEEP_PARSING_
      end

      def __finish

        # (yes we have wrapped the values into categories and now we are
        #  unwrapping them..)

        a = []
        @_bx.each_value do |cat|

          name_sym = cat.name_string.intern  # to produce a struct, need symbols

          cat.string_array.each do |val_s|
            a.push [ val_s, name_sym ]
          end
        end
        a
      end

      class Category__

        def initialize name_s, first_value_s

          @name_string = name_s
          @string_array = [ first_value_s ]
        end

        def name  # for fuzzy lookup
          @___nm ||= Common_::Name.via_slug @name_string
        end

        attr_reader(
          :name_string,
          :string_array,
        )
      end
    end
  end
end

