#!/usr/bin/env ruby -w

require_relative '../test-support'

module Skylab::Slicer::TestSupport

  module Benchmarks::Fourteen_XXX

    TIMES___ = 250_000

    long_path = nil
    number_of_times = nil
    rx = nil

    same_setup = -> do
      long_path = ::File.join Home_.dir_path, 'target-thing', 'other-thing.kd'
      sep = ::Regexp.escape ::File::SEPARATOR
      # rx = %r(  ([^#{ sep }]+)  #{ sep }  [^#{ sep }]+  \z)x   # same factor
      rx = %r(  [^#{ sep }]+ (?=  #{ sep }  [^#{ sep }]+  \z))x
    end

    regex_way = -> * do
      rx.match( long_path )[ 0 ]
    end

    dirname_basename_way = -> * do
      ::File.basename ::File.dirname long_path
    end

    _check_run = -> y do
      same_setup[]
      x = regex_way[]
      x_ = dirname_basename_way[]
      x || fail
      x == x_ || fail
      y << "ok: #{ x } == #{ x_ }"
    end

    _real_run = -> do
      same_setup[]
      number_of_times = TIMES___
      TestSupport_::Benchmark.bmbm do |bm|
        bm.report "the regex way" do
          number_of_times.times( & regex_way )
        end
        bm.report "the dirname basename way" do
          number_of_times.times( & dirname_basename_way )
        end
      end
    end

    TestSupport_::Benchmark.selftest_argparse[ _check_run, _real_run ]
  end
end
