module Skylab::Headless

  module CLI::Box
    # (will get twerked by autoloader)
  end

  module CLI::Box::InstanceMethods
    # (for now the main coverage of this is in frontier product "my-tree")

    include CLI::Action::InstanceMethods # makes dsl hacks easier, not nec. here

  protected

    #                 ~ core controller-like methods ~

    def action_box_module
      self.class.action_box_module
    end

    def default_action
      :dispatch
    end

    # (because `dispatch` is named as our default action, the variable names
    # and method signature that appears below is both designed that way
    # *and* appears in help screens -- weird!)

    def dispatch action=nil, *args  # (**NOTE** param names are cosmetic!)
      res = nil
      if action
        klass = fetch action
        if klass
          o = klass.new self
          res = o.invoke args
          if false == res                      # this cluster here is what
            help_yielder << o.invite_line      # gives us the terminal action
            res = nil                          # node in the invite line
          end
        end
      else
        error expecting_string
        res = usage_and_invite
      end
      res
    end

    def fetch action_str
      # #todo: fuzzy find
      action_box_module.const_fetch action_str,
        -> e do
          error "there is no #{ ick e.name } action. #{ expecting_string }"
          usage_and_invite
        end,
        ->( e ) do
          error "invalid action name: #{ e.invalid_name }"
          usage_and_invite
        end
    end

    def is_leaf                   # a box is always a branch and we must define
      false                       # this like so (see `is_branch`)
    end

    #   ~ core help-, string-, ui-msg-rendering methods and support ~

    # `box_enqueue_help` - a convenience -h / --help handler to be used in
    # an o.p block for the option. `cmd` is typically the arg passed to your
    # -h (you have to pass it in the handler block to here.)  Hackishly we
    # also just straight up rob @argv of its next token if a) it doesn't look
    # like an option and b) if you didn't pass one in explicitly. For better
    # or worse what this gets you is 'foo -h' handled without `foo` needing
    # to know about it.

    def box_enqueue_help cmd=nil
      if ! cmd && CLI::OPT_RX !~ @argv.first
        cmd = @argv.shift
      end
      enqueue [ :help, cmd ]
    end

    def expecting_string
      a = action_box_module.each.reduce [] do |m, (_, x)|
        m << x.name_function.local.as_slug
      end
      "expecting {#{ a.map(& method( :kbd ) ) * '|' }}"
    end
                                  # a "porcelain-visible" toplevel entrypoint
                                  # method/action for help of *box* actions!
    def help *action              # (the var name you use here appears in the
      @queue[ 0 ] = default_action  # always this is the action we show
      help_screen help_yielder, *action  # the interface!)
      true                        # (just for fun we result in true instead of
    end                           # nil which may have a strange effect..)

    def help_screen y, action=nil
      if action
        help_screen_for_child y, action
      else
        super y
        y << ''                   # assume there is some section above
        y << invite_line_about_action
      end
      nil
    end

    # `build_desc_lines` - this hackishly results in the array *and* has
    # side-effects (#todo) (here b.c called by `help_screen` in parent).
    # When we collapse the descs we build the sections too.

    def build_desc_lines
      res = super
      a = action_box_module.each.reduce [] do |m, (_, c)|
        m << ( c.new self )       # ich muss sein - we need a charged graph
      end
      if a.length.nonzero?
        section = CLI::Desc::Section.new "action#{ s a }:", [ ]
        ( @sections ||= [] ) << section
        a.each do |act|
          section.lines << [ :item, act.name.as_slug, act.summary_line ]
        end
      end
      res
    end

    def help_screen_for_child y, action_ref
      if @argv.length.nonzero?
        y << "(ignoring: \"#{ @argv.shift }\"#{ ' .. ' if @argv.any? })"
      end
      if action_ref.respond_to? :call
        action = action_ref.call
      else
        klass = fetch action_ref
        if klass
          action = klass.new self
        end
      end
      if action
        action.help_screen y
      end
      nil
    end

    def invite_line z=nil  # override parent because we are box, we take action!
      render_invite_line "#{ normalized_invocation_string } -h [<action>]", z
    end
                                  # (in contrast to above, once the user is
                                  # already looking at the full help screen it
                                  # is redundant to again invite her to the
    def invite_line_about_action  # same screen!)
      render_invite_line "#{ normalized_invocation_string } -h <action>",
        "on that action"
    end
  end

  CLI::Box::Proxy = MetaHell::Proxy::Functional.new :desc
    # (used for shenanigans elsewhere..)

end
