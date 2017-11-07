require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - replace', ct: true do

    TS_[ self ]
    use :my_API
    use :my_reports

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

          paths << Fixture_file_[ 'tree-005-minimal' ]

          _this_path = fixture_functions_ 'la-la-015.rb'

          o.argument_paths = paths
          o.code_selector_string = "send(method_name=='expect_nootral_event')"
          o.replacement_function_string = "file:#{ _this_path }"

          o.listener = -> * chan, & _p do
            :find_command_args == chan.last || fail
          end
        end

        _3_lines = [ st.gets, st.gets, st.gets ]
        [ _3_lines, st ]
      end
    end

    # -

    def _call_subject_magnetic_by & p
      call_report_ p, :replace
    end

    # ==

    # ==
    # ==
  end
end
# #born.
