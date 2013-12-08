module Skylab::Headless

  module CLI::Box::DSL

    # ~ never say never

    def self.[] mod, * x_a
      mod.module_exec x_a, & To_proc
    end

    To_proc = -> x_a do
      MetaHell::MAARS::Upwards[ self ]  # #re-entrant
      extend MMs__ ; include IMs__  # NOTE 'method_added' hook
      x_a && x_a.length.nonzero? and
        Bundles__.apply_iambic_on_client x_a, self ; nil
    end

    module Bundles__
      # populated within narrative below
      MetaHell::Bundle::Multiset[ self ]
    end

    module MMs__  # read [#040] - #storypoint-1

      include Autoloader::Methods

      include CLI::Action::ModuleMethods  # #reach-up!

    private  # ~ #storypoint-6 the bread and butter of this module is these..

      def append_syntax s
        some_act_cls.append_syntax s ; nil  # [#119] intentionally ugly names
      end

      def build_option_parser & p
        some_act_cls.build_option_parser( & p ) ; nil
      end

      def option_parser &p
        some_act_cls.option_parser( & p ) ; nil
      end

      def option_parser_class x
        some_act_cls.option_parser_class x ; nil
      end

      alias_method :wrt_bx_dsc, :desc  # picks up below

      def desc *a, &p   # #storypoint-3 :+[#033] general tracker of desc
        if p and a.length.zero?
          acpt_dsc p
        else
          some_act_cls.desc( *a, &p )
        end
      end

      def acpt_dsc p
        some_act_cls.desc do |y|
          me = self
          @request_client.instance_exec do
            if @downstream_action
              me.object_id == @downstream_action.object_id or
                change_to me
            else
              collapse_to me  # #jump-3
            end
            instance_exec y, &p
          end ; nil
        end
      end

      def method_added meth_i  # #storypoint-8  #hook-in to ruby.
        if ! dsl_is_disabled
          _const_i = Autoloader::FUN.constantize[ meth_i ]
          action_box_module.const_set _const_i, some_act_cls
          @action_class_in_progress = nil
        end
      end
    public
      attr_reader :dsl_is_disabled
    private
      def turn_DSL_off  # (not used or covered #todo)
        @dsl_is_disabled = true ; nil
      end
      #
      def turn_DSL_on
        @dsl_is_disabled = false ; nil
      end

      # ~ #storypoint-7 (the next several methods)

      def some_act_cls
        @action_class_in_progress ||= bld_act_cls
      end
      def bld_act_cls
        box = self
        ::Class.new( leaf_act_supercls ).class_exec do
          extend Leaf_MMs__
          const_set :ACTIONS_ANCHOR_MODULE, box.action_box_module  # #jump-1
          include Leaf_IMs__
          @tug_class = MAARS::Tug
          define_method :argument_syntax do  # #storypoint-2
            Headless::CLI::Argument::Syntax::Inferred.new(
              box.instance_method( leaf_method_name ).parameters, nil )
          end
          undef_method :invoke
          self
        end
      end
      def leaf_act_supercls
        ::Object
      end
    end
    module Leaf_IMs__
      def leaf_method_name
        name.local_normal
      end
    end
    module Bundles__
      Leaf_action_base_class = -> x_a do
        p = x_a.shift
        define_singleton_method :leaf_act_supercls, p ; nil
      end
    end
    module MMs__  # (still in #storypoint-7)
      def action_box_module  # :#jump-1. must be public
        if const_defined? ACTIONS_CONST_I__, false
          const_get ACTIONS_CONST_I__, false
        else
          const_set ACTIONS_CONST_I__, bld_action_bx_mod
        end
      end
    private
      def bld_action_bx_mod
        box = self
        ::Module.new.module_exec do
          include CLI::Box::InstanceMethods
          @tug_class = MAARS::Tug
          if box.dir_pathname
            @dir_pathname = box.dir_pathname.join ACTIONS_STRING__
          else
            @dir_pathname = false  # tells a.l not to try to induce our path
            box.add_dir_pathname_listener ACTIONS_CONST_I__, self
          end
          MetaHell::Boxxy[ self ]
          self
        end
      end
      ACTIONS_CONST_I__ = :Actions ; ACTIONS_STRING__ = 'actions'.freeze
    end

    module MMs__

      def box  # #storypoint-5 experimental way to get thru to the host cls
        @box_proxy ||= bld_bx_pxy
      end
    private
      def bld_bx_pxy
        Pxy__[].new( desc: -> *a do
          wrt_bx_dsc( * a )
        end )
      end
      Pxy__ = MetaHell::FUN::Memoize[ -> do
        Pxy___ = MetaHell::Proxy::Functional.new :desc
      end ]
    end

    module IMs__

      include CLI::Box::InstanceMethods

      def initialize * _
        @downstream_action = @is_leaf = @option_parser = @prev_frame = nil
        @queue = []
        super( * _ )
      end

    private

      def dispatch action=nil, *args  # #storypoint-094.  NOTE args are UI la..
        if action then
          cry = rslv_task_with_action_x_and_args action, args
          cry and cry.receiver.send cry.method_name, * cry.arguments
        else
          super
        end
      end

      def rslv_task_with_action_x_and_args x, a
        cls = fetch x  # #after-merge: rename
        cls and rslv_task_with_action_class_and_args cls, a
      end

      def rslv_task_with_action_class_and_args cls, a
        hot = cls.new self
        if hot.is_branch  # why deny the child its own autonomy
          rslv_task_with_hot_branch_and_args hot, a
        else
          collapse_to hot
          Method_Curry__.new method( :invoke ), [ a ]
        end
      end

      def rslv_task_with_hot_branch_and_args hot, a
        Method_Curry__.new hot.method( :invoke ), [ a ]
      end
    end

    Method_Curry__ = Headless::Services::Basic::Method::Curry

    Frame__ = ::Struct.new :is_leaf, :option_parser  # below

    module IMs__

      attr_reader :is_leaf  # #hook-out, # #storypoint-95 - leaf or branch?

    private

      def collapse_to hot  # #storypoint-96, :#jump-3
        if @queue.length.nonzero?
          :dispatch == @queue.fetch( 0 ) or fail 'sanity'
        end
        @prev_frame ||= Frame__.new  # really asking for it
        @prev_frame.is_leaf = false
        @prev_frame.option_parser = @option_parser
        change_to hot ; nil
      end

      def change_to hot
        @downstream_action = hot
        @is_leaf = hot.is_leaf
        @option_parser = hot.option_parser
        @queue[ 0 ] = hot.leaf_method_name ; nil
      end

      def uncollapse_from leaf_i  # #storypoint-60
        leaf_i == @downstream_action.normalized_local_action_name or
          raise "sanity - expected '#{ i }' had .."
        @is_leaf = @prev_frame.is_leaf
        @prev_frame.is_leaf = nil
        @option_parser = @prev_frame.option_parser
        @prev_frame.option_parser = nil
        @downstream_action = nil ; nil
      end

      def default_action  # #hook-out
        @default_action ||= :dispatch
      end

      # ~ #storypoint-80 #hook-in to facilities to customize them

      def normalized_invocation_string as_collapsed=true
        a = [ super() ]
        is_collapsed && as_collapsed and a << @downstream_action.name.as_slug
        a * TERM_SEPARATOR_STRING_
      end

      def is_collapsed
        @downstream_action
      end

      def build_option_parser  # popular default, :+[#037] box who builds own
        op = create_box_option_parser
        sw = op.define '-h', '--help [<sub-action>]',
            'this screen [or sub-action help]' do |x|
          box_enqueue_help x ; true
        end
        do_not_render_switch_in_syntax_string sw
        op
      end

      def do_not_render_switch_in_syntax_string sw  # #todo this goes away after merge
        option_is_visible_in_syntax_string[ sw.object_id ] = false ; nil
      end

      def create_option_parser
        op = Headless::Services::OptionParser.new
        op.base.long.clear  # never use builtin 'officious' -v, -h  # [#059]
        op
      end
      # #storypoint-50
      alias_method :create_box_option_parser, :create_option_parser
      alias_method :create_leaf_option_parser, :create_option_parser

      def argument_syntax  # [#063] a smell from hybridiation
        if is_collapsed
          argument_syntax_when_collapsed
        else
          argument_syntax_when_not_collapsed
        end
      end

      def argument_syntax_when_collapsed
        argument_syntax_for_method @downstream_action.
          normalized_local_action_name
      end

      def argument_syntax_when_not_collapsed
        argument_syntax_for_method :dispatch
      end

      def render_argument_syntax syn, em_range=nil  # [#063] a hybrid'n smell
        if is_collapsed && @downstream_action.class.append_syntax_a
          "#{ super } #{ render_downstream_action_append_syntax_a }"
        else
          super
        end
      end

      def render_downstream_action_append_syntax_a
        @downstream_action.class.append_syntax_a * TERM_SEPARATOR_STRING_
      end

      def invite_line z=nil  # [#063] a smell from hybridiaztion
        if is_collapsed
          render_invite_line "#{ normalized_invocation_string false } -h #{
            }#{ @downstream_action.name.as_slug }", z
        else
          super
        end
      end

      def build_desc_lines  # #storypoint-98, :#jump-2, [#063] smell
        x = super
        if is_collapsed
          uncollapse_from @downstream_action.normalized_local_action_name
        end ; x
      end

      def enqueue_help  # #storypoint-99
        norm_i = @downstream_action.normalized_local_action_name
        @queue.first == norm_i or fail 'sanity'
        @queue.shift  # done processing the name, shift it off
        box_enqueue_help norm_i
        @downstream_action = nil ; nil
      end
    end

    module Leaf_MMs__

      include CLI::Action::ModuleMethods  # #reach-up!

      def any_build_option_parser_p  # :#jump-4
        build_option_parser_p
      end
      attr_reader :build_option_parser_p
      def build_option_parser &p  # this is the DSL block writer, gets called
        p or raise ::ArgumentError, "block required."
        option_parser_blocks and raise ::ArgumentError, "bop must be before op"
        @build_option_parser_p = p ; nil
      end
      def option_parser_class x
        any_build_option_parser_p and raise ::ArgumentError, "#{
          }b.o.p and o.p are mutually exclusive."
        define_method :option_parser_class do x end ; nil
      end
    end

    module Leaf_IMs__

      include CLI::Action::InstanceMethods

      def build_option_parser  # #storypoint-100
        build_op_p = self.class.any_build_option_parser_p  # #jump-4
        build_op_p ||= build_build_op_p
        request_client.instance_exec( & build_op_p )
      end
    private
      def build_build_op_p
        leaf = self
        -> do
          op = leaf.crt_any_op || create_leaf_option_parser
          instance_exec op, & leaf.wrt_any_op_blks_p
          instance_exec op, & leaf.wrt_any_help_option_p
          op
        end
      end
    public
      def crt_any_op
        if (( cls = option_parser_class ))
          cls.respond_to?( :call ) and cls = cls.call
          cls.new
        end
      end
    private
      def option_parser_class  # :#hook-in for custom o.p class
      end
    public
      def wrt_any_op_blks_p  # (method visibiliy does not API visibility eql)
        leaf = self
        -> op do
          p_a = leaf.class.option_parser_blocks
          p_a and p_a.each do |p|
            instance_exec op, &p
          end ; nil
        end
      end
      def wrt_any_help_option_p
        leaf = self
        -> op do
          op.on '-h', '--help', 'this screen' do
            leaf_i = leaf.normalized_local_action_name
            @prev_frame and uncollapse_from leaf_i  # else hackery
            if @queue.length.nonzero?
              leaf_i == @queue.first or fail "sanity - #{ @queue.first }"
              @queue.shift
            end
            enqueue [ :help, -> { leaf } ] ; nil
          end
        end
      end
    end
  end
end
