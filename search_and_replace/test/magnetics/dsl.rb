module Skylab::SearchAndReplace::TestSupport

  module Magnetics::DSL

    def self.[] tcc
      Magnetics::Mutable_File_Session[ tcc ]
      tcc.extend Module_Methods___
      tcc.include Instance_Methods___
    end

    Danger_memo__ = TestSupport_::Define_dangerous_memoizer

    module Module_Methods___

      def shared_input_ & p

        Danger_memo__.call self, :_input_tuple do

          @_mag_DSL_SIS = Shared_Input_Struct___.new
          instance_exec( & p )
          remove_instance_variable :@_mag_DSL_SIS
        end ; nil
      end

      def shared_mutated_edit_session_ sym, & p

        _m = SMES_method_for__[ sym ]

        Danger_memo__.call self, _m do

          es = build_edit_session_
          instance_exec es, & p
          es
        end
      end
    end

    Shared_Input_Struct___ = ::Struct.new :s, :rx

    SMES_method_for__ = -> sym do
      :"_shared_mutated_edit_sesssion_called__#{ sym }__"
    end

    module Instance_Methods___

      def input_string s
        @_mag_DSL_SIS[ :s ] = s ; nil
      end

      def regexp rx
        @_mag_DSL_SIS[ :rx ] = rx ; nil
      end

      def the_shared_mutated_edit_session_ sym
        _m = SMES_method_for__[ sym ]
        send _m
      end

      def build_edit_session_

        _s, _rx = _input_tuple.to_a
        build_edit_session_via_ _s, _rx
      end

      def match_controller_at_offset_ es, d

        0 > d and self._NO

        st = match_controller_stream_for_ es
        x = st.gets
        d.times do
          x = st.gets
        end
        x
      end

      def for_ st

        if block_given?
          @_mag_dsl_st = st
          yield
          remove_instance_variable :@_mag_dsl_st
          s = st.gets

        elsif st
          s = st.gets
        end

        if s
          fail __for_say_unexp s
        end
      end

      def _ line_without_newline

        x = @_mag_dsl_st.gets
        if x
          s = assemble_ x
          s_ = s.chomp!
          if s_
            s_.should eql line_without_newline
          else
            fail __for_say_no_newline s
          end
        else
          fail __for_say_miss line_without_newline
        end
      end

      def __for_say_unexp s ; "unexpected line: #{ s.inspect }" ; end
      def __for_say_no_newline s ; "did not have a newline: #{ s.inspect }" ; end
      def __for_say_miss s ; "missing expected line: #{ s.inspect }" ; end

      def one_line_ st
        _ = st.gets
        _2 = st.gets
        _2 and fail
        assemble_ _
      end

      def lines_before_
        tuple_.fetch 0
      end

      def lines_during_
        tuple_.fetch 1
      end

      def lines_after_
        tuple_.fetch 2
      end
    end
  end
end
