module Skylab::Zerk

  module API

    class ArgumentScannerExpressionAgent

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end  # >>

      alias_method :calculate, :instance_exec

      def say_formal_operation_alternation st
        _say_name_alternation :say_formal_operation_, st
      end

      def say_primary_alternation_ st
        _say_name_alternation :say_primary_, st
      end

      def say_business_branch_item_alternation_ st
        _say_name_alternation :_same, st
      end

      def _say_name_alternation m, st

        p = method m

        st.join_into_with_by "", " or " do |name|
          p[ name ]  # hi.
        end
      end

      def say_formal_operation_ name
        _same name
      end

      def say_formal_component_ name
        _same name
      end

      def say_strange_branch_item x
        x.inspect
      end

      def prim sym
        say_primary_ Common_::Name.via_variegated_symbol sym
      end

      def say_primary_ name
        _same name
      end

      def say_arguments_head_ name
        _same name
      end

      def _ick name
        self._WAHT
      end

      def _same name
        name.as_lowercase_with_underscores_symbol.inspect
      end
    end
  end
end
# #history: abstracted from [tmx]
