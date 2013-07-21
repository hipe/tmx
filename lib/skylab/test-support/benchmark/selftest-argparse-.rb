module Skylab::TestSupport

  Benchmark::Selftest_argparse_ = -> test_proc, bench_proc do # a bit of a #hack

    argv = ::ARGV
    y = ::Enumerator::Yielder.new( & Subsys::Stderr_[].method( :puts ) )
    call = -> f do
      f[ * ( [ y ] if 1 == f.arity ) ]
    end
    if argv.length.nonzero?
      usg = -> do
        y << "usage: #{ $PROGRAM_NAME } [--self-test]"
      end
      if 1 == argv.length
        arg = argv.fetch 0
        if '--self-test' == arg
          call[ test_proc ]
        else
          if ! [ '-h', '--help' ].include? arg
            y << "unrecognized argument(s) - #{ argv * ' ' }"
          end
          usg[]
        end
      else
        usg[]
      end
    else
      call[ bench_proc ]
    end
  end
end
