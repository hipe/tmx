module Skylab::Treemap

  class Adapter::Action::Unbound

    #                      ~ Unbound Actions wtf ~
    #        a ridiculous experiment: the action as a a concrete
    #          ui object, but abstracted from any one adapter.

    include Treemap::CLI::Action::InstanceMethods  # we definately are this, first

    extend Treemap::CLI::Option__::Ridiculous  # (we have to o.p hack below)

    include Adapter::InstanceMethods::Action  # `resolve_adapter`

    #         1. the mote gave your legacy pxy to the f.w

    def legacy_proxy
      @legacy_proxy ||= build_legacy_proxy
    end

    attr_reader :name  # important - override h.l! our name is dynamiic

  private

    def initialize mc, adapter_a, name_func
      init_treemap_sub_client -> { mc }
      @adapter_a, @name = adapter_a, name_func
      @ui_is_initted = nil
      nil
    end

    #         1. (continud)

    LegPxy = LIB_.proxy_lib.nice :help, :resolve do
      def respond_to? _  # :+[#057]
        true
      end
    end

    def build_legacy_proxy
      LegPxy.new(
        help:                method( :__legacy_help ),
        resolve:             method( :__legacy_resolve )
      )
    end

    #         2. the request is coming in from the front: `my-app -h my-act`

    def __legacy_help h
      if { full: true } == h
        special_help
      end
      nil
    end

    #         your help screen is composed of (in order)

    option_parser do |o|
      o.on '-a', '--adapter <NAME>',
        'adapter to use for {{nerk}} (actually required)' do |v|
        @param_h[:adapter] = v
      end
    end

    def render_option_parser_switch sw  # #hook-in to [hl] o.p rendering
      if '-a' == sw.short.first
        "#{ sw.short.first || sw.short.first }#{ sw.arg }"
      else
        super
      end
    end

    def render_nerk_for_option opt
      em slug  # ("adapter to use for "install"")
    end

    def argument_syntax  # used in `usage_and_invite`
      @arg_params ||= [[:rest, :adapter_specific_arg]]
      @argument_syntax ||= LIB_.CLI_lib.argument.syntax.isomorphic(
        @arg_params, nil )
    end

    def o  # you love it
      @o ||= -> k { option_parser.options.fetch k }
    end

    def get_desc_line_a  # compat h.l to show in its help screens
      @sections ||= nil  # etc
      y = [ ]
      a = @adapter_a.map(& :slug )
      y << "there exist#{ s a, :_s } #{ an_ slug, a }`#{ slug }` #{
        }action#{ s } for the #{ and_ a.map(& method(:em)) } plugin#{ s }."
      y
    end

    #         ~ resolution (f.w wants to defer argv to you) ~

    def __legacy_resolve argv  # (might be a good general resolve too)
      res = nil
      begin                       # check if an '-a' option was provided
        ref = o[:adapter].parse! argv
        ref and break( res = explicit ref, argv )

        if 1 == argv.length and o[:help].parse( argv )
          break special_help
        end

        special_usage_and_invite
        # res = [ method( :invoke ), [ argv ] ]
      end while nil
      res
    end

    def adapter adapter, argv
      kls = adapter.resolve_cli_action_class @name.as_slug, -> e do
        usage_and_invite e
      end
      if kls
        charged = kls.new request_client  # (probably the m.c)
        [ charged.method( :invoke ), [ argv ] ]
      end
    end

    def explicit ref, argv  # '-a' option was provided, use it
      msg = nil
      adaptr = resolve_adapter ref, -> e { msg = e ; nil }
      if adaptr
        adapter adaptr.item, argv
      else
        usage_and_invite msg
      end
    end

    def special_help
      __legacy_init_ui  # imporant - frontier expects we came in thru `invoke`
      y = help_yielder
      help_screen y
      y << ''
      y << "try #{ pre "#{ normalized_invocation_string } #{
        }#{ o[:help].rndr } #{ o[:adapter].rndr }" } #{
        }for `#{ slug }` help for that particular plugin."
      nil
    end

    def special_usage_and_invite
      opt = o[:adapter]
      s = "#{ opt.render_short } (#{ opt.render_long })#{ opt.argmnt_str }"
      usage_and_invite "#{ em slug } for which adapter? #{
        }(missing required argument: #{ em s })"
      nil
    end
  end
end
