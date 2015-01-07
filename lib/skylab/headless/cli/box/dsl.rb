module Skylab::Headless

  module CLI

    module Box

      module DSL  # read [#040] #storypoint-5
        to_proc = -> x_a do
          if ! private_method_defined? DISPATCH_METHOD_I_
            Box[ self, :core_instance_methods ]
          end
          extend CLI::Action_::DSL_Meths
          module_exec( & Preserve_box_property_methods__ )
          extend MMs__ ; include IMs__
          :leaf_action_base_class == x_a.first and x_a.shift and
            module_exec x_a, & Bundles__::Leaf_action_base_class
          nil
        end ; define_singleton_method :to_proc do to_proc end

        module Bundles__
          Leaf_action_base_class = -> x_a do
            x = x_a.shift
            _p = x.respond_to?( :call ) ? x : -> { x }
            singleton_class.class_exec do
              define_method :leaf_action_base_cls, _p
              private :leaf_action_base_cls
            end ; nil
          end
        end

        module MMs__

          def unbound_action_box
            @unbnd_act_bx ||= rslv_unbound_action_box
          end
        private
          def rslv_unbound_action_box
            const_defined? ACTIONS_BOX_MOD_I__, false or intlz_unbound_act_box
            const_get ACTIONS_BOX_MOD_I__, false
          end
          def intlz_unbound_act_box  # #storypoint-25
            respond_to? :dir_pathname or Autoloader_[ self ]
            mod = const_set ACTIONS_BOX_MOD_I__, ::Module.new
            Autoloader_[ mod, :boxxy ] ; nil
          end
        end

        ACTIONS_BOX_MOD_I__ = :Actions

        module MMs__
          attr_reader :_DSL_is_off
        private
          def method_added i  # #storypoint-55
            _DSL_is_off or fnsh_active_action i
          end
        public
          def with_DSL_off
            befor = _DSL_is_off
            @_DSL_is_off = true
            r = yield
            @_DSL_is_off = befor ; r
          end
          def turn_DSL_off
            @_DSL_is_off = true ; nil
          end
          def turn_DSL_on
            @_DSL_is_off = false ; nil
          end
          attr_reader :crrnt_open_action_cls
        private
          def fnsh_active_action i
            unbound_action_box.const_set(
              Callback_::Name.via_variegated_symbol( i ).as_const,
              rls_some_open_action_class )
          end
          def rls_some_open_action_class
            cls = some_crrnt_open_action_class
            @crrnt_open_action_cls = nil
            cls
          end
          def some_crrnt_open_action_class
            @crrnt_open_action_cls ||= bld_open_action_class
          end
          def bld_open_action_class
            unbound_acts_mod = unbound_action_box
            ::Class.new( leaf_action_base_cls ).class_exec do
              extend Leaf_MMs__ ; include Leaf_IMs__
              const_set :ACTIONS_ANCHOR_MODULE_P__, -> { unbound_acts_mod }
              undef_method :invoke  # catch issues early
              self
            end
          end
          def leaf_action_base_cls
            ::Object
          end
        end  # box m.m's

        module Leaf_MMs__

          include CLI::Action_::DSL_Meths

          include Headless_::Action::Anchored_Name_MMs
        end

        module IMs__
        private
          def argument_stx
            if @is_engaged
              arg_stx_as_DSL_box_engaged
            else
              arg_stx_as_DSL_box_disengaged
            end
          end
          def arg_stx_as_DSL_box_engaged
            argument_syntax_for_action_i @bound_downtree_action.name.as_lowercase_with_underscores_symbol
          end
          def arg_stx_as_DSL_box_disengaged
            argument_syntax_for_action_i default_action_i
          end
          def initialize( * )
            @bound_downtree_action = nil ; @is_engaged = false
            @is_leaf = false ; @node_stry = nil
            @reached_this_point = false
            super
          end
        public
          attr_reader :is_leaf  # #storypoint-155
          def bound_action_was_created_for_disptch disp  # #storypoint-105
            super  # notify it but disregard result
            engg_with disp.bound_receiver
            @argv, = disp.args
            befor = queue_len
            x = parse_opts @argv
            if PROCEDE_X_ != x
              Value_Dispatch_[ x ]
            elsif befor == queue_len
              crt_dispatch_for_bound_downtree
            else
              NO_OP_  # something was added to the queue, just bubble up
            end
          end
        private
          def engg_with downtree
            @is_engaged and self._SANITY
            @bound_downtree_action = downtree
            @has_od = nil ; @is_engaged = true ; @is_leaf = downtree.is_leaf
            @node_stry_before_engagement = @node_stry ; @node_stry = nil
            @op_before_engagement = @option_parser
            @option_parser = downtree.any_op
            nil
          end
          def dsngg_from downtree
            @is_engaged or self._SANITY
            @bound_downtree_action = nil
            @has_od = nil ; @is_engaged = false ; @is_leaf = false
            @node_stry = @node_stry_before_engagement
            @node_stry_before_engagement = nil
            @option_parser = @op_before_engagement
            @op_before_engagement = nil ; nil
          end

          class DSL::Value_Dispatch_
            class << self ; alias_method :[], :new end
            def initialize x
              @value_x = x ; nil
            end
            attr_reader :value_x
            def bound_receiver ; self end
            def dispatchee_method_i ; :value_x end
            def args ; EMPTY_A_ end
            def invite_line ; end  # eew
          end
          DSL::NO_OP_ = class DSL::The_No_op_dispatch__
            alias_method :initialize, :freeze
            def bound_receiver ; self end
            def dispatchee_method_i ; :noop end
            def args ; EMPTY_A_ end
            def noop ; PROCEDE_X_ end
            self
          end.new

          def crt_dispatch_for_bound_downtree  # #storypoint-175
            _meth_i = @bound_downtree_action.name.as_lowercase_with_underscores_symbol
            enqueue _meth_i
            if @reached_this_point
              NO_OP_
            else
              _disp = Raw_Dispatch__.new self, :invk_when_engaged, EMPTY_A_
              _disp
            end
          end

          def invk_when_engaged
            r = invoke
            CEASE_X_ == r and r = nil  # don't double up the errmsgs
            r
          end
        end

        Raw_Dispatch__ = ::Struct.
          new :bound_receiver, :dispatchee_method_i, :args

        module Leaf_IMs__
          include CLI::Action_::IMs
          def any_op
            op
          end
        private
          def build_option_parser
            @request_client.build_op_for_bound_actn self
          end
        public
          def any_option_prsr_p_a
            self.class.any_option_parser_p_a
          end
          def any_build_option_prsr_p
            self.class.any_build_op_p
          end
        end

        module IMs__

          def any_op  # :[#hl-158] fix
            op
          end

          def build_op_for_bound_actn bound
            if (( bld_p = bound.any_build_option_prsr_p ))
              bld_option_parser_for_bound_with_p bound, bld_p
            else
              bld_normal_option_parser_for_bound bound
            end
          end
        private
          def bld_option_parser_for_bound_with_p bound, bld_p
            instance_exec( & bld_p )
          end
          def bld_normal_option_parser_for_bound bound
            op = bound.begin_option_parser
            p_a = bound.any_option_prsr_p_a
            p_a and apply_p_a_on_op p_a, op
            match = lng_help_switch_rx.method :=~
            has = op.top.list.index do |x|
              x.respond_to? :long or next
              a = x.long or next
              a.index( & match )
            end
            has or add_hlp_for_child_to_op bound, op
            op
          end
          def lng_help_switch_rx
            @lhsrx ||= bld_long_help_switch_rx
          end
          def bld_long_help_switch_rx
            _long = say_with_lxcn :LNG_HLP_SW
            /\A#{ ::Regexp.escape _long }\b/
          end
        private
          def add_hlp_for_child_to_op bound, op
            _a = lexical_vals_at :SHRT_HLP_SW, :LNG_HLP_SW, :THS_SCRN
            op.on( * _a ) do
              enqueue_with_args :help, -> { }  # #storypoint-195
            end
            op
          end
          def help_screen_for_chld y, chld_x  # #storypoint-200
            if @is_engaged
              x = chld_x[] and fail "sanity - #{ Headless_.lib_.strange x }"
              hlp_screen_as_engaged_box y
            else
              bound = rslv_bound_action_for_help chld_x
              bound ? hlp_screen_for_bound_child( y,  bound ) : CEASE_X_
            end
          end
          def hlp_screen_for_bound_child y, bound
            engg_with bound
            r = hlp_screen_as_engaged_box y
            dsngg_from bound
            r
          end
          def hlp_screen_as_engaged_box y
            @argv.length.zero? or on_extra_argv_during_hlp y
            help_screen y
          end
          def prepare_for_help_screen_as_bx
            if @is_engaged
              replace_queue_head_wth_i @bound_downtree_action.name.as_lowercase_with_underscores_symbol
            else
              super
            end ; nil
          end
        public  # #storypoint-405
          def invite_line z=nil
            if @is_engaged
              normalized_invocation_string_prts( y = [] )
              y[ -1, 0 ] = [ say_with_lxcn( :SHRT_HLP_SW ) ]
              _cmd = y * TERM_SEPARATOR_STRING_
              render_invite_line _cmd, z
            else
              super
            end
          end
          def normalized_invocation_string_prts y
            super
            @is_engaged and y << @bound_downtree_action.name.as_slug ; nil
          end
        private
          def render_any_hlp_dsc y
            if @is_engaged
              super
            else
              super
            end
          end
        public
          def any_description_p_a_for_stry
            if @is_engaged
              @bound_downtree_action.any_description_p_a_for_stry
            else
              super
            end
          end
          def add_any_supplemental_sections_for_stry y
            if @is_engaged
              @bound_downtree_action.add_any_supplemental_sections_for_stry y
            else
              super
            end
          end
        private
          def build_any_line_sexp_about_this_chld bound
            @is_engaged and self._SANITY
            engg_with bound
            _summary_line = some_summary_ln
            dsngg_from bound
            [ :item, bound.name.as_slug, _summary_line ]
          end
          def render_any_hlp_opts y
            if @is_engaged
              super
            else
              super
            end
          end
          def render_any_hlp_sects y
            if @is_engaged
              super
            else
              super
            end
          end
          def render_any_hlp_addtn y
            if @is_engaged
              @bound_downtree_action.send :render_any_hlp_addtn, y
            else
              super
            end
          end
        end

        # ~ fix [#158] (tall stacks with hybrid box nodes)

        module MMs__
          def produce_arg_syntax
            @as ||= bld_arg_syntax
          end
          def bld_arg_syntax
            _i_a_a = instance_method( DISPATCH_METHOD_I_ ).parameters
            CLI.argument.syntax.isomorphic _i_a_a
          end
        end

        module IMs__
        private
          def produce_call_tuple_from_method_i_and_valid_args meth_i, a
            @reached_this_point  = true  # help
            if action_is_defined_via_meth meth_i
              super
            else
              prdc_call_tuple_because_it_is_another_box meth_i, a
            end
          end

          def prdc_call_tuple_because_it_is_another_box act_i, a
            1 == @q_x_a.length && act_i == @q_x_a.first or self._SANITY
            # leave the above on the queue, it gets cleared later
            @is_engaged or self._SANITY
            bnd = @bound_downtree_action
            dsngg_from bnd
            _meth = bnd.method DISPATCH_METHOD_I_
            [ OK_, _meth, a ]
          end
        end

        OK_ = CLI::Action_::OK_

        # #storypoint-505: the auxiliaries, the 'DSL' part of the DSL

        module MMs__
          def build_option_parser &p
            some_crrnt_open_action_class.class_exec do
              build_option_parser( & p )
            end ; nil
          end
        end
        module Leaf_MMs__
          attr_reader :any_build_op_p
        private
          def build_option_parser & p  # #storypoint-515
            any_build_op_p and raise "`b.o.p` is write-once."
            any_option_parser_p_a and raise say_bop_op_mutex
            @any_build_op_p = p ; nil
          end
          def option_parser
            any_build_op_p and raise say_bop_op_mutex
            super
          end
          def say_bop_op_mutex
            "`b.o.p` and `o.p` are mutually exclusive"
          end
        end

        WMETH_I_A__ = %w( append_syntax desc
          option_parser option_parser_class ).freeze

        module MMs__
          WMETH_I_A__.each do |i|
            define_method i do |*a, &p|
              some_crrnt_open_action_class.send i, *a, &p
            end
          end
          private( * WMETH_I_A__ )
        end

        module MMs__
        private
          def box
            @box_properties_DSL_writer_proxy ||=
              Box_Props_DSL_Writer_Proxy__.new self
          end
        end

        class Box_Props_DSL_Writer_Proxy__

          def initialize mod
            @mod = mod ; nil
          end

          WMETH_I_A__.each do |i|
            define_method i do |*a, &p|
              @mod.send :"#{ i }_before_box_DSL", *a, &p
            end  # NOTE we intentionally leave them public here
          end
        end

        Preserve_box_property_methods__ = -> do
          singleton_class.class_exec do
            WMETH_I_A__.each do |i|
              alias_method :"#{ i }_before_box_DSL", i
            end ; nil
          end
        end
      end  # DSL
    end  # Box
  end  # CLI
end
