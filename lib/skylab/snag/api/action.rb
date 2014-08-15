module Skylab::Snag

  class API::Action               # (following [#sl-110] order)

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    extend Snag_::Lib_::NLP[]::EN::API_Action_Inflection_Hack
    inflection.inflect.noun :singular

    Snag_::Lib_::Formal_attribute[]::DSL[ self ]
    meta_attribute :default
    meta_attribute :required, default: false

    Callback_[ self, :employ_DSL_for_digraph_emitter ]  # #note-10

    event_factory Snag_::Lib_::Memoize[ -> do  # #note-15
      Callback_::Event::Factory::Isomorphic.new API::Events
    end ]


    taxonomic_streams(* Snag_::API::Events.taxonomic_streams ) # #note-20

    listeners_digraph  error: :lingual  # #note-25

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


    include Snag_::Core::SubClient::InstanceMethods

    def initialize _
      @listener = @nodes = @param_h = nil
      super
    end

    def invoke_via_iambic x_a
      h = {} ; d = 0 ; length = x_a.length
      while d < length
        h[ x_a.fetch( d ) ] = x_a.fetch( d + 1 )
        d += 2
      end
      if h.key? :listener
        @listener = h.delete :listener
        @prefix = h.delete :prefix
      end
      @param_h = h
      ok = absorb_param_h
      ok && execute
    end

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

    attr_reader :up_from_path

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
          error_string "#{ s extra, :this } #{ s :is } not #{ s :a }#{
            }parameter#{ s }: #{ extra.join ', ' }"
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
          error_string "missing required parameter#{ s missing }: #{
            }#{ missing.join ', ' }"
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

    def send_to_listener i, x
      call_digraph_listeners i, x
    end ; public :send_to_listener  # :+[#060]

    # `build_event` - we override the one we get from [cb] to pass our
    # factory 1 more parameter than usual (if e.g the event class being
    # used is "lingual" it will take linguistic metadata from us, the
    # caller).

    def build_event stream_name, pay_x
      @event_factory.call @event_stream_graph_p.call, stream_name, self, pay_x
    end

    def info_string s
      if @listener
        @listener.send :"on_#{ @prefix }_info_string", s
      else
        info s  # inorite
      end
    end

    def error_string s
      if @listener
        @listener.send :"on_#{ @prefix }_error_string", s
      else
        error msg  # inorite
      end
    end


    # ~ strictly business

    def execute
      nodes
      @nodes and if_nodes_execute
    end

    def if_nodes_execute
      @node = @nodes.fetch_node @node_ref
      @node and if_node_execute
    end

    def manifest_pathname # #gigo
      @nodes.manifest.pathname
    end

    def nodes
      @nodes ||= rslv_any_nodes
    end

    def rslv_any_nodes
      mani = request_client.find_closest_manifest up_from_path, -> msg do
        error_string msg
      end
      mani and Snag_::Models::Node.build_collection mani, self
    end
  end
end
