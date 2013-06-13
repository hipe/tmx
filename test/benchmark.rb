module Skylab::Test

  module Benchmark

    Alternative = TestSupport::Benchmarking::Alternative

      # import that constant (load that node) early.

    def self.bmbm *a, &b  # and then for no real reason except OCD we
                          # lazy-load the std-lib nerk


      Services::Benchmark.bmbm( *a, &b )
    end
  end

  module Benchmark::Services

    o = { }

    o[ :Benchmark ] = -> { require 'benchmark' ; ::Benchmark }

    define_singleton_method :const_missing do |i|
      const_set i, o.fetch( i ).call
    end
  end

  def Benchmark.argparse test_proc, bench_proc
    argv = ::ARGV
    y = ::Enumerator::Yielder.new( & $stderr.method( :puts ) )
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
