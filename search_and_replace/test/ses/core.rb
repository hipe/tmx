module Skylab::SearchAndReplace::TestSupport

  module SES  # string edit session

    # assumes `mutated_edit_session_`

    def self.[] tcc
      tcc.include InstanceMethods
    end

    module InstanceMethods

      def expect_edit_session_output_ string

        es = mutated_edit_session_

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

      def assemble_ line_sexp_array

        __these::Line_stream_via_line_sexp_array_stream::
          Line_via_line_sexp_array___[ line_sexp_array ]
      end

      def distill_ line_sexp_array

        line_sexp_array.map do | x |
          if :zero_width == x.first
            x[ 1 ]
          else
            x.first
          end
        end
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
        string_edit_session_controllers_.match_controller_array
      end

      def string_edit_session_begin_controllers_

        _s, _rx = common_DSL_string_and_regex

        build_string_edit_session_controllers_ _str, _rx
      end

      def build_string_edit_session_controllers_ s, rx

        es = build_edit_session_via_ s, rx
        _a = match_controller_array_for_ es
        Common_State___.new _a, es
      end

      Common_State___ = ::Struct.new :match_controller_array, :string_edit_session

      def build_edit_session_via_ s, rx
        _string_edit_session.new true, s, nil, nil, nil, rx
      end

      def __these
        _string_edit_session::Magnetics_
      end

      def _string_edit_session
        Home_::StringEditSession_
      end
    end

    # ==

    module Common_DSL

      module ModuleMethods

        def given & p
          common_DSL_when_givens_are_given
          define_method :common_DSL_given_proc do
            p
          end ; nil
        end

        def common_DSL_when_givens_are_given
          NOTHING_
        end
      end

      module InstanceMethods

        # -- writing

        def str s
          @common_DSL_given_string = s ; nil
        end

        def rx rx
          @common_DSL_given_regex = rx ; nil
        end

        # -- reading

        def common_DSL_string_and_regex

          instance_exec( & common_DSL_given_proc )
          a = []
          a.push remove_instance_variable :@common_DSL_given_string
          a.push remove_instance_variable :@common_DSL_given_regex
          a
        end
      end

    end

    # ==

    Build_match_scanner = -> s, rx do

      Asset[]::Match_Scanner___.new s, rx
    end

    Build_line_scanner = -> big_str do

      Asset[]::Line_Scanner_.new big_str
    end

    Asset = -> do
      Home_::StringEditSession_
    end

    # ==
  end
end
