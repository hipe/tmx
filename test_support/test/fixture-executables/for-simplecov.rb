#!/usr/bin/env ruby -w

module Skylab
  class SimpleCov
  end
end

module Skylab::SimpleCov::TestSupport

  module Run_Me

    Y = ::Enumerator::Yielder.new( & STDERR.method( :puts ) )

    def blizzo run_this_color
      if :orange == run_this_color
        Y << "welff you probably want orange"
      elsif :blue == run_this_color
        Y << "what you said is the color blue"
      else
        Y << "not a recognized color - #{ run_this_color }"
        usage
      end
      nil
    end
    module_function :blizzo

    def usage
      Y << "usage: #{ $PROGRAM_NAME } { orange | blue }"
      nil
    end
    module_function :usage

    case ::ARGV.length
    when 0 ; usage
    when 1 ; blizzo ::ARGV[ 0 ].intern
    else   ; Y << "unexpected argument #{ ::ARGV[ 1 ].inspect }"
             usage
    end
  end
end
