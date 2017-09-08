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

      def say_primary_alternation_ internable_st

        internable_st.join_into_with_by ::String.new, ' or ' do |o_x|
          prim o_x.intern
        end
      end

      def simple_inflection & p
        o = dup
        o.extend Home_.lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end

      def ick_prim sym
        _say_sym sym
      end

      def prim sym
        _say_sym sym
      end

      def ick_oper x
        if x.respond_to? :id2name
          _say_sym x
        elsif x.respond_to? :ascii_only?
          x.inspect  # as covered
        else
          self._COVER_ME__strange_shape__
        end
      end

      def oper sym
        _say_sym sym
      end

      def _say_sym sym
        ":#{ sym.id2name }"  # type check :/
      end

      # ==
      # ==
    end
  end
end
# :#history-B (probably temporary)
# #history: abstracted from [tmx]
