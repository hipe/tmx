module Skylab::Snag
  class API::Action               # (following [#sl-110] order)
    extend Headless::Action::ModuleMethods
    include Headless::Action::InstanceMethods # before below per `emit`
    ACTIONS_ANCHOR_MODULE = -> { API::Actions }

    extend Headless::NLP::EN::API_Action_Inflection_Hack
    inflection.inflect.noun :singular

    extend MetaHell::Formal::Attribute::Definer
    meta_attribute :default
    meta_attribute :required, default: false

    extend PubSub::Emitter # puts `emit` i.m lower on the chain than s.c above!
    event_class API::MyEvent
    public :emits? # for #experimental dynamic wiring per action reflection

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

    def absorb_params!            # [#hl-047] this kind of algo, sort of
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
          if meta[:required] && @param_h[k].nil?
            m << k
          end
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
