#!/usr/bin/env ruby -w

require_relative '../core'

module Skylab::Test::Struct_Members_Vs_Ivars_Etc_

  TIMES = 7_000_000  # this number has been adjusted down so that we can
  # see results "right away" (and make sure that the benchmark itself still
  # works.). when results with more rigor are needed, please increase this.

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

    def initialize foo
      @foo = foo
    end

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
  end

  Test_ = ::Skylab::Test

  if ::ARGV.length.nonzero?
    Test_::TestSupport.debug_IO.puts "unpexpected argument(s), #{
      }skipping benchmark: #{ ::ARGV * ' ' } (from #{ self })"
  else

  ::Skylab::Test::Benchmark.bmbm do |bm|
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

  end  # indent broken to preserve history :/
end
