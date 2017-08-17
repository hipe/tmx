module Skylab::BeautySalon::TestSupport

  module Crazy_Town

    def self.[] tc
      tc.include self
    end

    # -

      def fails_with_these_normal_lines_ & p

        lines, x = _emission_lines_and_result_CT

        x == false || fail

        expect_these_lines_in_array_ lines, & p
      end

      def JUST_SHOW_ME_THE_LINES
        lines, _ = _emission_lines_and_result_CT
        io = debug_IO
        io.puts lines
        io.puts "GOODBYE FROM JUST_SHOW_ME_THE_LINES"
        exit 0
      end

      def _emission_lines_and_result_CT

        expecting_no_more_emissions = -> * do
          fail
        end

        lines = nil

        p = -> em_p, sym_a do

          lines = _lines_via_thing_CT em_p, sym_a

          p = expecting_no_more_emissions
        end

        _x = subject_magnetic_.call_by do |o|

          o.listener = -> * sym_a, & em_p do
            p[ em_p, sym_a ]
          end

          o.string = remove_instance_variable :@STRING
        end

        [ lines, _x ]
      end

      def expect_success_against_ string

        x = subject_magnetic_.call_by do |o|

          o.listener = -> * sym_a, & em_p do
            lines = _lines_via_thing_CT em_p, sym_a
            fail "unexpected etc startig with #{ lines[0].inspect }"
          end

          o.string = string
        end
        x || fail
        x
      end

      def _lines_via_thing_CT em_p, sym_a

        :error == sym_a.first || fail
        :expression == sym_a[1] || fail
        lines = []
        _p = if do_debug
          io = debug_IO
          -> line { io.puts line ; lines.push line }
        else
          -> line { lines.push line }
        end
        y = ::Enumerator::Yielder.new( & _p )
        _y_ = nil.instance_exec y, & em_p
        y.object_id == _y_.object_id || fail
        lines
      end

    # -
  end
end
# #born: broke out of a spec file
