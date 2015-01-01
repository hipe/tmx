module Skylab::Snag

  module API

    EXPRESSION_AGENT = class Expression_Agent___

      alias_method :calculate, :instance_exec

      def ick x
        Snag_.lib_.strange x
      end

      def pth x
        ::Pathname.new( "#{ x }" ).basename.to_path
      end

      Snag_.lib_.NLP_EN_methods self, :private, [ :s ]

      self
    end.new
  end
end
