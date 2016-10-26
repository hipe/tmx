module Skylab::Zerk

  module ArgumentScanner

    When = ::Module.new

    module WhenScratchSpace____

      # ==

      When::Argument_value_not_provided = -> argument_scanner do

        self._COVER_ME_just_a_sketch

        sym = argument_scanner.current_primary_symbol

        argument_scanner.listener.call(
          :error, :expression, :parse_error, :primary_value_not_provided
        ) do |y|

          _name = Common_::Name.via_variegated_symbol sym

          y << "#{ say_primary_ _name } must be followed by an argument"

        end
        UNABLE_
      end

      # ==

      When::Unrecognized_primary = -> argument_scanner, ks_p, listener=argument_scanner.listener do

        listener.call(
          :error, :expression, :parse_error, :unrecognized_primary
        ) do |y|

          _name = argument_scanner.head_as_agnostic

          _keys = ks_p[]

          _name_st = Stream_.call _keys do |sym|
            Common_::Name.via_variegated_symbol sym
          end

          y << "unrecognized primary #{ say_strange_primary_ _name }"

          _this_or_this_or_this = say_primary_alternation_ _name_st

          y << "expecting #{ _this_or_this_or_this }"
        end

        UNABLE_
      end

      # ==

      Stream_ = -> a, & p do
        Common_::Stream.via_nonsparse_array a, & p  # on stack to move up
      end
    end
  end
end
# #history: abstracted from the "when" node of the [tmx] map operation
