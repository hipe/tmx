require 'benchmark'

module Skylab
  # for now we don't whole-hog anything
end

module Skylab::TestSupport
  # even though this is defined elsewhere with more stuff
end

module Skylab::TestSupport::Benchmarking
  class Alternative < ::Struct.new :label, :block
    def initialize param_h
      param_h.each do |k, v|
        self[k] = v
      end
    end
  end
end
