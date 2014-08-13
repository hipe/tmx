module Skylab::Snag

  module API

    EXPRESSION_AGENT = class Expression_Agent___

      alias_method :calculate, :instance_exec

      def ick x
        Snag_::Lib_::Strange[ x ]
      end

      self
    end.new
  end
end
