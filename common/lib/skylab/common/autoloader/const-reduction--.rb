module Skylab::Common

  module Autoloader

    class Const_Reduction__  # sed [#029]

      self._WILL_REWRITE

      def ___build_name_error_event

        Home_::Event.inline_not_OK_with(

          :uninitialized_constant,
          :name, @_name.as_variegated_symbol,
          :mod, @_current_module,
          :error_category, :name_error,

        ) do |y, o|

          y << "uninitialized constant #{ o.mod }::( ~ #{ o.name } )"
        end
      end

      def __build_wrong_const_name_event

        Home_::Event.inline_not_OK_with(
          :wrong_const_name,
          :name, @_name.as_variegated_symbol,
          :error_category, :name_error,
        ) do |y, o|
          y << "wrong constant name #{ ick o.name } for const reduce"
        end
      end
    end
  end
end
# #tombstone: full rewrite
# #tombstone: assume_is_defined
