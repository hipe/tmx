module Skylab::Callback

  module Autoloader

    class Const_Reduction__  # read [#029] the const reduce narrative (sparse)

      # (in the rewrite before this one, was:
      # three laws compliant, 100% covered, test is doc)

      def initialize a, & p

        @do_assume_is_defined = false
        @do_result_in_n_and_v = false
        @do_result_in_n_and_v_for_step = false
        @did_require = false
        @else_p = p
        @final_path_to_load = nil
        @try_these_const_method_i_a = ALL_CONST_METHOD_I_A___

        @__a = a
      end

      ALL_CONST_METHOD_I_A___ = %i( as_const as_camelcase_const ).freeze

      def execute

        a = remove_instance_variable :@__a

        if 2 == a.length
          a = [ :const_path, a.fetch( 0 ), :from_module, a.fetch( 1 ) ]
        end

        ___via_nonempty_parse_stream  Polymorphic_Stream.via_array a
      end

      def ___via_nonempty_parse_stream st

        @_st = st
        begin
          _ok = send :"#{ st.gets_one }="
          _ok or self._COVER_ME
          if st.no_unparsed_exists
            break
          end
          redo
        end while nil

        __work
      end

      # --

      def assume_is_defined=  # #assume-is-defined
        @do_assume_is_defined = true ; KEEP_PARSING_
      end

      def core_basename=
        x = @_st.gets_one
        if x
          if CORE_FILE_ == x
            KEEP_PARSING_
          else
            self._IMPLEMENT_ME
          end
        else
          KEEP_PARSING_
        end
      end

      def const_path=
        @const_path = @_st.gets_one ; KEEP_PARSING_
      end

      def final_path_to_load=
        @final_path_to_load = @_st.gets_one ; KEEP_PARSING_
      end

      def from_module=
        @from_module = @_st.gets_one ; KEEP_PARSING_
      end

      def path_x=
        x = @_st.gets_one
        @const_path = ::Array.try_convert( x ) || [ * x ]
        KEEP_PARSING_
      end

      def result_in_name_and_value=
        @do_result_in_n_and_v = true ; KEEP_PARSING_
      end

      # --

      def __work
        @mod = @from_module
        _ok = ___steps
        _ok && __resolve_result
        @result
      end

      def ___steps
        @scn = ___build_any_step_stream
        if @scn
          nil while step
          @step_OK
        else
          KEEP_PARSING_
        end
      end

      def ___build_any_step_stream
        if 1 < @const_path.length
          d = -1 ; last = @const_path.length - 2
          Scn.new do
            d < last and @const_path.fetch( d += 1 )
          end
        end
      end

      def step
        const_x = @scn.gets
        if const_x
          @const_x = const_x
          ___step_via_const_x
        else
          remove_instance_variable :@const_x
          const_x
        end
      end

      def ___step_via_const_x
        ok = _procure_valid_name_from_const_x
        ok &&= __step_with_valid_name
        @step_OK = ok
        ok
      end

      def _procure_valid_name_from_const_x

        x = @const_x
        if x

          nf = if x.respond_to? :ascii_only?
            Name.via_slug x  # hazard a guess
          else
            Name.via_variegated_symbol x
          end

          const = nf.as_const
          @name = nf  # needed for error reporting too
        else
          @name = Name.empty_name_for__ x
        end

        if const
          const
        else
          ___cannot_construe_valid_const
        end
      end

      def ___cannot_construe_valid_const

        if @else_p && @else_p.arity.nonzero?  # covered
          if 1 == @else_p.arity
            @result = @else_p[ bld_wrong_const_name_exception ]
          else
            @result = @else_p.call :error, :wrong_const_name do
              ___build_wrong_const_name_event
            end
          end
        else
          raise bld_wrong_const_name_exception
        end
        UNABLE_
      end

      def ___build_wrong_const_name_event

        Home_::Event.inline_not_OK_with :wrong_const_name,
            :name, @name.as_variegated_symbol,
            :error_category, :name_error do |y, o|

          y << "wrong constant name #{ ick o.name } for const reduce"
        end
      end

      def bld_wrong_const_name_exception
        ::NameError.new say_cannot_construe, @name.as_variegated_symbol
      end

      def say_cannot_construe
        "wrong constant name #{ @name.as_variegated_symbol } for const reduce"
      end

      def __step_with_valid_name
        _procede = _via_valid_name
        if _procede
          @mod = @result ; @result = nil ; KEEP_PARSING_
        else
          UNABLE_
        end
      end

      # ~ final step (intermixed with support for pre-final step)

      def __resolve_result

        @const_x = @const_path.fetch( -1 )  # fail loudly if not there

        path = @final_path_to_load  # hack to support filenames w/o extension
        if path
          ::Kernel.load path
        end

        _ok = _procure_valid_name_from_const_x
        if _ok
          @do_result_in_n_and_v_for_step = @do_result_in_n_and_v
          _via_valid_name
        end
      end

      def _via_valid_name
        if @do_assume_is_defined
          ___when_assume_defined
        else
          __via_any_means
        end
      end

      def ___when_assume_defined  # leverage whatever autoloading
        # the node defines for itself with a fuzzy name that we assume it will
        # resolve; and then after the node has loaded the value, if necessary
        # we go back and resolve the correct casing/scheme for the fuzzy
        # name.
        @result = @mod.const_get @name.as_const, false
        if @do_result_in_n_and_v_for_step
          _via_fuzzy_lookup -> i { @result = [ i, @result, ] }
        end
        KEEP_PARSING_
      end

      def _via_fuzzy_lookup one_p=nil, many_p=nil, zero_p=nil

        a = []
        stem = @name.as_distilled_stem

        @mod.constants.each do | const_sym |
          if stem == Distill_[ const_sym ]
            a.push const_sym
          end
        end

        @result = case a.length <=> 1
        when -1
          if zero_p
            zero_p[]
          else
            _when_const_not_defined
          end
        when 0
          if one_p
            one_p[ a.first ]
          else
            _via_correct_const a.first
          end
        when 1
          if many_p
            many_p[ a ]
          else
            _when_ambiguous a
          end
        end
      end

      def _via_correct_const i
        x = @mod.const_get i, false
        if @did_require
          @did_require = false
          if @mod.respond_to? :autoloaderize_with_normpath_value
            @mod.autoloaderize_with_normpath_value @normpath_that_was_required, x
          end
        end
        if @do_result_in_n_and_v_for_step
          [ i, x ]
        else
          x
        end
      end

      # ~ the "by any means" strategy

      def __via_any_means
        if @mod.const_defined? @name.as_const, false
          @result = _via_correct_const @name.as_const
          KEEP_PARSING_
        else
          ___via_name_search_or_loading
        end
      end

      def ___via_name_search_or_loading
        found = false
        x = _via_fuzzy_lookup(

          -> i do  # when it is one stop now
            found = true
            _via_correct_const i
          end,

          -> a do  # when it is many fail/resolve now
            found = true
            _when_ambiguous a
          end,

          EMPTY_P_ )  # when it is zero do nothing
        if found
          @result = x
          KEEP_PARSING_
        elsif @mod.respond_to? :dir_pathname
          @result = ___via_loading
          KEEP_PARSING_
        else
          _when_const_not_defined
        end
      end

      def ___via_loading

        tree = ___tree
        if tree
          np = tree.normpath_from_distilled @name.as_distilled_stem
        end

        if np
          __via_loading_some_file_in_normpath np
        else
          _when_const_not_defined
        end
      end

      def ___tree
        if @mod.respond_to? :entry_tree
          tree = @mod.entry_tree
        else
          dpn = @mod.dir_pathname
          dpn and tree = LOOKAHEAD_[ dpn ]
        end
        tree
      end

      def __via_loading_some_file_in_normpath np
        file = np.can_produce_load_file_path && np
        if file
          ___via_loading_file_for_normpath file
        else
          _when_const_not_defined
        end
      end

      def ___via_loading_file_for_normpath file_normpath
        file_normpath.change_state_to :loaded
        @did_require = true
        @normpath_that_was_required = file_normpath
        _path = file_normpath.get_require_file_path
        require _path
        _via_fuzzy_lookup
      end

      def _when_ambiguous a
        idx = a.index @name.as_const
        if ! idx
          idx = 0  # MEH
        end
        const = a.fetch idx
        x = @mod.const_get const, false
        if @do_result_in_n_and_v_for_step
          [ const, x ]
        else
          x
        end
      end

      def _when_const_not_defined
        @result = ___result_for_when_const_not_defined
        UNABLE_
      end

      def ___result_for_when_const_not_defined
        if @else_p
          p = @else_p
          case p.arity
          when 0
            p[]
          when 1
            p[ _build_name_error ]
          else
            p.call :error, :uninitialized_constant do
              ___build_name_error_event
            end
          end
        else
          raise _build_name_error
        end
      end

      def ___build_name_error_event
        Home_::Event.inline_not_OK_with(
            :uninitialized_constant, :name, @name.as_variegated_symbol,
              :mod, @mod ) do |y, o|
          y << "uninitialized constant #{ o.mod }::( ~ #{ o.name } )"
        end
      end

      def _build_name_error
        Name_Error__.new @mod, @name.as_variegated_symbol
      end

      class Name_Error__ < ::NameError
        def initialize mod, received_name_i
          @module = mod
          super "uninitialized constant #{ mod }::( ~ #{
            received_name_i } )", received_name_i
        end
        attr_reader :module
        def members
          [ :name, :module ]
        end
      end
    end
  end
end
