module Skylab::TestSupport::TestSupport

  module Quickie

    module Indicated_Line_Ranges

      def self.[] tcc
        tcc.include self
      end

      # -

        def from_to d, d_
          from d
          to d_
        end

        def from d
          _ILR_enqueue :receive_from, d
        end

        def to d
          _ILR_enqueue :receive_to, d
        end

        def line d
          _ILR_enqueue :receive_line, d
        end

        def _ILR_enqueue m, d
          ( @QUEUED_CALLS ||= [] ).push [ m, d ]
          NIL
        end

        def want_fail tail_sym=:ranges_touch

          spy = Common_.test_support::Want_Emission_Fail_Early::Spy.new

          spy.want :error, :expression, :parse_error, tail_sym do |actual_lines|

            actual_scanner = Common_::Scanner.via_array actual_lines

            _custom_yielder = ::Enumerator::Yielder.new do |expected_line|

              actual_line = actual_scanner.gets_one
              actual_line == expected_line || fail

            end
            yield _custom_yielder

            actual_scanner.no_unparsed_exists || fail
          end

          these = remove_instance_variable :@QUEUED_CALLS

          cls = subject_class_

          spy.call_by do

            subject = cls.new( & spy.listener )

            scn = Common_::Scanner.via_array these

            call = scn.gets_one

            # expect that non-last calls don't fail:
            until scn.no_unparsed_exists

              x = subject.send call.first, * call[1..-1]
              Home_::ACHIEVED_ == x || fail
              call = scn.gets_one
            end

            # expect that the last call does fail:

            x = subject.send call.first, * call[1..-1]
            UNABLE_ == x || fail

            :_no_see_ts_
          end

          spy.execute_under self
        end

        def want_succeed

          _guy = subject_class_.new do |*chan, &msg|
            _ILR_express_emission_to_debug_IO msg, chan
            fail 'unexpected emission per above'
          end
          _ok = _ILR_send_things_to_guy _guy
          _ok || fail
          NIL
        end

        def flush_to_debugging

          _guy = subject_class_.new do |*chan, &msg|
            _ILR_express_emission_to_debug_IO msg, chan
          end
          _ok = _ILR_send_things_to_guy _guy
          if _ok
            debug_IO.puts "(SUCCEEDED)"
          end
          NIL
        end

        def _ILR_send_things_to_guy guy

          ok = true
          these = remove_instance_variable :@QUEUED_CALLS
          these.each do |m, *args|
            ok = guy.send m, * args
            ok || break
          end
          ok
        end

        def _ILR_express_emission_to_debug_IO msg, chan
          io = debug_IO
          io.puts "UNEXPECTED EMISSION: #{ chan.inspect }"
          buffer = ""
          expression_agent.calculate buffer, & msg
          io.puts "(SAID: #{ buffer.inspect })"
          NIL
        end

        def subject_class_
          subject_module_::IndicatedLineRanges___
        end

      # -

      # ==

      module TheseModuleMethods

        # [#009.D] hack caller locations (NOTE needs to move)

        def _hack_next_line_number d
          @WOOHOO = [ LineNo___.new( d ) ]
        end

        def caller_locations d, d_
          1 == d || fail
          1 == d_ || fail
          remove_instance_variable :@WOOHOO
        end
      end

      LineNo___ = ::Struct.new :lineno

      # ==

      # ==
    end
  end
end
# #born
