module Skylab::TanMan::TestSupport

    EXPRESSION_AGENT = class Expression_Agent__

      alias_method :calculate, :instance_exec


      def pth x
        "«#{ x }»"  # :+#guillemets
      end

      self
    end.new
end
