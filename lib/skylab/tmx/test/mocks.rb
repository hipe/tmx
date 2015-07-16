module Skylab::TMX::TestSupport

  module Mocks

    class Unbound < ::Module

      attr_reader :sym

      def initialize sym
        @sym = sym
      end

      def description_under expag
        me = self
        expag.calculate do
          val me.sym.id2name
        end
      end
    end

    App_Kernels = ::Module.new
  end
end
