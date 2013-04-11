module Skylab::Snag

  class CLI::Action

    ACTIONS_ANCHOR_MODULE = -> { CLI::Actions }

  end

  module CLI::Action::InstanceMethods

    Adapter = Porcelain::Legacy::Adapter

    include Snag::Core::SubClient::InstanceMethods

    include Headless::CLI::Action::InstanceMethods

  protected

    #         ~ api invocation and wiring support (pre-order) ~


    # note this gets called from the m.c and modals
    def api_invoke normalized_name, param_h, *a, &b
      { 1 => true }.fetch( ( b ? a << b : a ).length )
      act = api_build_wired_action normalized_name, a[0]
      act and begin
        res = act.invoke param_h
        if false == res           # the placement of this check here is very
          if self.class.respond_to? :name_function  # ick
            res = issue_an_invitation_to self
          else
            invite
            res = nil
          end
        end                       # particular, explained in [#031]
        res
      end
    end

    def api_build_wired_action normalized_action_name, wire
      action = api.build_action normalized_action_name
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

    def api
      request_client.send :api
    end

    [ :handle_payload, :handle_info, :handle_error,
      :handle_raw_info
    ].each do |m|
      define_method m do request_client.send m end
    end

    # just a debugging tool (#overhead) that was several hours in
    # the making (ok days). experimentally we will result in trueish
    # if there *were* warnings, and falseish if not (just to see
    # how it reads)

    def warn_about_unhandled_streams action
      action.if_unhandled_non_taxonomic_stream_names -> missed_a do
        emit :warn, "(warning, unhandled: #{ missed_a * ', ' })"
        true
      end, -> do
        false
      end
    end

    def issue_an_invitation_to live_action
      request_client.send :issue_an_invitation_to, live_action
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

    extend Headless::CLI::Action::ModuleMethods

    include CLI::Action::InstanceMethods

    extend Headless::NLP::EN::API_Action_Inflection_Hack

    inflection.inflect.noun :singular

    def resolve_argv argv
      [ nil, method( :invoke ), [ argv ] ]  # compat legacy
    end

  protected

    def initialize request_client
      super
      @param_h = { }
    end

    #         ~ common optparse options ~

    attr_reader :param_h

    def dry_run_option o
      o.on '-n', '--dry-run', 'dry run.' do
        param_h[:dry_run] = true
      end
    end

    def verbose_option o
      o.on '-v', '--verbose', 'verbose output.' do
        param_h[:be_verbose] = true
      end
    end

    #         ~ some wanktastic hacks for [#030] -1, -2 etc ~

    def leaf_create_option_parser
      Snag::CLI::Option::Parser.new
    end
  end
end
