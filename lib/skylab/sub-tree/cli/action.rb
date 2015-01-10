module Skylab::SubTree

  class CLI::Action

    extend SubTree_::Lib_::Bzn_[].name_library.name_function_proprietor_methods

    def init_for_invocation_via_services svcs
      @app_mod = SubTree_
      @infostream, @CLI_receive_pair = svcs.at :errstream, :emit_proc
      self
    end

    def invoke_via_iambic x_a
      ok = receive_iambic x_a
      ok &&= bound_call
      ok and ok.receiver.send ok.method_name, * ok.args
    end

  private

    def receive_iambic x_a
      ok = process_iambic_fully x_a
      ok &&= via_default_proc_and_is_required_normalize
      ok && normalize
    end

    def process_iambic_fully x_a
      @local_iambic = x_a
      PROCEDE_
    end

    def via_default_proc_and_is_required_normalize
      PROCEDE_
    end

    def normalize
      PROCEDE_
    end

    def bound_call
      bnd = build_corresponding_API_action
      bnd and begin
        bnd.bound_call_against_iambic_stream(
          Callback_::Iambic_Stream.via_array @local_iambic )
      end
    end

    def build_corresponding_API_action
      @API_action_class = corresponding_API_action_class
      _oes_p = -> * , & ev_p do
        _ev = ev_p[] or fail
        receive_event _ev
      end
      @API_action_class.edit_entity_directly nil, _oes_p  do
        is_API_action
      end
    end

    def corresponding_API_action_class
      SubTree_.lib_.module_lib.value_via_module_and_relative_parts(
        @app_mod::API::Actions, qualified_const_path )
    end

    def qualified_const_path
      nf  = self.class.name_function
      full = [ nf ]
      nf_ = nf
      while nf_ = nf_.parent
        full.push nf_
      end
      full.reverse!
      full.map( & :as_const )
    end

  public

    def receive_event ev  # bridge from new to old events
      if ev.ok
        receive_payload_event ev  # :+#hook-out
      elsif ev.ok.nil?
        receive_info_event ev
      else
        receive_error_event ev
      end
    end

  private

    def receive_info_event ev
      m_i = :"receive_info_#{ ev.terminal_channel_i }"
      if respond_to? m_i
        send m_i, ev
      else
        default_receive_info_event ev
      end
    end

    def default_receive_info_event ev
      send_lines ev, :info do |s|
        qualify_info_string s
      end
    end

    def receive_error_event ev
      send_lines ev, :error do |s|
        qualify_error_string s
      end
    end

    def qualify_info_string s
      did = true
      @did_info ||= begin
        did = false ; true
      end
      if did
        "..and #{ s }"
      else
        qualify_info_string_first_time s
      end
    end

    def qualify_info_string_first_time s
      v = name.as_human
      _v_ = expression_agent.calculate do
        progressive_verb v
      end
      "while #{ _v_ }, #{ s }"
    end

    def qualify_error_string s
      "won't #{ name.as_human } because #{ s }"
    end

    def name
      self.class.name_function
    end

    def send_lines ev, i, & map_p
      map_p ||= IDENTITY_
      _y = Callback_::Proxy.common :<< do |s|
        _s_ = map_p[ s ]
        @CLI_receive_pair[ i, _s_ ]
      end
      ev.render_all_lines_into_under _y, expression_agent
      ev.ok
    end

    def send_info_string s
      @CLI_receive_pair[ :info, s ]
    end

    def send_payload_string s
      @CLI_receive_pair[ :payload, s ]
    end

    def expression_agent
      @expag ||= SubTree_::Lib_::Bzn_[]::CLI.expression_agent_instance  # #open [#013]
    end
  end
end
