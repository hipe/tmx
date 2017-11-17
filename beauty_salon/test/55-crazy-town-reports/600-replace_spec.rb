require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - replace', ct: true do

    TS_[ self ]
    use :my_API
    use :my_reports

    context 'wee' do

      it 'first three lines' do

        _a = _tuple.first

        want_these_lines_in_array_ _a do |y|
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
           
          -      _em = want_nootral_event :pirng
          +      _em = chamonay(:pirng)
           
                 black_and_white( _em.cached_event_value ).should eql(
                   "hello from beauty salon." )
               end
           
          -    want_nootral_event :purng
          +    chamonay(:purng)
             end
           end
        O

        exp_st = Home_.lib_.basic::String::LineStream_via_String[ _exp_s ]

        want_these_lines_in_array_ _actual_st do |y|
          while line=exp_st.gets
            y << line
          end
        end
      end

      shared_subject :_tuple do

        scn = Home_::Scanner_.call(
          # (emissions are not the focus of this test case so we fudge
          #  over them, but strictly so because meh)
          [
            [ :info, :event, :find_command_args, ],
            [ :info, :expression, :processing_next_file ],
          ]
        )

        st = _call_subject_magnetic_by do |o|

          paths = []

          paths << Fixture_file_[ 'tree-005-minimal' ]

          _this_path = fixture_functions_ 'la-la-015.rb'

          o.argument_paths = paths
          o.code_selector_string = "send(method_name=='want_nootral_event')"
          o.replacement_function_string = "file:#{ _this_path }"

          o.listener = -> * chan, & _p do
            _exp = scn.gets_one
            _exp == chan || fail
          end
        end

        _3_lines = [ st.gets, st.gets, st.gets ]
        scn.no_unparsed_exists || fail
        [ _3_lines, st ]
      end
    end

    it 'we need the one more term here' do

      anticipate_ :error, :expression, :argument_error do |y|
        y == ['expecting delimiter ":" at end of macro string'] || fail
      end

      _path = Fixture_tree_for_case_one_[]

      _x = _call_subject_magnetic_by do |o|
        o.argument_paths = [ _path ]
        o.macro_string = 'method:ravi_bhalla'
      end

      _x.nil? || fail
    end

    it 'MONEY MAYBE' do  # #coverpoint4.2

      _path = Fixture_tree_for_case_one_[]

      st = _call_subject_magnetic_by do |o|
        o.argument_paths = [ _path ]
        o.macro_string = 'method:danica_roem:DANICA_ROEM_123'
      end

      __want_these_lines_in_array_CUSTOM st do |o|
        o.call 'diff'
        o.call '---'
        o.call '+++'
        o.call '@@ '
        o.call 3, nil
        o.call '-  '
        o.call '+  '
      end

      count = 0
      count += 1 while st.gets  # exhaust any open resources
      42 == count || fail  # ..
    end

    def __want_these_lines_in_array_CUSTOM st

      yield -> d=1, s do
        if s
          go = -> line  do
            _act = line[ 0, s.length ]
            if s != _act
              fail
            end
          end
        else
          go = -> line do
            if /\A[ ]+/ !~ line
              fail
            end
          end
        end

        d.times do
          line = st.gets
          line || fail
          go[ line ]
        end
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
