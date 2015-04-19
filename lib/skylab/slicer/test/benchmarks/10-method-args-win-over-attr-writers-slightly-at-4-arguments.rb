#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Benchmark_10

    class The_Tests__

      def initialize
        @use_loud_guy = false
      end

      attr_writer :bm_agent, :number_of_times, :use_loud_guy, :y

      def execute

        @bm_agent.bmbm do | bm |

          bm.report "2 args / attr_writers" do

            o = build

            @number_of_times.times do

              o.one = 1
              o.two = 2

            end
          end

          bm.report "2 args / method arguments" do

            o = build

            @number_of_times.times do

              o.set_two_components 1, 2

            end
          end

          bm.report "3 args / attr_writers" do

            o = build

            @number_of_times.times do

              o.one = 1
              o.two = 2
              o.three = 3

            end
          end

          bm.report "3 args / method arguments" do

            o = build

            @number_of_times.times do

              o.set_three_components 1, 2, 3

            end
          end

          bm.report "4 args / attr_writers" do

            o = build

            @number_of_times.times do

              o.one = 1
              o.two = 2
              o.three = 3
              o.four = 4

            end
          end

          bm.report "4 args / method arguments" do

            o = build

            @number_of_times.times do

              o.set_four_components 1, 2, 3, 4

            end
          end

          bm.report "5 args / attr_writers" do

            o = build

            @number_of_times.times do

              o.one = 1
              o.two = 2
              o.three = 3
              o.four = 4
              o.five = 5

            end
          end

          bm.report "4 args / method arguments" do

            o = build

            @number_of_times.times do

              o.set_five_components 1, 2, 3, 4, 5

            end
          end
        end
      end

      def build
        if @use_loud_guy
          Loud_Guy___.new @y
        else
          Guy__.new
        end
      end
    end

    class Guy__

      attr_writer :one, :two, :three, :four, :five

      def set_two_components a, b
        @one = a
        @two = b
      end

      def set_three_components a, b, c
        @one = a
        @two = b
        @three = c
      end

      def set_four_components a, b, c, d
        @one = a
        @two = b
        @three = c
        @four = d
      end

      def set_five_components a, b, c, d, e
        @one = a
        @two = b
        @three = c
        @four = d
        @five = e
      end
    end

    class Loud_Guy___ < Guy__

      def initialize y
        @y = y
      end

      %i( one two three four five ).each do | sym |
        define_method :"#{ sym }=" do | x |
          @y << "setting #{ sym } to #{ x }"
          super( x )
        end
      end

      %i( two three four five ).each do | sym |
        define_method :"set_#{ sym }_components" do | * a |
          @y << "setting #{ a.length } components: ( #{ a * ', ' } )"
          super( * a )
        end
      end
    end

    TestSupport_::Benchmark.selftest_argparse[ -> y do

      t = The_Tests__.new
      t.number_of_times = 1
      t.bm_agent = TestSupport_::Benchmark::Mock_.new y
      t.y = y
      t.use_loud_guy = true
      t.execute

    end, -> do

      t = The_Tests__.new
      t.number_of_times = 20_000_000
      t.bm_agent = TestSupport_::Benchmark
      t.execute

    end ]
  end
end
