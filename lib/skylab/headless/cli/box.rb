module Skylab::Headless

  module CLI::Box
  end


  module CLI::Box::InstanceMethods
    # Tests for this exist in the frontier product "my-tree".
    # note that for now this module is kept as standalone, until
    # we get a chance to develop with non-client box controllers.

  protected

    def box_enqueue_help!
      cmd = argv.shift if CLI::OPT_RX !~ argv.first # hack for prettier syntax:/
      enqueue! -> { help cmd }
    end

    def default_action
      :dispatch
    end

    def dispatch action=nil, *args # `args` (the name) is cosmetic here, careful
      if action
        klass = fetch action
        if klass
          klass.new( self ).invoke args
        end
      else
        error expecting_string
        usage_and_invite
      end
    end

    def emit type, *payload       # [#ps-002] this is really asking for it:
      if payload.empty? and ::String === type # all we want to do is centralize
        payload.push type         # all the redundant emits to :help in a
        type = :help              # centralized way that is readable.  Hopefully
      end                         # box controllers aren't busy with too much
      super type, *payload        # else.
    end

    def expecting_string
      "expecting {#{ box.each.map { |x|
                              kbd  x.normalized_local_action_name }.join '|' }}"
    end

    def fetch action_str
      # #todo: fuzzy find
      box.const_fetch action_str,
        -> e do
          error "there is no \"#{ e.name }\" action. #{ expecting_string }"
          usage_and_invite
        end,
        ->( e ) do
          error "invalid action name: #{ e.invalid_name }"
          usage_and_invite
        end
    end

    def help action=nil # override parent b/c we are box, we take action!
      if action
        if argv.any?
          emit "(ignoring: \"#{ argv.shift }\"#{ ' .. ' if argv.any? })"
        end
        klass = fetch action
        if klass
          klass.new( self ).help
        end
      else
        help_screen
      end
      true                                     # continue w/ queue i suppose
    end

    smart_summary_width = -> option_parser, actions do
      # (Find the narrowest we can make column A of both sections (options
      # and actions) such that we accomodate the widest content there!)

      max = actions.reduce 0 do |m, a|         # width of the widest action name
        (x = a.normalized_local_action_name.to_s.length) > m ? x : m
      end
      max = CLI::FUN.summary_width[ option_parser, max ] # ditto here
      max + option_parser.summary_indent.length - 1 # ditto "parent" module
    end

    define_method :help_screen do
      emit usage_line
      actions = box.each.to_a.freeze           # sure why not, cautious for now
      option_parser.summary_width = smart_summary_width[ option_parser, actions]
      help_options
      _help_actions actions if actions.any?
      emit ''                                  # assumes there is section above!
      emit "use #{ kbd "#{ normalized_invocation_string } -h <action>"
                  } for help on that action"
      nil
    end

    def _help_actions actions
      emit ''
      emit "#{ em 'actions:' }"
      ind = option_parser.summary_indent
      fmt = "%-#{ option_parser.summary_width }s"
      actions.each do |a|
        emit "#{ ind }#{ kbd( fmt % [ a.normalized_local_action_name ] ) } #{
          }teach me how to #{ a.normalized_local_action_name }"
      end
      nil
    end

    def invite_line # override parent because we are box, we take action!
      "use #{ kbd "#{ normalized_invocation_string } -h [<action>]" } for help"
    end
  end
end
