module Skylab
  module Slake
    FakeRequest = Object.new
    FakeParent = Class.new.class_eval do
      attr_reader :ui
      def request
        FakeRequest
      end
      self
    end.new
  end
end