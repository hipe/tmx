module Skylab::Snag

  class API::Action               # (following [#sl-110] order)

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    extend Snag_::Lib_::NLP[]::EN::API_Action_Inflection_Hack
    inflection.inflect.noun :singular

    Snag_::Lib_::Formal_attribute[]::DSL[ self ]
    meta_attribute :default
    meta_attribute :required, default: false

    Callback_[ self, :employ_DSL_for_digraph_emitter ]  # put `call_digraph_listeners` nearer on the chain than s.c above

    event_factory Snag_::Lib_::Memoize[ -> do
      Callback_::Event::Factory::Isomorphic.new API::Events # oh boy .. use the
    end ]                   # same factory instance for every action subclass
                            # instance which *should* be fine given the funda-
                            # mental supposition of isomorphic factories (see)
                            # **NOTE** see warnings there too re: coherence

    taxonomic_streams(* Snag_::API::Events.taxonomic_streams )
                            # we check for unhandled even streams, but we don't
                            # care about taxonomic streams like these.

    listeners_digraph  error: :lingual   # probably every api action subclass should have it
                            # in its graph that it listeners_digraph  this (and so it does)
                            # because we call_digraph_listeners errors in `absorb_param_h`
                            # which they all use (i think..)

    def self.attributes_or_params
      res = nil
      if const_defined? :PARAMS, false
        a = const_get :PARAMS, false
        res = Snag_::Lib_::Formal_attribute[]::Box[
          a.map { |sym| [ sym, { required: true } ] }
        ]
      else
        res = self.attributes     # (for clearer error msgs)
      end
      res
    end

    def self.params *params       # nerka derka nerka derka nerka derka
      fail 'sanity' if const_defined? :PARAMS, false
      attr_accessor( *params )
      const_set :PARAMS, params
      nil
    end

    # --*--

    include Snag_::Core::SubClient::InstanceMethods

    def invoke_via_iambic x_a
      h = {} ; d = 0 ; length = x_a.length
      while d < length
        h[ x_a.fetch( d ) ] = x_a.fetch( d + 1 )
        d += 2
      end
      @listener = h.fetch :listener ; h.delete :listener
      @prefix = h.fetch :prefix ; h.delete :prefix
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

    def initialize api
      @listener = nil
      @nodes = nil
      @param_h = nil
      super
    end

    def absorb_param_h            # [#hl-047] this kind of algo, sort of
      res = false
      begin
        formal = self.class.attributes_or_params
        extra = @param_h.keys.reduce [] do |m, k|
          m << k if ! formal.has? k
          m
        end
        if extra.length.nonzero?               # 1) bork on unexpected params
          error "#{ s extra, :this } #{ s :is } not #{ s :a }#{
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
          error "missing required parameter#{ s missing }: #{
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

    def manifest_pathname # #gigo
      @nodes.manifest.pathname
    end

    def nodes
      @nodes ||= begin
        nodes = nil
        begin
          mf = request_client.find_closest_manifest up_from_path, -> msg do
            error msg
          end
          mf or break( nodes = mf )
          nodes = Snag_::Models::Node.build_collection self, mf
        end while nil
        nodes
      end
    end

    # `build_event` - we override the one we get from [cb] to pass our
    # factory 1 more parameter than usual (if e.g the event class being
    # used is "lingual" it will take linguistic metadata from us, the
    # caller).

    def build_event stream_name, pay_x

      @event_factory.call @event_stream_graph_p.call, stream_name, self, pay_x
    end

    def error msg_s
      if @listener
        @listener.send :"on_#{ @prefix }_error_string", msg_s
      else
        super
      end
    end
  end
end
