module Skylab::Snag

  class API::Action  # read [#055]

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    extend Snag_::Lib_::NLP[]::EN::API_Action_Inflection_Hack
    inflection.inflect.noun :singular

    Snag_::Lib_::Formal_attribute[]::DSL[ self ]
    meta_attribute :default
    meta_attribute :required, default: false

    Callback_[ self, :employ_DSL_for_digraph_emitter ]  # #note-10

    event_factory -> do
      API::Event_Factory
    end  # #note-15

    class << self  # ~ minimal hand-rolled

      def attributes_or_params
        if const_defined? :PARAMS, false
          a = const_get :PARAMS, false
          _o_a = a.map { |i| [ i, { required: true } ] }
          Snag_::Lib_::Formal_attribute[]::Box[ _o_a ]
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
      @nodes = @param_h = nil
      super()
    end

    attr_reader :up_from_path

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
      res = nil
      begin
        @param_h and fail 'sanity'
        @param_h = param_h || { }
        res = absorb_param_h
        res or break
        res = execute  # false ok - pass it to modal. don't handle ui here.
      end while nil
      res
    end

  private

    def absorb_param_h            # [#hl-047] this kind of algo, sort of
      res = false
      begin
        formal = self.class.attributes_or_params
        extra = @param_h.keys.reduce [] do |m, k|
          m << k if ! formal.has? k
          m
        end
        if extra.length.nonzero?               # 1) bork on unexpected params
          send_error_string say_extra extra
          break
        end
        formal.each do |k, meta|               # 2) mutate the request h with
          ivar = :"@#{ k }"
          if meta.has?( :default ) && @param_h[k].nil?  # defaults iff nec.
            @param_h[k] = meta[:default]       # (else set the ivar to nil!!)
          elsif ! instance_variable_defined? ivar
            instance_variable_set ivar, nil
          end
        end
        missing = formal.each.reduce [] do |m, (k, meta)|  # 3) aggregate and
          if meta[:required] && @param_h[k].nil?  # then bork on required
            m << k                             # missing actual params.
          end
          m
        end
        if missing.length.nonzero?
          send_error_string say_missing missing
          break
        end
        @param_h.each do |k, v|                # 4) absorb the request params
          send "#{ k }=", v                    #    by going thru the writers
        end
        @param_h = nil
        res = true
      end while nil
      res
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

    def to_listener
      lstnr_to_digraph_proxy_class.new self
    end
    def lstnr_to_digraph_proxy_class
      self.class.listener_to_digraph_proxy_cls
    end
    class << self
      define_method :listener_to_digraph_proxy_cls, -> do
        i = :Listener_to_Digraph_Proxy___
        -> do
          if const_defined? i, false
            const_get i, false
          else
            const_set i, bld_listener_to_digraph_proxy_class
          end
        end
      end.call
    private
      def bld_listener_to_digraph_proxy_class
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
            send_to_listener i, x
          end
        end ; nil
      end
      def chnnl_i_a
        event_stream_graph._a
      end
    end

    def send_to_listener i, x
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
      @node = @nodes.fetch_node @node_ref, to_listener
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
        send_to_listener channel_i, ev_
        UNABLE_
      end
    end
    self
    end
  end
end
