module Skylab::Zerk

  class NonInteractiveCLI

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

      def _say_name_alternation m, st

        p = method m

        _mid = st.join_into_with_by "", " | " do |name|
          p[ name ]  # hi.
        end

        "{ #{ _mid } }"
      end

      def say_formal_operation_ name  # NO DASH
        _same name
      end

      def say_arguments_head_ name
        _same name
      end

      def say_primary_ name
        _add_dash name
      end

      def say_strange_primary_value x
        x.inspect
      end

      def say_formal_component_ name
        _same_inspect name  # usually it reads weirdly without the quotes
      end

      def _add_dash name
        "#{ DASH_ }#{ _same name }"
      end

      def _same_inspect name
        _same( name ).inspect
      end

      def _same name
        name.as_slug
      end
    end
  end
end
# #history: abstracted from [tmx]
