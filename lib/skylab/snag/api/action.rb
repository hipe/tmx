module Skylab::Snag
  class API::Action
    include Snag::Core::SubClient::InstanceMethods
    extend PubSub::Emitter

    extend Porcelain::Attribute::Definer
    extend Headless::NLP::EN::API_Action_Inflection_Hack

    meta_attribute :default
    meta_attribute :required

    inflection.inflect.noun :singular

    event_class API::MyEvent

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


    pathify = Autoloader::Inflection::FUN.pathify      # until headless BEGIN #
    pos = API.name.length + 2                                                 #

    define_singleton_method :normalized_action_name do
      fail 'fix me'
      @normalized_action_name ||= begin
        tail = name[ pos .. -1 ]
        o = tail.split( '::' ).map { |s| pathify[ s ].intern }
        o
      end
    end

    def normalized_action_name
      self.class.normalized_action_name                                       #
    end                                                  # until headless END #

    def wire! # my body is filled with rage
      yield self
      self
    end

  protected

    def initialize api
      @issues = nil
      @param_h = nil
      _snag_sub_client_init! api
    end


    def absorb_params!
      res = nil
      begin
        attrs = self.class.attributes
        attrs.each do |k, m|
          if m.key?( :default ) && ! @param_h.key?( k )
            @param_h[k] = m[:default]
          end
        end
        missing = attrs.select do |k, m|
          m[:required] && @param_h[k].nil?
        end.keys
        if ! missing.empty?
          error "missing required parameter#{
            }#{ 's' if missing.length != 1 }: #{ missing.join ', ' }"
          break( res = false )
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
      @issues.manifest.pathname
    end

    def issues
      issues = nil
      begin
        break( issues = @issues ) if @issues
        o = request_client.find_closest_manifest -> msg do
          error msg
        end
        break if ! o
        issues = Snag::Models::Node::Collection.new self, o
        @issues = issues
      end while nil
      issues
    end
  end
end
