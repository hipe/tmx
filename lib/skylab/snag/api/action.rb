module Skylab::Snag

  class API::Action               # (following [#sl-110] order)

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    extend Headless::NLP::EN::API_Action_Inflection_Hack
    inflection.inflect.noun :singular

    extend MetaHell::Formal::Attribute::Definer
    meta_attribute :default
    meta_attribute :required, default: false

    extend PubSub::Emitter  # put `emit` i.m lower on the chain than s.c above!

    event_factory MetaHell::FUN.memoize[ -> do
      PubSub::Event::Factory::Isomorphic.new API::Events # oh boy .. use the
    end ]                   # same factory instance for every action subclass
                            # instance which *should* be fine given the funda-
                            # mental supposition of isomorphic factories (see)
                            # **NOTE** see warnings there too re: coherence

    taxonomic_streams(* Snag::API::Events.taxonomic_streams )
                            # we check for unhandled even streams, but we don't
                            # care about taxonomic streams like these.

    emits error: :lingual   # probably every api action subclass should have it
                            # in its graph that it emits this (and so it does)
                            # because we emit errors in `absorb_param_h`
                            # which they all use (i think..)

    def self.attributes_or_params
      res = nil
      if const_defined? :PARAMS, false
        a = const_get :PARAMS, false
        res = MetaHell::Formal::Attribute::Box[
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

    include Snag::Core::SubClient::InstanceMethods

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

    def initialize api
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
          mf = request_client.find_closest_manifest -> msg do
            error msg
          end
          mf or break( nodes = mf )
          nodes = Snag::Models::Node::Collection.new self, mf
        end while nil
        nodes
      end
    end

    # `build_event` - we override the one we get from pub-sub to pass our
    # factory 1 more parameter than usual (if e.g the event class being
    # used is "lingual" it will take linguistic metadata from us, the
    # caller).

    def build_event stream_name, pay_x

      @event_factory.call @event_stream_graph_p.call, stream_name, self, pay_x
    end
  end
end
