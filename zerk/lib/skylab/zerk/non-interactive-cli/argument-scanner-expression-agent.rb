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

      def say_primary_alternation_ st

        _mid = st.join_into_with_by "", " | " do |sym|
          prim sym
        end

        "{ #{ _mid } }"
      end

      def simple_inflection & p
        o = dup
        o.extend Home_.lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end

      def ick_oper s
        s.ascii_only?  # type check :/
        s.inspect
      end

      def oper sym
        sym.id2name.gsub UNDERSCORE_, DASH_
      end

      def prim sym
        "#{ DASH_ }#{ sym.id2name.gsub UNDERSCORE_, DASH_ }"
      end

      # ==
      # ==
    end
  end
end
# :#history-B (probably temporary)
# #history: abstracted from [tmx]
