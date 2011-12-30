module Skylab
  module Dependency
    FakeRequest = Object.new
    FakeParent = Class.new.class_eval do
      attr_reader :ui
      def request
        FakeRequest
      end
      def node_type
        :graph
      end
      def show_info
        true
      end
      self
    end.new
  end
end
