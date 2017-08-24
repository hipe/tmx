require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - main', ct: true do

    TS_[ self ]
    use :memoizer_methods

    context 'wee' do

      it 'first three lines' do

        _a = _tuple.first

        expect_these_lines_in_array_ _a do |y|
          same_1 = 'a/.+005-xx-yy\.rb'
          same_2 = 'b/.+005-xx-yy\.rb'
          y << %r(\Adiff -U #{ same_1 } #{ same_2 }\z)
          y << %r(\A--- #{ same_1 }\z)
          y << %r(\A\+\+\+ #{ same_2 }\z)
        end
      end

      it 'remaining lines (byte per byte)' do

        _actual_st = _tuple.last

        _exp_s = <<~O
          @@ -11,12 +11,12 @@
           
               this 'ping' do
           
          -      _em = expect_nootral_event :pirng
          +      _em = chamonay(:pirng)
           
                 black_and_white( _em.cached_event_value ).should eql(
                   "hello from beauty salon." )
               end
           
          -    expect_nootral_event :purng
          +    chamonay(:purng)
             end
           end
        O

        exp_st = Home_.lib_.basic::String::LineStream_via_String[ _exp_s ]

        expect_these_lines_in_array_ _actual_st do |y|
          while line=exp_st.gets
            y << line
          end
        end
      end

      shared_subject :_tuple do

        st = _call_subject_magnetic_by do |o|

          paths = []
          paths << ::File.join( TS_.dir_path, 'fixture-files/tree-005-minimal' )
          _st = __INCREDIBLE_HACK paths
            # (by way of everything else, cover directories here)

          o.file_path_upstream = _st
          o.code_selector_string = "send(method_name=='expect_nootral_event')"
          o.replacement_function_string = 'file:test/fixture-functions/la-la-015.rb'
        end

        _3_lines = [ st.gets, st.gets, st.gets ]
        [ _3_lines, st ]
      end
    end

    # -

    -> do
      report_name = "main"
    define_method :_call_subject_magnetic_by do |&p|

      _subject_magnetic.call_by do |o|
        o.report_name = report_name
        o.filesystem = NOTHING_
        o.listener = -> * chan, & em_p do
          _DIE_ON_THING em_p, chan
        end
        p[ o ]
      end
    end
    end.call

    def __INCREDIBLE_HACK paths
      # (we would like to cover this map-expand without going thru the CLI)
      o = Home_::Models_::CrazyTown.allocate
      o.instance_variable_set :@_filesystem, ::File
      o.instance_variable_set :@listener, -> * chan, & em_p do
        if :find_command_args != chan.last
          _DIE_ON_THING em_p, chan
        end
      end
      _ok = o.__resolve_file_path_upstream_via_files paths
      _ok ? o.remove_instance_variable( :@_file_path_upstream ) : false
    end

    def _DIE_ON_THING em_p, chan

      io = $stderr
      io.puts "GONNA DIE: #{ chan.inspect }"
      y = ::Enumerator::Yielder.new do |line|
        io.puts "YERP: #{ line }"
      end
      em_p[ y ]
      exit 0
    end

    def _subject_magnetic
      Home_::CrazyTownMagnetics_::Result_via_ReportName_and_Arguments
    end

    # ==
    # ==
  end
end
# #born.
