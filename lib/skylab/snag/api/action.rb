module Skylab::Snag

  class API::Action  # read [#055]  .. this old action class is being repalced by sibling node `Action_`

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    extend Snag_._lib.NLP::EN::API_Action_Inflection_Hack
    inflection.inflect.noun :singular

    Snag_._lib.formal_attribute::DSL[ self ]
    meta_attribute :default
    meta_attribute :required, default: false

    Callback_[ self, :employ_DSL_for_digraph_emitter ]  # #note-10

    event_factory -> do
      Event_factory__
    end  # #note-15

    Event_factory__ = -> digraph, chan_i, sender, ev  do
      ev
    end

    class << self  # ~ minimal hand-rolled

      def attributes_or_params
        if const_defined? :PARAMS, false
          a = const_get :PARAMS, false
          _o_a = a.map { |i| [ i, { required: true } ] }
          Snag_._lib.formal_attribute::Box[ _o_a ]
        else
          attributes     # (for clearer error msgs)
        end
      end

    private

      def params * i_a
        const_defined? :PARAMS, false and self._SANITY
        attr_accessor( * i_a )
        const_set :PARAMS, i_a.freeze
        nil
      end
    end

    def initialize p, _API_client
      p[ self ]
      assert_all_channels_handled
      @API_client = _API_client
      @error_count = 0
      @nodes = @param_h = nil
      super()
    end

  private
    def assert_all_channels_handled
      if_unhandled_stream_names -> missed_a do
        raise say_unhandled missed_a
      end
    end

    def say_unhandled missed_a
      "unhandled channel(s): #{ missed_a * ', ' } (#{ self.class })"
    end
  public

    def invoke param_h=nil
      @param_h = param_h || {}
      ok = absorb_param_h
      ok && execute
    end

  private

    def absorb_param_h  # :+[#hl-047] (bridge)
      @formal = self.class.attributes_or_params
      ok = bork_on_unexpected_params
      ok && mutate_param_h_with_defaults_else_set_the_ivars_to_nil
      ok &&= check_for_missing_required_params
      ok && absorb_the_request_params_into_ivars
    end

    def bork_on_unexpected_params
      xtra_a = @param_h.keys.reduce nil do |m, i|
        @formal.has? i or ( m ||= [] ).push i ; m
      end
      ! xtra_a or begin
        send_error_string say_extra xtra_a
        UNABLE_
      end
    end

    def mutate_param_h_with_defaults_else_set_the_ivars_to_nil
      @formal.each_pair do |i, prop|
        ivar = :"@#{ i }"
        if prop.has?( :default ) && @param_h[ i ].nil?
          @param_h[ i ] = prop[ :default ]
        elsif ! instance_variable_defined? ivar
          instance_variable_set ivar, nil
        end
      end
    end

    def check_for_missing_required_params
      miss_a = @formal.each_pair.reduce nil do |m, ( i, prop )|
        if prop[ :required ] && @param_h[ i ].nil?
          ( m ||= [] ).push i
        end ; m
      end
      ! miss_a or begin
        send_error_string say_missing miss_a
        UNABLE_
      end
    end

    def absorb_the_request_params_into_ivars
      befor = @error_count
      @param_h.each do |i, x|
        send :"#{ i }=", x
      end
      @param_h = nil
      befor == @error_count
    end

    def say_extra a
      expression_agent.calculate do
        "#{ s a, :this } #{ s :is } not #{ s :a }#{
          }parameter#{ s }: #{ a * ', ' }"
      end
    end

    def say_missing a
      expression_agent.calculate do
        "missing required parameter#{ s a }: #{
          }#{ a * ', ' }"
      end
    end

    def expression_agent
      API::EXPRESSION_AGENT
    end

    # ~ bridging the event gap [#note-136]

    def to_delegate
      lstnr_to_digraph_proxy_class.new self
    end
    def lstnr_to_digraph_proxy_class
      self.class.delegate_to_digraph_proxy_cls
    end
    class << self
      define_method :delegate_to_digraph_proxy_cls, -> do
        i = :Delegate_to_Digraph_Proxy___
        -> do
          if const_defined? i, false
            const_get i, false
          else
            const_set i, bld_delegate_to_digraph_proxy_class
          end
        end
      end.call
    private
      def bld_delegate_to_digraph_proxy_class
        i_a = chnnl_i_a
        ::Class.new.class_exec do
          def initialize act
            @action = act
          end
          i_a.each do |i|
            define_method :"receive_#{ i }" do |x|
              @action.call_digraph_listeners i, x
            end
          end
          self
        end
      end
    end
    public :call_digraph_listeners

    class << self
    private
      def make_sender_methods
        chnnl_i_a.each do |i|
          define_method :"send_#{ i }" do |x|
            send_to_delegate i, x
          end
        end ; nil
      end
      def chnnl_i_a
        event_stream_graph._a
      end
    end

    def send_to_delegate i, x
      call_digraph_listeners i, x
    end

    # ~ overrides

    def build_event stream_name, pay_x  # #note-195
      @event_factory.call @event_stream_graph_p.call, stream_name, self, pay_x
    end

    include module Business_Methods___

    def execute
      nodes
      @nodes and if_nodes_execute
    end

    def if_nodes_execute
      @node = @nodes.fetch_node @node_ref, to_delegate
      @node ? if_node_execute : UNABLE_  # we can't get errors back from digraph
    end

    def manifest_pathname  # #gigo
      @nodes.manifest.pathname
    end

    def nodes
      @nodes ||= prdc_nodes
    end

    def prdc_nodes
      @API_client.models.nodes.collection_for @working_dir do |ev|
        channel_i, ev_ = ev.unwrap
        send_to_delegate channel_i, ev_
        UNABLE_
      end
    end
    self
    end
  end
end
