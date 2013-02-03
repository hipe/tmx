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

    def dispatch action=nil, *args
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

    summary_width = -> option_parser, action_objects do
      # (Find the narrowest we can make column A of both sections (options
      # and actions) such that we accomodate the widest content there!)

      max = action_objects.reduce 0 do |m, a|  # width of the widest action name
        x = a.name.to_slug.to_s.length
        x > m ? x : m
      end
      CLI::Action::FUN.summary_width[ option_parser, max ]
    end

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
      a = action_box_module.each.reduce [] do |m, (k, x)|
        m << x.name_function.local.to_slug
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

    def help_actions y, action_objects
      y << ''                     # (assumes there is a section above)
      y << "#{ em 'actions:' }"
      ind = option_parser.summary_indent
      fmt = "%-#{ option_parser.summary_width }s"

      action_objects.each do |action_object|
        x = action_object.summary_line
        x = " #{ x }" if x
        y << "#{ ind }#{ kbd( fmt % [ action_object.name.to_slug] ) }#{ x }"
      end

      nil
    end

    def help_screen y, action=nil
      if action
        help_screen_for_child y, action
      else
        help_screen_for_adult y
      end
    end

    define_method :help_screen_for_adult do |y|   # (ugly for now..)
      y << usage_line                          # " (means a copypasta of sister)
      help_description y if desc_lines         # "
      actions = action_box_module.each.reduce [] do |m, (k, c)|
        m << ( c.new self )       # ich muss sein - we need a charged graph
      end
      if option_parser            # if we have one we show it *after*..
        @option_parser.summary_width = summary_width[ @option_parser, actions ]
        help_options y            # re-adjust o.p spacing per actions!!
      end
      help_actions( y, actions ) if actions.length.nonzero?
      y << ''                     # assume there is some section above
      y << invite_line_about_action
      nil
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

    def invite_line  # override parent because we are box, we take action!
      render_invite_line "#{ normalized_invocation_string } -h [<action>]"
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
