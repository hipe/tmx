module Skylab::SearchAndReplace::TestSupport

  module SES  # string edit session

    # assumes `mutated_edit_session_`

    def self.[] tcc
      tcc.include InstanceMethods
    end

    module InstanceMethods

      def want_edit_session_output_ string

        es = mutated_edit_session_

        exp_st = Home_.lib_.basic::String::LineStream_via_String[ string ]
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

      def want_no_matches_
        expect( number_of_match_controllers_ ).to be_zero
      end

      def want_one_match_
        expect( number_of_match_controllers_ ).to eql 1
      end

      def number_of_match_controllers_
        match_controllers_.length
      end

      def match_controllers_
        string_edit_session_controllers_.match_controller_array
      end

      def string_edit_session_begin_controllers_

        _s, _rx = common_DSL_string_and_regex

        build_string_edit_session_controllers_ _s, _rx
      end

      def string_edit_session_begin_

        _s, _rx = common_DSL_string_and_regex

        build_edit_session_via_ _s, _rx
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

      def self.[] tcc
        tcc.extend ModuleMethods
        tcc.include SES::InstanceMethods
        tcc.include InstanceMethods
      end

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

        def string_edit_session_controllers_once_  # OCD - see next method
          yes = true
          define_method :string_edit_session_controllers_ do
            if yes
              yes = false
              string_edit_session_begin_controllers_
            else
              fail
            end
          end
        end

        def shared_string_edit_session_controllers_with_no_mutation_

          shared_subject :string_edit_session_controllers_ do

            string_edit_session_begin_controllers_
          end
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
