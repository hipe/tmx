require_relative '../../test-support'

module Skylab::TestSupport::TestSupport::Regret::CLI::Actions::Simplecov

  ::Skylab::TestSupport::TestSupport::Regret::CLI::Actions[ TS__ = self ]

  add_command_parts_for_system_under_test 'regret', 'simplecov'

  module InstanceMethods
    SUT_TEST_SUPPORT_MODULE_HANDLE_ = TS__
  end

  include CONSTANTS

  extend TestSupport_::Quickie

  TestSupport_::Library_.touch :Open3

  Lib_ = TestSupport_::Lib_

  NILADIC_EMPTINESS_ = -> { }

  TS_TS = TS_TS

  describe "[ts] regret CLI action s simplecov" do

    extend TS__

    stop_s = '(tmx regret '
    stop_range = 0.. ( stop_s.length - 1 )

    it "SO BEAUTIFUL / SO UGLY : test simplecov in a sub-process" do
      cmd_a = build_command_a
      line_a, exitstatus = open2 cmd_a
      while line = line_a.first and :err == line.out_or_err and
          stop_s != line.line[ stop_range ]
        debug_IO.puts "(skipping errput: #{ line_a.shift.line.chomp! })"
      end
      exitstatus.should be_zero
      handle_last_line line_a.pop
      check_errput line_a
    end

    def handle_last_line any_line
      (( line = any_line )) or fail "expected serveral lines of output, had none"
      line.out_or_err.should eql( :out )
      if ! (( md = terrible_rx.match line.line ))
        line.line.should match( md )  # trigger the test suite failure :/
      else
        md[ :x ].should eql( '13' )
        md[ :y ].should eql( '20' )
        do_cleanup md
      end
    end

    let :terrible_rx do
      /\ACoverage report generated for run-me\.rb #{
        }\(skylab simplecov\) to #{
        }(?<path>#{ ::Regexp.escape expected_out_dir })\.#{
        } (?<x>\d+) \/ (?<y>\d+) LOC \(\d{1,2}\.\d+%\) covered\.\n\z/
    end

    def expected_out_dir
      expected_out_dir_pn.to_s
    end

    let :expected_out_dir_pn do
      test_home_pathname.join 'coverage'
    end

    def do_cleanup md
      md[:path] == (( p = expected_out_dir )) or ::Kernel.fail "sanity"
      tail = p[ - (( lsc = LAST_SANITY_CHECK_ )).length .. -1 ]
      lsc == tail or ::Kernel.fail "sanity"
      fu.remove_entry_secure p
    end
    LAST_SANITY_CHECK_ = '/test-support/test/coverage'.freeze

    def check_errput lines
      lines.length.zero?.should eql( false )
      uniq = lines.map( & :out_or_err ).uniq
      uniq.should eql( [ :err ] )
      lines.shift.line.should match( /about to run:.+run-me\.rb orange/ )
      lines.shift.line.should eql( "welff you probably want orange\n" )
      if lines.length.nonzero?
        Lib_::Stderr[].puts "LET's FIX SIMPLECOV (that one warning)"
      end
    end

    #  ~ running ~

    def build_command_a
      cmd_a = sut_cmd_a
      path = self.path
      cmd_a << path << '--' << path << 'orange'
    end

    let :path do
      visual.join( 'run-me.rb' ).to_s
    end

    def visual
      @visual ||= TS_TS.dir_pathname.join 'visual/regret'
    end

    def open2 cmd_a
      yy = get_any_debugging_yielder
      o = e = w = nil
      fu.cd test_home do
        _, o, e, w = ::Open3.popen3( * build_command_a )
      end
      y = [ ]
      read_o, read_e = [ [ :out, o ], [ :err, e ] ].map do |i, io|
        p = -> do
          if (( s = io.gets ))
            line = Line_[ i, s ]
            yy and yy << line.to_a.inspect
            y << line ; true
          else
            io.close ; p = NILADIC_EMPTINESS_ ; nil
          end
        end
        -> { p[] }
      end
      nil while ( read_e[] || read_o[] )
      exitstatus = w.value.exitstatus
      [ y, exitstatus ]
    end
    Line_ = ::Struct.new :out_or_err, :line

    def get_any_debugging_yielder
      if do_debug
        ::Enumerator::Yielder.new( & Lib_::Stderr[].method( :puts ) )
      end
    end

    -> do
      fu = nil
      define_method :fu do
        fu ||= TestSupport_::Library_::FileUtils
      end
    end.call

    let :test_home do
      test_home_pathname.to_s
    end

    def test_home_pathname
      TestSupport_::TestSupport.dir_pathname
    end
  end
end
