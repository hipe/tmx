module Skylab::Callback

  module Autoloader

    class Const_Reduction__  # read [#029] the const reduce narrative
      # also doc is spec, 100% covered, three laws compliant

      Dispatch = -> a, p do
        if a.length.zero?
          if p
            new.process_block p
          else
            Proc_  # curriable form
          end
        else
          Proc_[ * a, &p ]
        end
      end

      def initialize
        @do_assume_is_defined = false
        @do_result_in_n_and_v = false
        @do_result_in_n_and_v_for_step = false
        @did_require = false
        @else_p = nil ; @try_these_const_method_i_a = ALL_CONST_METHOD_I_A__
      end

      ALL_CONST_METHOD_I_A__ = %i( as_const as_camelcase_const ).freeze

      Proc_ = -> const_i_a, mod, & p do
        shell = Shell_.new( kernel = new )
        shell.const_path const_i_a
        shell.from_module mod
        p and shell.else( & p )
        kernel.flush
      end

      def process_block p
        shell = Shell_.new self
        if p.arity.zero?
          shell.instance_exec( & p )
        else
          p[ shell ]
        end
        flush
      end

      class Shell_
        def initialize kernel
          @kernel = kernel
        end
        def assume_is_defined  # #assume-is-defined
          do_assume_is_defined true
        end
        def do_assume_is_defined x
          @kernel.do_assume_is_defined = x ; nil
        end
        def path_x x
          const_path ::Array.try_convert( x ) || [ * x ]
        end
        def const_path x
          @kernel.const_path = x ; nil
        end
        def core_basename core_rb
          @kernel.core_basename = core_rb ; nil
        end
        def else &p
          else_p p
        end
        def else_p p
          @kernel.else_p = p ; nil
        end
        def from_module x
          @kernel.from_module = x ; nil
        end
        def result_in_name_and_value
          do_result_in_n_and_v true
        end
        def do_result_in_n_and_v x
          @kernel.do_result_in_n_and_v = x ; nil
        end
      end

      attr_writer :const_path,
        :do_assume_is_defined,
        :do_result_in_n_and_v,
        :else_p,
        :from_module

      def core_basename= x
        x and CORE_FILE_ == x || self._IMPLEMENT_ME
      end

      def flush
        @mod = @from_module
        steps && rslv_result
        @result
      end
    private
      def steps
        @scn = bld_any_step_stream
        if @scn
          nil while step
          @step_OK
        else
          PROCEDE_
        end
      end
      def bld_any_step_stream
        if 1 < @const_path.length
          d = -1 ; last = @const_path.length - 2
          Scn.new do
            d < last and @const_path.fetch( d += 1 )
          end
        end
      end
      def step
        @const_x = @scn.gets
        @const_x and step_with_const_x
      end
      def step_with_const_x
        @step_OK = procure_valid_name_from_const_x && step_with_valid_name
      end
      def procure_valid_name_from_const_x
        @name = Name.via_variegated_symbol @const_x
        @name.as_const or cannot_construe_valid_const
      end

      def cannot_construe_valid_const
        if @else_p && @else_p.arity.nonzero?  # covered
          if 1 == @else_p.arity
            @result = @else_p[ bld_wrong_const_name_exception ]
          else
            @result = @else_p.call :error, :wrong_const_name do
              bld_wrong_const_name_event
            end
          end
        else
          raise bld_wrong_const_name_exception
        end
        CEASE_
      end

      def bld_wrong_const_name_event
        Callback_::Lib_::Event_lib[].inline_not_OK_with :wrong_const_name,
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

      def step_with_valid_name
        _procede = rslv_result_with_valid_name
        if _procede
          @mod = @result ; @result = nil ; PROCEDE_
        else
          CEASE_
        end
      end

      # ~ final step (intermixed with support for pre-final step)

      def rslv_result
        @const_x = @const_path.fetch( -1 )  # or not
        if procure_valid_name_from_const_x
          @do_result_in_n_and_v_for_step = @do_result_in_n_and_v
          rslv_result_with_valid_name
        end
      end
      def rslv_result_with_valid_name
        if @do_assume_is_defined
          rslv_result_when_assume_is_defined
        else
          rslv_result_by_any_means
        end
      end
      def rslv_result_when_assume_is_defined  # leverage whatever autoloading
        # the node defines for itself with a fuzzy name that we assume it will
        # resolve; and then after the node has loaded the value, if necessary
        # we go back and resolve the correct casing/scheme for the fuzzy
        # name.
        @result = @mod.const_get @name.as_const, false
        if @do_result_in_n_and_v_for_step
          rslv_some_result_via_fuzzy_lookup -> i { @result = [ i, @result, ] }
        end
        PROCEDE_
      end
      def rslv_some_result_via_fuzzy_lookup one_p=nil, many_p=nil, zero_p=nil
        stem = @name.as_distilled_stem
        a = [] ; @mod.constants.each do |const_i|
          stem == Distill_[ const_i ] and a << const_i
        end
        @result = case a.length <=> 1
        when -1 ; zero_p ? zero_p[] : prdc_result_when_const_not_defined
        when  0 ; one_p ? one_p[ a.first ] :
                    rslv_some_result_from_correct_const( a.first )
        when  1 ; many_p ? many_p[ a ] : rslv_some_result_when_ambiguous( a )
        end
      end
      def rslv_some_result_from_correct_const i
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

      def rslv_result_by_any_means
        if @mod.const_defined? @name.as_const, false
          @result = rslv_some_result_from_correct_const @name.as_const
          PROCEDE_
        else
          rslv_result_via_name_search_or_loading
        end
      end
      def rslv_result_via_name_search_or_loading
        found = false
        x = rslv_some_result_via_fuzzy_lookup(

          -> i do  # when it is one stop now
            found = true
            rslv_some_result_from_correct_const i
          end,

          -> a do  # when it is many fail/resolve now
            found = true
            rslv_some_result_when_ambiguous a
          end,

          EMPTY_P_ )  # when it is zero do nothing
        if found
          @result = x
          PROCEDE_
        elsif @mod.respond_to? :dir_pathname
          @result = rslv_some_result_via_loading
          PROCEDE_
        else
          rslv_result_when_const_not_defined
        end
      end
      def rslv_some_result_via_loading
        tree = rslv_any_tree
        tree and np = tree.normpath_from_distilled( @name.as_distilled_stem )
        if np
          rslv_some_result_by_loading_some_file_in_normpath np
        else
          prdc_result_when_const_not_defined
        end
      end
      def rslv_any_tree
        if @mod.respond_to? :entry_tree
          tree = @mod.entry_tree
        else
          dpn = @mod.dir_pathname
          dpn and tree = LOOKAHEAD_[ dpn ]
        end
        tree
      end

      def rslv_some_result_by_loading_some_file_in_normpath np
        file = np.can_produce_load_file_path && np
        if file
          rslv_some_result_by_loading_file_for_normpath file
        else
          prdc_result_when_const_not_defined
        end
      end
      def rslv_some_result_by_loading_file_for_normpath file_normpath
        file_normpath.change_state_to :loaded
        @did_require = true
        @normpath_that_was_required = file_normpath
        _path = file_normpath.get_require_file_path
        require _path
        rslv_some_result_via_fuzzy_lookup
      end
      def rslv_some_result_when_ambiguous a
        idx = a.index @name.as_const
        idx or self._NEVER_BEEN_TESTED
        const = a.fetch idx
        r = @mod.const_get const, false
        if @do_result_in_n_and_v_for_step
          r = [ const, r ]
        end
        r
      end
      def rslv_result_when_const_not_defined
        @result = prdc_result_when_const_not_defined
        CEASE_
      end

      def prdc_result_when_const_not_defined
        if @else_p
          case @else_p.arity
          when 0
            @else_p[]
          when 1
            @else_p[ build_name_error ]
          else
            @else_p.call :error, :uninitialized_constant do
              bld_name_error_event
            end
          end
        else
          raise build_name_error
        end
      end

      def bld_name_error_event
        Callback_::Lib_::Event_lib[].inline_not_OK_with(
            :uninitialized_constant, :name, @name.as_variegated_symbol,
              :mod, @mod ) do |y, o|
          y << "uninitialized constant #{ o.mod }::( ~ #{ o.name } )"
        end
      end

      def build_name_error
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

      # ~

      def Proc_.via_args x_a
        2 > x_a.length and raise ::ArgumentError, "(#{ x_a.length } for 2)"
        shell = Shell_.new( kernel = Kernel_.new )
        shell.const_path x_a.fetch 0
        shell.from_module x_a.fetch 1
        kernel.flush
      end

      # ~

      def Proc_.with * x_a
        via_iambic x_a
      end

      # ~

      def Proc_.via_iambic x_a
        kernel = Kernel_.new
        shell = Shell_.new kernel
        begin
          k, v = x_a.shift 2
          shell.send k, v
        end while x_a.length.nonzero?
        kernel.flush
      end

      # ~

      CEASE_ = false
      IGNORED_ = nil
      PROCEDE_ = true
      Kernel_ = self
    end
  end
end
