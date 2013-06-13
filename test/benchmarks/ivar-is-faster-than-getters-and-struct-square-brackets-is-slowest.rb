#!/usr/bin/env ruby -w

require_relative '../core'

module Skylab::Test
module Benchmarks::Struct_Members_Vs_Ivars_Etc_  # lost indent

  TIMES = 14_000_000

  class SomeStructSubclass < ::Struct.new :foo
    def go_member
      TIMES.times do
        1 + self[:foo]
      end
    end
    def go_reader
      TIMES.times do
        1 + foo
      end
    end
  end

  class SomeRegularClass

    attr_reader :foo

    def go_ivar
      TIMES.times do
        1 + @foo
      end
    end

    def go_reader
      TIMES.times do
        1 + foo
      end
    end

  protected

    def initialize foo
      @foo = foo
    end
  end

  Test::Benchmark.bmbm do |bm|
    struct = SomeStructSubclass.new 3
    obj = SomeRegularClass.new 3
    bm.report "regular class object ivar" do
      obj.go_ivar
    end
    bm.report "regular class object reader" do
      obj.go_reader
    end
    bm.report "struct member (direct access with [])" do
      struct.go_member
    end
    bm.report "struct reader" do
      struct.go_reader
    end
  end
end
end  # lost indent
