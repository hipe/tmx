module Skylab::Snag

  CLI::Action = ::Class.new

  module CLI::Action::InstanceMethods

    Adapter = Snag_::Lib_::Porcelain__[]::Legacy::Adapter

    include Snag_::Core::SubClient::InstanceMethods

    Snag_::Lib_::CLI[]::Action[ self, :core_instance_methods ]

    #         ~ API invocation and wiring support (pre-order) ~


    # note this gets called from the m.c and modals
    def call_API local_normal_name, * x_a, & p
      if ::Hash.try_convert x_a.first
        param_h = x_a.shift
        p ||= x_a.pop
        x_a.length.zero? or raise ::ArgumentError
        invoke_API_via_name_and_h_and_p local_normal_name, param_h, p
      else
        p and raise ::ArgumentError
        action = _API_client.build_action local_normal_name
        action and action.invoke_via_iambic x_a
      end
    end

  private

    def invoke_API_via_name_and_h_and_p local_normal_name, param_h, some_p
      act = bld_wired_API_action local_normal_name, some_p
      act and begin
        res = act.invoke param_h
        if false == res           # the placement of this check here is very
          if self.class.respond_to? :name_function  # ick
            res = issue_an_invitation_to self
          else
            info invite_line
            res = nil
          end
        end
        res  # [#031]
      end
    end

    def say_must_have_proc_or_bloc a
      "must have exactly 1 proc or block (#{ a.length } for 1)"
    end

    def bld_wired_API_action normalized_action_name, wire
      action = _API_client.build_action normalized_action_name
      action and begin
        wire[ action ]
        if warn_about_unhandled_streams action
          info "For now we won't proceded until you handle the above #{
            }event(s) for #{ action.class }."
          false   # should be just nil but we want to test the gears
        else
          action
        end
      end
    end

    def _API_client
      request_client._API_client
    end ; protected :_API_client

    [ :handle_payload, :handle_info,
      :handle_error, :handle_raw_info
    ].each do |m|
      define_method m do
        request_client.send m
      end
    end

    public :handle_info, :handle_error  # #as-necessary

    # just a debugging tool (#overhead) that was several hours in
    # the making (ok days). experimentally we will result in trueish
    # if there *were* warnings, and falseish if not (just to see
    # how it reads)

    def warn_about_unhandled_streams action
      action.if_unhandled_non_taxonomic_stream_names -> missed_a do
        call_digraph_listeners :warn, "(warning, unhandled: #{ missed_a * ', ' })"
        true
      end, -> do
        false
      end
    end

    def issue_an_invitation_to live_action
      request_client.issue_an_invitation_to live_action
    end

    #         ~ randomass re-used view templates ick ~

    def invalid_node_message e
      "failed to parse line #{ e.line_number } because #{
        }#{ e.invalid_reason_string } (in #{ escape_path e.pathname })"
    end

    def node_msg_smry n
      tail = ' [..]' if n.extra_lines_count.nonzero?
      "#{ n.first_line_body }#{ tail }"
    end
  end


  class CLI::Action

    ACTIONS_ANCHOR_MODULE = -> { CLI::Actions }

    Snag_::Lib_::CLI[]::Action[ self, :DSL ]

    include CLI::Action::InstanceMethods

    extend Snag_::Lib_::NLP[]::EN::API_Action_Inflection_Hack

    inflection.inflect.noun :singular

    def initialize client
      super
      @param_h = {}
    end

    def resolve_argv argv
      [ nil, method( :invoke ), [ argv ] ]  # compat legacy
    end

    public :expression_agent

    def paystream
      request_client.paystream
    end

  private

    #         ~ common optparse options ~

    def dry_run_option o
      o.on '-n', '--dry-run', 'dry run.' do
        @param_h[:dry_run] = true
      end
    end

    def verbose_option o
      o.on '-v', '--verbose', 'verbose output.' do
        @param_h[:be_verbose] = true
      end
    end

    #         ~ some wanktastic hacks for [#030] -1, -2 etc ~

    def leaf_create_option_parser
      Snag_::CLI::Option::Parser.new
    end
  end
end
