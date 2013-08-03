require_relative '../../test-support'

module Skylab::TestSupport::TestSupport::Regret::CLI_Actions_Simplecov

  ::Skylab::TestSupport::TestSupport::Regret[ TS_ = self ]

  add_command_parts_for_system_under_test 'regret', 'simplecov'

  module InstanceMethods
    SUT_TEST_SUPPORT_MODULE_HANDLE_ = TS_
  end

  include CONSTANTS

  extend TestSupport::Quickie

  TestSupport::Services.kick :Open3

  NILADIC_NILNESS_ = -> { }

  describe "#{ TestSupport }::Regret::CLI::Actions::Simplecov" do

    extend TS_

    it "THIS TEST IS AT ONCE SO BEAUTIFUL AND SO UGLY" do
      cmd_a = build_command_a
      line_a, exitstatus = open2 cmd_a
      exitstatus.should eql( 0 )
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
        TestSupport::Stderr_[].puts "LET's FIX SIMPLECOV (that one warning)"
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
      VISUAL_
    end

    VISUAL_ = ::Pathname.new 'visual/regret'

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
            io.close ; p = NILADIC_NILNESS_ ; nil
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
        ::Enumerator::Yielder.new( & TestSupport::Stderr_.method( :puts ) )
      end
    end

    -> do
      fu = nil
      define_method :fu do
        fu ||= TestSupport::Services::FileUtils
      end
    end.call

    let :test_home do
      test_home_pathname.to_s
    end

    def test_home_pathname
      TestSupport::TestSupport.dir_pathname
    end
  end
end
