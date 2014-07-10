module Skylab::Headless

  module CLI::Box  # read [#137] the CLI box.. #storypoint-5

    def self.[] mod, * x_a
      Bundles__.apply_iambic_on_client x_a, mod ; nil
    end

    module Bundles__
      Core_instance_methods = -> _ do
        include IMs_ ; nil
      end
      DSL = -> x_a do
        module_exec x_a, & CLI::Box::DSL.to_proc ; nil
      end
      Headless::Library_::Bundle::Multiset[ self ]
    end

    CEASE_X__ = CLI::Action::CEASE_X

    module IMs_

      include CLI::Action::IMs

      def is_leaf  # #hook-in to the o.p facility
        false
      end

    private

      def default_action_i  # #hook-out
        DISPATCH_METHOD_I_
      end

      CLI::Box::DISPATCH_METHOD_I_ = :dsptch

      # #storypoint-30 [#119] intentionally ugly names are used here

      def dsptch action=nil, *args  # #storypoint-20, NOTE [#145] params
        disp = disptch_p[ self, action, args ]
        disp and begin
          r = disp.bound_receiver.send disp.dispatchee_method_i, * disp.args
          CEASE_X__ == r and r = dsptch_failed( disp )
          r
        end
      end
      def disptch_p
        Dispatch__
      end
    public
      def no_action_arg_for_dispatch disp  # #todo:after-merge [#139] event model?
        _s = say_expting
        emit_error_line _s
        usage_and_invite
      end
    private
      def say_expting
        "expecting #{ act_arg_stx_s }"
      end
      def act_arg_stx_s sep_s=ALTERNATION_SEPARATOR_GLYPH__
        kbd_p = say { method :kbd }
        _a = unbound_action_box.names.reduce [] do |m, name|  # :+[#cb-031]
          m << name.as_slug
        end
        "{#{ _a.map( & kbd_p ) * sep_s }}"
      end
      def unbound_action_box
        self.class.unbound_action_box
      end
    public
      def fetch_action_cls_for_dispatch action_s
        ftch_action_class action_s
      end
    private
      def ftch_action_class action_s
        Autoloader_.const_reduce do |cr|
          cr.from_module unbound_action_box
          cr.const_path [ action_s ]
          cr.else( & method( :on_no_act ) )
        end
      end
      def on_no_act name_err
        exp_s = say_expting
        _s = say { "there is no #{ ick name_err.name } action. #{ exp_s }" }
        emit_error_line _s
        usage_and_invite
      end
      def dsptch_failed disp
        s = disp.bound_receiver.invite_line
        s and help_yielder << s
        CEASE_X__
      end
    public
      def bound_action_was_created_for_disptch disp  # :+#API-private hook-in
        # this is where you would set e.g @last_action_i
        nil
      end
    end

    class Dispatch__
      Headless::Library_::Funcy[ self ]
      def initialize client, action_s, arg_s_a
        @action_s = action_s ; @arg_s_a = arg_s_a ; @client = client ; nil
      end
      def bound_receiver
        @bound
      end
      def dispatchee_method_i
        CLI::Action::INVOKE_METHOD_I
      end
      def args
        [ @arg_s_a ]  # per the signature of the invoke method
      end
      def execute
        if @action_s
          when_action
        else
          when_no_action_argument
        end
      end
    private
      def when_no_action_argument
        @client.no_action_arg_for_dispatch self
      end
      def when_action
        @cls = @client.fetch_action_cls_for_dispatch @action_s
        @cls and when_class
      end
      def when_class
        @bound = @cls.new @client.client_services_for_bound_action_by_agent
        r = @client.bound_action_was_created_for_disptch self
        r or self
      end
    end

    module IMs_

     # ~ #hook-in's to self (usually but not always private)

      def client_services_for_bound_action_by_agent  # API-private
        self  # placeholder for future #todo:after-merge client svcs
      end
    private
      def help *action  #hook-in # #storypoint-80 NOTE parameter name [#145]
        help_screen help_yielder, *action
      end

      def help_screen y, action_x=nil  # :+#public-API (overrides parent)
        if action_x
          help_screen_for_chld y, action_x
        else
          prepare_for_help_screen_as_bx
          super y
        end
      end ; protected :help_screen  # #protected-not-private

      def prepare_for_help_screen_as_bx
        replace_queue_head_wth_i default_action_i ; nil
      end

      def help_screen_for_chld y, action_x
        @argv.length.zero? or on_extra_argv_during_hlp y
        bound = rslv_bound_action_for_help action_x
        bound and bound.help_screen y
      end

      def on_extra_argv_during_hlp y
        y << "(ignoring: \"#{ @argv.first }\"#{
          }#{ ' .. ' if 1 < @argv.length })" ; nil
      end

      def rslv_bound_action_for_help action_cls_x  # #storypoint-100
        if action_cls_x.respond_to? :call
          action_cls_x.call
        else
          cls = ftch_action_class action_cls_x
          cls and cls.new self
        end
      end

      def render_any_hlp_addtn y
        super
        if s = any_invite_line_as_bx
          y << EMPTY_STRING_  # #assume-previous-line-above
          y << s ; nil
        end
      end

      def any_invite_line_as_bx  # #storypoint-90
        render_invite_line "#{ normalized_invocation_string } -h <action>",
          "on that action"
      end

    public
      def add_any_supplemental_sections_for_stry sect_a  # #storypoint-110
        super
        a = gt_bound_child_a
        a.length.zero? or add_a_sctn_about_the_story_of_our_children sect_a, a
        nil
      end
    private
      def gt_bound_child_a
        client = client_services_for_bound_action_by_agent
        mod = unbound_action_box
        mod.constants.each.reduce [] do |m, const_i|  # :+[#cb-031]
          m << mod.const_get( const_i, false ).new( client )
          # ich muss sein - we need a charged graph
        end
      end

      def add_a_sctn_about_the_story_of_our_children y, a
        y << (( section = strt_actions_section a.length ))
        line_a = section.lines
        a.each do |act|
          x = build_any_line_sexp_about_this_chld act
          x and line_a << x
        end ; nil
      end

      def build_any_line_sexp_about_this_chld bound
        [ :item, bound.name.as_slug, bound.some_summary_ln ]
      end

      def strt_actions_section d
        hdr_s = say :chld_acts
        _plural_s = say { "#{ hdr_s }#{ s d }" }  # don't format or stylize
        CLI::Action::Desc::Section.new _plural_s, []
      end

      CLI::Box::LEXICON_ = CLI::Box::LEXICON__ = CLI::Action::LEXICON__
        # #storypoint-130

      LEXICON__.add do |lx|
        lx.add_entry_with_default :chld_acts, 'action'
      end

      def invite_line z=nil  # #hook-in #storypoint-140
        render_invite_line "#{ normalized_invocation_string } -h [<action>]", z
      end ; public :invite_line

    # ~ private #hook-out's for client

      def enqueue_help_as_box cmd_s=nil  # #storypoint-145
        if ! cmd_s && CLI::Option::Constants::OPT_RX !~ @argv.first
          cmd_s = @argv.shift
        end
        enqueue_with_args :help, cmd_s
      end

      def render_argument_syntax_term_with_alternation  # #todo - in branch?
        stx = argument_syntax_for_action_i DISPATCH_METHOD_I_
        y = [ act_arg_stx_s ]
        render_base_arg_stx_prts y, stx[ 1 .. -1 ]
        y * TERM_SEPARATOR_STRING_ if y.length.nonzero?
      end

      CLI::Box::ALTERNATION_SEPARATOR_GLYPH__ = '|'.freeze

    # ~ optional service method for default o.p support

      def build_option_parser  # :+[#037] box who builds own
        op = create_box_option_parser
        _short, _long, _sub_action, _this_screen, _or_sub_action_help =
          lexical_vals_at :SHRT_HLP_SW, :LNG_HLP_SW, :sb_actn,
            :THS_SCRN, :osah
        _sw = op.define _short, "#{ _long } [<#{ _sub_action }>]",
          "#{ _this_screen } [#{ _or_sub_action_help }]" do |x|
          enqueue_help_as_box x ; true
        end
        do_not_render_switch_in_stx_str _sw
        op
      end

      def create_box_option_parser  # #storypoint-170
        begin_option_parser
      end

      def create_child_op
        begin_option_parser
      end

      LEXICON__.add do |lx|  # for now
        lx.add_entry_with_default :osah, 'or sub-action help'
        lx.add_entry_with_default :sb_actn, 'sub-action'
      end
    end
  end
end
