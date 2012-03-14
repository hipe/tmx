module Skylab::Issue
  class Models::Issues::MyEnumerator < ::Enumerator
    # thanks to brian chandler from issue 707
    def each &b
      o = catch(:last_item) do
        super(&b)
        nil
      end
      o and b.call(o)
    end
    def filter &b
      self.class.new do |y|
        each do |*input|
          b.call(y, *input)
        end
      end
    end
    attr_accessor :search
  end
end

