class Skylab::Brazen

  Modelesque::Name = ::Module.new

    # looking for a name *class*? see comments [#005] code node.

  # ->

    class Modelesque::Name::Inflection

      def initialize scanner, cls
        @cls = cls
        @scanner = scanner
      end

      def execute
        :noun == @scanner.current_token or raise ::ArgumentError, __say_only
        @scanner.advance_one
        x = @scanner.current_token
        if :with_lemma == x
          @scanner.advance_one
          x = @scanner.current_token
        end
        x.respond_to? :ascii_only? or raise ::ArgumentError, __say_string
        @scanner.advance_one
        __accept Model___.new x
      end

      def __say_only
        "the only kind of inflection a model may customize is 'noun' #{
          }(had '#{ @scanner.current_token }')"
      end

      def __say_string
        "noun lemma must be a string (had #{ @scanner.current_token.inspect })"
      end

      def __accept _MODEL_INFLECTION_
        @cls.send :define_singleton_method, :custom_branch_inflection do
          _MODEL_INFLECTION_
        end
        KEEP_PARSING_
      end

      Model___ = ::Struct.new :noun_lemma
    end
  # <-
end
