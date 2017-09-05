require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - main', ct: true do

    TS_[ self ]
    use :my_API

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
           
               this 'perng' do
           
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
          _st = __expanded_stream_via_paths paths
            # (by way of everything else, cover directories here)

          _this_path = ::File.join TS_.dir_path, 'fixture-functions', 'la-la-015.rb'

          o.file_path_upstream = _st
          o.code_selector_string = "send(method_name=='expect_nootral_event')"
          o.replacement_function_string = "file:#{ _this_path }"
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

    def __expanded_stream_via_paths paths

      # this is a bit of a crutch/band-aid over the fact that probably
      # the thing that resolve the file paths upstream is written into
      # the action when it should probably be its own magnet.
      # mainly we wan to cover the map-expand logic there.

      _ir = X_ctr_InvocationResourcesStub.new do |*chan, &em_p|
        if :find_command_args != chan.last
          _DIE_ON_THING em_p, chan
        end
      end

      o = Home_::Models_::CrazyTown.new { _ir }

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

    class X_ctr_InvocationResourcesStub

      def initialize & p
        @argument_scanner = X_ctr_ListenerHaver.new p
      end

      def filesystem  # ..
        ::File
      end

      attr_reader(
        :argument_scanner,
      )
    end

    X_ctr_ListenerHaver = ::Struct.new :listener

    # ==
    # ==
  end
end
# #born.
