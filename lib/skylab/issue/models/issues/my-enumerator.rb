module Skylab::Issue
  class Models::Issues::MyEnumerator < ::Enumerator
    # thanks to brian chandler from issue 707
    def filter &b
      self.class.new do |y|
        each do |*input|
          b.call(y, *input)
        end
      end
    end
  end
end

