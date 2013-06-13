module Skylab::TestSupport

  class Benchmarking::Alternative

    def self.[] *a
      new( *a )
    end

    def initialize label, block
      @label, @proc = label, block
    end

    attr_reader :label, :proc

    def to_a
      [ :@label, :@proc ].map { |ivar| instance_variable_get ivar }
    end

    def execute
      instance_exec( & @proc )
    end
  end
end
