#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Scan_vs_each__

    # an ad-hoc map-reduce operation is implemented variously with a
    # scanner-like implementation and an enumerator-like implementation,
    # and their speeds are compared. we were prepared to accept some reasonable
    # cost to using scanners over enumerators because we like them better;
    # our intention here was to determine that cost.
    #
    # so imagine how pleased we were with ourselves when we found out that
    # when doing the reduce operation here the scanner actually outperformed
    # the enumerator, which is unexpected good news.
    #
    # on one system the enumerator takes about 75% longer than the scanner:
    # using the scanner takes about 57% of the time of the enumerator.
    #
    # but note that if no reduce operation is required, and we are instead
    # simply comprehending over a list, *and* that list exists as an array,
    # perhaps not surprisingly using native to_enum on that array yields
    # about a 2x speedup (again) over using the scanner. this is not reflected
    # below.

    TIMES__ = 1_000_000

    A__ = 1.upto( 5 ).to_a

    BLACK_A__ = [ 2, 4 ]

    Build_Scanner__ = -> a do
      d = -1 ; last = a.length - 1
      Scn__.new do
        while d < last
          BLACK_A__.include?(( x = a[ d += 1 ] )) or break( r = x )
        end
        r
      end
    end
    class Scn__ < ::Proc ; alias_method :gets, :call end

    Build_Enumerator__ = -> a do
      ::Enumerator.new do |y|
        a.each do |x|
          BLACK_A__.include?( x ) or y << x
        end
      end
    end

    number_of_times = nil ; some_action = nil

    invoke = -> benchm do
      benchm.bmbm do |bm|
        bm.report "a custom scanner with the built-in " do
          x = nil
          number_of_times.times do
            scn = Build_Scanner__[ A__ ]
            while (( x = scn.gets ))
              some_action[ x ]
            end
          end
        end
        bm.report "this direct thing" do
          number_of_times.times do
            ea = Build_Enumerator__[ A__ ]
            ea.each do |x|
              some_action[ x ]
            end
          end
        end
      end
    end

    TestSupport_::Benchmark.selftest_argparse[ -> y do
      number_of_times = 1
      some_action = -> x { $stderr.puts "OK - #{ x }" }
      invoke[ TestSupport_::Benchmark::Mock_.new y ]
    end, -> do
      number_of_times = TIMES__
      some_action = -> _ { }
      invoke[ TestSupport_::Benchmark ]
    end ]
  end
end
