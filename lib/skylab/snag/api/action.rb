module Skylab::Snag
  class API::Action
    extend Headless::Action::ModuleMethods
    extend Headless::NLP::EN::API_Action_Inflection_Hack
    extend MetaHell::Formal::Attribute::Definer

    include Headless::Action::InstanceMethods
    include Snag::Core::SubClient::InstanceMethods

    extend PubSub::Emitter # puts `emit` i.m lower on the chain than s.c above!

    public :emits? # for #experimental dynamic wiring per action reflection

    meta_attribute :default
    meta_attribute :required

    inflection.inflect.noun :singular

    event_class API::MyEvent

    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    def self.attributes_or_params
      res = nil
      if const_defined? :PARAMS, false
        a = const_get :PARAMS, false
        res = MetaHell::Formal::Attribute::Box[ a.map do |k|
          [ k, MetaHell::Formal::Attribute::Metadata[ required: true ] ]
        end ]
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

    def invoke param_h=nil
      res = nil
      begin
        @param_h and fail 'sanity'
        @param_h = param_h || { }
        res = absorb_params!
        res or break
        res = execute
      end while nil
      if false == res
        res = invite self         # an invite hook should happen at the
      end                         # end of invoke for 2 reasons: 1) it wraps
      res                         # execute, 2) it is hopefully at the end
    end

  protected

    def initialize api
      @nodes = nil
      @param_h = nil
      _snag_sub_client_init! api
    end

    def absorb_params!
      res = false
      begin
        formal = self.class.attributes_or_params
        extra = @param_h.keys.reduce [] do |m, k|
          m << k if ! formal.has? k
          m
        end
        if extra.length.nonzero?
          error "#{ s extra, :this } #{ s :is } not #{ s :a }#{
            }parameter#{ s }: #{ extra.join ', ' }"
          break
        end
        formal.each do |k, meta|
          if meta.has?( :default ) && @param_h[k].nil?
            @param_h[k] = meta[:default]
          end
        end
        missing = formal.each.reduce [] do |m, (k, meta)|
          m.push( k ) if meta[:required] && @param_h[k].nil?
          m
        end
        if missing.length.nonzero?
          error "missing required parameter#{ s missing }: #{
            }#{ missing.join ', ' }"
          break
        end
        @param_h.each do |k, v|
          send "#{ k }=", v
        end
        @param_h = nil
        res = true
      end while nil
      res
    end

    def build_event type, data # compat pub-sub
      API::MyEvent.new type, data do |o|
        o.inflection = self.class.inflection
      end
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
  end
end
