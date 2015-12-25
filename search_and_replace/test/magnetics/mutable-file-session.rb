module Skylab::SearchAndReplace::TestSupport

  module Magnetics::Mutable_File_Session

    def self.[] tcc
      tcc.include self
    end

    # -

      def expect_output_ es, string

        exp_st = Home_.lib_.basic::String.line_stream string
        act_st = es.to_line_stream
        begin
          act = act_st.gets
          if act
            exp = exp_st.gets
            if exp
              if exp == act
                redo
              end
              ___expout_mismatch act, exp, exp_st.lineno
              break
            end
            __expout_extra act, exp_st.lineno
            break
          end
          exp = exp_st.gets
          if exp
            __expout_missing exp, exp_st.lineno
          end
          break
        end while nil
      end

      def ___expout_mismatch act, exp, d

        fail "on line #{ d } expected #{ exp.inspect }, had #{ act.inspect }"
      end

      def __expout_extra act, d

        fail "was not expecting more than #{ d } line(s). (had #{ act.inspect })"
      end

      def __expout_missing exp, d

        fail "had no line #{ d }. (expecting #{ exp.inspect })"
      end

      # --

      def expect_no_matches_
        number_of_match_controllers_.should be_zero
      end

      def expect_one_match_
        number_of_match_controllers_.should eql 1
      end

      def number_of_match_controllers_
        match_controllers_.length
      end

      def match_controllers_
        state_.match_controller_array
      end

      def build_common_state_ s, rx

        es = build_edit_session_ s, rx
        _a = match_controller_array_via_edit_session_ es
        Common_State___.new _a, es
      end

      def match_controller_array_via_edit_session_ es
        # (debugging friendly..)
        a = []
        mc = es.first_match_controller
        if mc
          a.push mc
          begin
            mc = mc.next_match_controller
            mc or break
            a.push mc
            redo
          end while nil
        end
        a
      end

      Common_State___ = ::Struct.new :match_controller_array, :edit_session

      def build_edit_session_ s, rx

        _ = magnetics_::Mutable_File_Session_Stream_via_File_Session_Stream
        _::String_Edit_Session___.new s, rx

      end
    # -
  end
end
