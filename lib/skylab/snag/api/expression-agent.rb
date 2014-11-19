module Skylab::Snag

  class API

    EXPRESSION_AGENT = class Expression_Agent___

      alias_method :calculate, :instance_exec

      def ick x
        Snag_._lib.strange x
      end

      def pth x
        ::Pathname.new( "#{ x }" ).basename.to_path
      end

      Snag_._lib.NLP_EN_methods self, :private, [ :s ]

      self
    end.new
  end
end
