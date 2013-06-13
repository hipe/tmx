#!/usr/bin/env ruby -w

require_relative '../core'

module Skylab::Test

  module Benchmarks::Lvar_Bennies

    T_ = 10_000_000

    t_factor = -> num do
      ( T_ * num ).to_i
    end

    class G_
      def initialize times, label, skip=false
        @times, @label, @do_skip = times, label, skip
        yield( @alt_a = [] )
      end
      attr_reader :times, :label, :alt_a, :do_skip
    end

    A_ = Test::Benchmark::Alternative

    obj = ::Object.new

    GROUP_A_ = ga = []
    ga << G_.new( t_factor[ 1 ], 'one business operation' ) do |y|
      y << A_[ 'without lvar', -> do
        obj.class == nil
      end ]
      y << A_[ 'with lvar', -> do
        var = obj.class
        var == nil
      end ]
    end

    ga << G_.new( t_factor[ 1 ], 'two business operations' ) do |y|
      y << A_[ 'without lvar', -> do
        obj.class.nil?
        obj.class.nil?
      end ]
      y << A_[ 'with lvar', -> do
        var = obj.class
        var.nil?
        var.nil?
      end ]
    end

    ga << G_.new( t_factor[ 1 ], 'three business operations' ) do |y|
      y << A_[ 'without lvar', -> do
        obj.class.nil?
        obj.class.nil?
        obj.class.nil?
      end ]
      y << A_[ 'with lvar', -> do
        var = obj.class
        var.nil?
        var.nil?
        var.nil?
      end ]
    end

    class Mock_
      def initialize y
        @y = y
      end
      def bmbm
        yield self
        nil
      end
      def report label
        @y << "mock label: #{ label }"
        yield
      end
    end

    common = -> y, is_real do
      bmrk = is_real ? Test::Benchmark : Mock_.new( y )
      GROUP_A_.each_with_index do |g, idx|
        g.do_skip and next
        y << nil << nil
        y << ( '-' * 58 )
        y << "Group #{ idx + 1 } - #{ g.label }:"
        bmrk.bmbm do |bm|
          g.alt_a.each do |a|
            bm.report a.label do
              g.times.times do
                a.proc.call
              end
            end
          end
        end
      end
    end

    Test::Benchmark.argparse( -> y do
      common[ y, false ]
    end, -> y do
      common[ y, true ]
    end )
  end
end
