module Skylab::Headless

  module CLI::Box

    module InstanceMethods  # read [#137] the CLI box.. #storypoint-1

      include CLI::Action::InstanceMethods

      def is_leaf  # #hook-in to the o.p facility
        false
      end

    private

      def default_action  # #hook-out
        :dispatch
      end

      def dispatch action=nil, *args  # #storypoint-2, NOTE names are UI labels
        @curried = Dispatch__.new( self, action, args ).execute
        @curried and flush_curry
      end
      def flush_curry
        r = @curried.hot.invoke @curried.arg_a
        false == r and r = on_ht_faild
        @curried = nil ; r
      end
      def on_ht_faild
        s = @curried.hot.invite_line
        s and help_yielder << s ; nil
      end
    public
      def no_action_notify disp
        error say_expting
        usage_and_invite
      end
    private
      # [#119] intentionally ugly names are used here
      def say_expting
        "expecting #{ act_arg_stx_s }"
      end
    public
      def fetch_action_class_notify action_s  # storypoint-3
        action_box_module.const_fetch action_s, method( :on_no_act )
      end
    private
      def action_box_module
        self.class.action_box_module
      end
      def on_no_act name_err
        exp_s = say_expting
        error say { "there is no #{ ick name_err.const } action. #{ exp_s }" }
        usage_and_invite
      end
    end

    class Dispatch__
      def initialize client, action_s, arg_a
        @action_s = action_s ; @arg_a = arg_a ; @client = client ; nil
      end
      attr_reader :arg_a, :hot
      def execute
        if @action_s
          when_action
        else
          when_no_action
        end
      end
    private
      def when_no_action
        @client.no_action_notify self
      end
      def when_action
        @cls = @client.fetch_action_class_notify @action_s
        @cls and when_class
      end
      def when_class
        @hot = @cls.new @client
        self
      end
    end

    module InstanceMethods

    private  # ~ private #hook-in's to self

      def help *action  #hook-in # #storypoint-9
        @queue[ 0 ] = default_action
        help_screen help_yielder, *action
        true
      end

      def help_screen y, action=nil  # :+#public-API (overrides parent)
        if action
          hlp_scrn_fr_chld y, action
        else
          super y
          if s = nvt_ln_about_act
            y << EMPTY_STRING_ # assume there is some section above
            y << s
          end
        end ; nil
      end ; protected :help_screen  # #protected-not-private

      def nvt_ln_about_act  # #storypoint-99
        render_invite_line "#{ normalized_invocation_string } -h <action>",
          "on that action"
      end

      def hlp_scrn_fr_chld y, action_x
        @argv.length.zero? or on_ignrd_argv y
        hot = rslv_hot_action_fr_hlp action_x
        hot and hot.help_screen y ; nil
      end

      def on_ignrd_argv y
        y << "(ignoring: \"#{ @argv.first }\"#{
          }#{ ' .. ' if 1 < @argv.length })" ; nil
      end

      def rslv_hot_action_fr_hlp action_cls_x
        if action_cls_x.respond_to? :call
          action_cls_x.call
        else
          cls = fetch_action_class_notify action_cls_x
          cls and cls.new self
        end
      end

      def build_desc_lines  #hook-in to our own API  # #storypoint-11
        r = super
        a = gt_hot_child_a
        a.length.zero? or add_sect_w_one_line_per_child a
        r
      end

      def gt_hot_child_a
        action_box_module.each.reduce [] do |m, (_, cls)|
          m << ( cls.new self )  # ich muss sein - we need a charged graph
        end
      end

      def add_sect_w_one_line_per_child a
        (( @sections ||= [] )) << (( section = start_sect a.length ))
        line_a = section.lines
        a.each do |act|
          line_a << [ :item, act.name.as_slug, act.summary_line ]
        end ; nil
      end

      def start_sect d
        hdr_s = say :chld_acts
        _plural_s = say { "#{ hdr_s }#{ s d }" }
        _hdr_s_ = format_header _plural_s
        CLI::Action::Desc::Section.new _hdr_s_, []
      end

      CLI::Action::LEXICON__.add_entry_with_default :chld_acts, 'action'

      def invite_line z=nil  # #hook-in #storypoint-12
        render_invite_line "#{ normalized_invocation_string } -h [<action>]", z
      end

    # ~ private #hook-out's for client

      def enqueue_help_as_box cmd_s=nil  # #storypoint-7
        if ! cmd_s && CLI::Option::Constants::OPT_RX !~ @argv.first
          cmd_s = @argv.shift
        end
        enqueue [ :help, cmd_s ]
      end

      def render_argument_syntax_term_with_alternation  # #todo - in branch?
        stx = argument_syntax_for_method :dispatch
        y = [ act_arg_stx_s ]
        render_base_arg_syntax_parts y, stx[ 1 .. -1 ]
        y * TERM_SEPARATOR_STRING_ if y.length.nonzero?
      end
      #
      def act_arg_stx_s sep_s=ALTERNATION_SEPARATOR_GLYPH__
        _a = action_box_module.each.reduce [] do |m, (_, x)|
          m << x.name_function.local.as_slug
        end
        kbd_p = say { method :kbd }
        "{#{ _a.map( & kbd_p ) * sep_s }}"
      end

      CLI::Box::ALTERNATION_SEPARATOR_GLYPH__ = '|'.freeze

    end
  end
end
