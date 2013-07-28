module Skylab::Headless

  # (chatty historical note: this is the first node in the skylab universe
  # ever to be [re-] written using the Three Laws of TDD. we couldn't resist
  # engaging in the exercize in light of both the growing scope of
  # responsibility for this node and the fact that we had just read martin's
  # _Clean Code_ [#sl-129]. falling under the spell of its dogma has another
  # side-effect: we (again) cut back down on method-level comments, limiting
  # them only to those methods that are part of the node's public API, if that
  # (something we used to do until the "functional period" whose start
  # roughly coincides with the birth of metahell). excessive effort has been
  # expended to make the corresponding spec for this node serve as
  # comprehensive API documentation (or at least, a source for it).)

  # (here we use "contained DSL's" [#mh-033] implemented using coduits et.
  # al [#078], API-private modules [#079]. we write in narrative pre-order
  # [#058], broken into facets [#080].)

  # ~ facet 1 - core, coarse facets, and facet management ~

  module Plugin
  end

  module Plugin::Host

    # `self.enhance` - give a ruby class the strength and agility of being
    # a host appilcation that operates with plugins.

    def self.enhance mod, &blk
      msvcs = if mod.const_defined? :Plugin_Host_Metaservices_, false
        mod.const_get :Plugin_Host_Metaservices_, false
      else
        Metaservices_.new
      end
      Conduit_.new( msvcs ).instance_exec( & blk ) if blk
      msvcs.flush mod
      nil
    end
  end

  class Plugin::Host::Conduit_
    def initialize story
      @story = story
    end
  end

  Plugin::Const_bang__ = -> mod, const_i, blk do
    if mod.const_defined? const_i, false
      mod.const_get const_i, false
    else
      mod.const_set const_i, blk.call
    end
  end

  Plugin::Const_bang_ = -> const_i, &blk do
    Plugin::Const_bang__[ self, const_i, blk ]
  end

  class Plugin::Metaservices__

    class << self
      alias_method :orig_new, :new
    end

    def self.new
      ::Class.new( self ).class_exec do
        class << self
          alias_method :new, :orig_new
        end
        self
      end
    end

    define_singleton_method :const!, & Plugin::Const_bang_

    def self.emit_meta_eventpoint method_name, *a
      if const_defined? :FACET_I_A_, false
        const_get( :FACET_I_A_, false ).each do |i|
          const_get( i, false ).send method_name, *a
        end
      end
      nil
    end

    def emit_meta_eventpoint i, host_metasvcs
      self.class.emit_meta_eventpoint i, self, host_metasvcs
    end
  end

  class Plugin::Host::Metaservices_ < Plugin::Metaservices__

    def self.flush mod
      if mod.const_defined? :Plugin_Host_Metaservices_, false
        self == mod.const_get( :Plugin_Host_Metaservices_, false ) or
          fail "sanity"
      else
        mod.const_set :Plugin_Host_Metaservices_, self
        def mod.client_can_broker_plugin_metaservices
          true
        end
      end
      mod.send :include, Plugin::Host::InstanceMethods_
      nil
    end

    def initialize host
      @host_f = -> { host }  # hack for prettier dumps
    end

    def moniker
      host.class.name
    end

  private

    def host
      @host_f.call
    end

    MAARS::Upwards[ self ]  # autoload plugin/*, plugin/host/*, p/h/msvcs_/*

  end

  module Plugin::Host::InstanceMethods_

    def attach_hot_plugin pi
      pi.receive_plugin_attachment_notification plugin_host_metaservices
      ( @hot_plugin_a ||= [ ] ) << pi
      nil
    end

    def attach_hot_plugin_with_name pi, local_normal
      attach_hot_plugin pi  # we break "thread safety" here ..
      ( @hot_plugin_h ||= { } )[ local_normal ] = @hot_plugin_a.length - 1
      nil
    end

    def attach_hot_plugin_with_name_proc pi, nf
      attach_hot_plugin_with_name pi, nf.local_normal
      pi.plugin_metaservices.set_name_proc nf
      nil
    end

    def fetch_hot_plugin_by_name local_normal
      @hot_plugin_a.fetch @hot_plugin_h.fetch( local_normal )
    end

    def plugin_host_metaservices
      @plugin_host_metaservices ||= plugin_host_metaservices_class.new self
    end

  private

    def has_hot_plugins
      false != hot_plugin_a
    end

    def hot_plugin_a
      if ! instance_variable_defined? :@hot_plugin_a
        @hot_plugin_a = false
        determine_hot_plugins
      end
      @hot_plugin_a
    end

    def determine_hot_plugins
      func, arg_x = plugin_host_metaservices.class.any_determiner_func_and_arg
      if func
        func[ self, arg_x ]
        nil
      end
    end

    def plugin_host_metaservices_class
      self.class.const_get :Plugin_Host_Metaservices_
    end

    alias_method :plugin_host_story, :plugin_host_metaservices_class
      # it is an implementation detail!
  end

  # --*--

  module Plugin

    def self.enhance mod, &blk
      cnd = Conduit_.new( fsh = Metaservices_.new )
      blk and cnd.instance_exec( & blk )
      fsh.flush mod
      nil
    end
  end

  class Plugin::Conduit_

    def initialize story
      @story = story
    end
  end

  class Plugin::Metaservices_ < Plugin::Metaservices__

    MAARS::Upwards[ self ]  # autoload ./metaservices-/*

    def self.flush mod
      mod.const_defined? :Plugin_Metaservices_, false and fail 'no'
      mod.const_set :Plugin_Metaservices_, self
      mod.extend Plugin::ModuleMethods_
      kls = RESOLVE_CLASS_H_.fetch( mod.class )[ mod ]
      emit_meta_eventpoint :receive_flush_notification, kls
      kls.send :include, Plugin::InstanceMethods_
      nil
    end

    RESOLVE_CLASS_H_ = {
      ::Class => -> kls do
        kls
      end,
      ::Module => -> mod do
        mod.extend Plugin::ModuleMethods_
        mod.const_defined? :Client, false and fail "add coverage for me"
        kls = mod.const_set :Client, ::Class.new
        if ! kls.const_defined? :Plugin_Metaservices_, false
          kls.const_set :Plugin_Metaservices_, mod::Plugin_Metaservices_
        end
        kls
      end
    }

    def initialize plugin
      @need_met_h = nil
      @plugin = plugin
    end

    attr_reader :plugin

    def moniker
      @plugin.class.name
    end

    def set_name_proc nf
      @name_function = nf
    end

    attr_reader :name_function

    def need_met_notify i
      @need_met_h ||= { }
      @need_met_h[ i ] = true
    end

    def has_already_met_need i
      @need_met_h && @need_met_h[ i ]
    end
  end

  module Plugin::ModuleMethods_

    def plugin_metaservices_class
      const_get :Plugin_Metaservices_, false
    end

    alias_method :plugin_story, :plugin_metaservices_class
      # it is an implementation detail!
  end

  module Plugin::InstanceMethods_

    def receive_plugin_attachment_notification host_metasvcs
      plugin_metaservices.
        emit_meta_eventpoint :receive_attachment_notification, host_metasvcs
    end

    def receive_plugin_eventpoint_notification ep, a, &b
      if plugin_metaservices.subscribed_to_eventpoint? ep.normal
        send ep.as_method_name, *a, &b
      end
    end

    def local_plugin_moniker
      nf = plugin_metaservices.name_function and nf.as_slug
    end

  private

    def plugin_metaservices
      @plugin_metaservices ||= self.class.
        const_get( :Plugin_Metaservices_, false ).new( self )
    end

    alias_method :plugin_metaservices, :plugin_metaservices
    public :plugin_metaservices
  end

  # (the remainder of this facet consists of
  # facilities used by the facets following this one.)

  class Plugin::Metaservices_
    class << self
      private
      def add_facet const_i
        ( const! :FACET_I_A_ do [ ] end ) << const_i
        nil
      end
    end
  end

  Plugin::Box_ = Headless::Services::Basic::Box

  class Plugin::DeclarationError < ::RuntimeError
  end

  Plugin::EAT_H_ = -> kls, h do
    h.default_proc = -> hh, k do
      raise Plugin::DeclarationError, "unexpected token #{ k.inspect }, #{
        }expecting #{ Headless::NLP::EN::Minitesimal::FUN.oxford_comma[
          hh.keys.map( & :inspect ), ' or ' ] } for #{
        }defining this #{ kls }"
    end
    h.freeze
  end

  # ~ facet 2 - services ~

  class Plugin::Host::Conduit_
    def services *x_a
      @story.concat_services x_a
    end
  end

  class Plugin::Host::Metaservices_

    def self.concat_services x_a
      x_a.each do | (name_i, *rest) |
        svc = Service_.new name_i, *rest
        services.add name_i, svc
      end
      nil
    end

    def self.services
      const! :SERVICES_ do Services_.new end
    end

    def build_proxy_for plugin_metasvcs
      self.class._proxy_class.new self, plugin_metasvcs
    end

    def self._proxy_class  # #api-private
      const! :Proxy_ do
        msvcs = self
        ::Class.new( Plugin::Host::Proxy_ ).class_exec do
          msvcs.services._a.each do |i|
            define_method i do |*a, &b|
              _call_host_service i, a, b
            end
          end
          self
        end
      end
    end

    def services
      self.class.services
    end

    def proc_for_has_service
      @_pfhs ||= services._h.method :key?
    end

    def call_service i, a=nil, b=nil
      svc = services._h.fetch i do
        raise Plugin::DeclarationError, "\"#{ i }\" has not been declared #{
          }as a service of this host (declare it with `services`?) - #{
          }#{ moniker }"
      end
      send VIA_H_.fetch( svc.via_i ), svc, *a, &b
    end

    VIA_H_ = {
      method: :fulfill_service_call_via_method,
      ivar: :fulfill_service_call_via_ivar,
      delegation: :fulfill_service_call_via_delegation,
      dispatch: :fulfill_service_call_via_dispatch
    }.freeze

  private

    def fulfill_service_call_via_method svc, *a, &b
      host.send svc.method_name, *a, &b
    end

    def fulfill_service_call_via_ivar svc
      host.instance_variable_defined? svc.via_ivar or fail "sanity - #{ svc.via_ivar } is not defined in this #{ host.class }"  # #todo-during:4
      host.instance_variable_get svc.via_ivar
    end

    def fulfill_service_call_via_delegation svc, *a, &b
      host.fetch_hot_plugin_by_name( svc.delegatee_local_normal ).
        plugin_host_metaservices.call_service svc.normal, a, b
    end

    def fulfill_service_call_via_dispatch svc, *a, &b
      host.send svc.method_name, * svc.dispatch_args_x, *a, &b
    end
  end

  class Plugin::Host::Proxy_

    def [] * i_a  # #canonical-monadic-service-aref-accessor [#074]
      if 1 == i_a.length
        _call_host_service i_a.fetch( 0 )
      else
        i_a.map { |i| _call_host_service i }
      end
    end

  private

    def initialize host_metasvcs, plugin_metasvcs
      @proc_for_has_service_used =
        ( @host_metasvcs, @plugin_metasvcs = host_metasvcs, plugin_metasvcs ).
          last.proc_for_has_service_used  # #cars-why
    end

    def _call_host_service i, a=nil, b=nil  # #a-and-b-exist-to-fail
      @proc_for_has_service_used[ i ] or
        raise Plugin::DeclarationError, "the \"#{ i }\" service must be but #{
          }was not declared as subscribed to by the #{
          }\"#{ @plugin_metasvcs.moniker }\" plugin (just add it to the #{
          }plugin's list of desired services?)."
      @host_metasvcs.call_service i, a, b
    end
  end

  class Plugin::Host::Metaservices_::Services_ < Plugin::Box_
  end

  Plugin::AT_ = -> do
    at = '@'.freeze
    -> rest do
      at == rest.fetch( 0 ).to_s[ 0 ]
    end
  end.call

  class Plugin::Host::Metaservices_::Service_

    def initialize name_i, *rest
      @normal = name_i
      rest.length.nonzero? and eat rest
      @via_i ||= begin
        @method_name = @normal
        :method
      end
    end

    attr_reader :normal, :via_i

    def method_name
      @method_name
    end

  private

    def eat rest
      while rest.length.nonzero?
        send EAT_H_[ rest.shift ], rest
      end
    end

    EAT_H_ = Plugin::EAT_H_[ self,
      ivar: :eat_ivar,
      delegatee: :eat_delegatee,
      method: :eat_method,
      dispatch: :eat_dispatch
    ]

    def eat_ivar rest
      @via_i = :ivar
      @via_ivar = if rest.length.nonzero? and at? rest
        rest.shift
      else
        :"@#{ @normal }"
      end
      nil
    end

    define_method :at?, & Plugin::AT_

    def via_ivar
      @via_ivar
    end
    public :via_ivar

    def eat_delegatee rest
      @via_i = :delegation
      @delegatee_local_normal = rest.fetch 0 ; rest.shift
      nil
    end

    def delegatee_local_normal
      @delegatee_local_normal
    end
    public :delegatee_local_normal

    def eat_method rest
      @via_i = :method
      @method_name = rest.fetch 0 ; rest.shift
      nil
    end

    def eat_dispatch rest
      @via_i = :dispatch
      @method_name = rest.fetch 0 ; rest.shift
      @dispatch_args_x = rest.fetch 0 ; rest.shift
      nil
    end

    def dispatch_args_x
      @dispatch_args_x
    end
    public :dispatch_args_x
  end

  class Plugin::Conduit_

    def services_used *x_a
      @story.concat_services_used x_a
    end
  end

  # --*--

  class Plugin::Metaservices_

    def self.concat_services_used x_a
      box = const! :SERVICES_SUBSCRIBED_TO_ do
        add_facet :SERVICES_SUBSCRIBED_TO_
        Services_Used_.new
      end
      x_a.each do | (name_i, *rest) |
        box.add name_i, Service_Used_.new( name_i, *rest )
      end
      nil
    end

    def self.services_used
      const_get :SERVICES_SUBSCRIBED_TO_, false
    end

    def services_used
      self.class.services_used
    end

    def proc_for_has_service_used
      @_pfhsu ||= services_used._h.method :key?
    end

    def absorb_metaservices_service host_metasvcs, svc
      send INTO_H_.fetch( svc.into_i ), host_metasvcs, svc
    end

    INTO_H_ = {
      instance_method: :absorb_metaservices_service_into_instance_method,
      proxy: :absorb_metaservices_service_into_proxy,
      ivar: :absorb_metaservices_service_into_ivar
    }.freeze

    def absorb_metaservices_service_into_instance_method ms, _svc
      if ! @plugin.instance_variable_defined? :@plugin_parent_metaservices
        @plugin.instance_variable_set :@plugin_parent_metaservices, ms
      end
      nil
    end

    def absorb_metaservices_service_into_proxy ms, _
      if ! @plugin.instance_variable_defined? :@plugin_parent_services
        @plugin.instance_variable_set :@plugin_parent_services,
          ms.build_proxy_for( @plugin.plugin_metaservices )
      end
      nil
    end

    def absorb_metaservices_service_into_ivar ms, svc
      @plugin.instance_variable_set svc.into_ivar,
        ( ms.call_service svc.normal )
      nil
    end
  end

  class Plugin::Metaservices_::Services_Used_ < Plugin::Box_

    def receive_flush_notification kls
      @h.each_value do |svc|
        if :instance_method == svc.into_i
          kls.send :define_method, svc.into_method do |*a, &b|
            @plugin_parent_metaservices.call_service svc.normal, a, b
          end
          kls.send :private, svc.into_method
        end
      end
      nil
    end

    def receive_attachment_notification plugin_metasvcs, host_metasvcs
      has_service = host_metasvcs.proc_for_has_service ; err = nil
      @a.each do |i|
        plugin_metasvcs.has_already_met_need( i ) and next
        if has_service[ i ]
          plugin_metasvcs.
            absorb_metaservices_service host_metasvcs, @h.fetch( i )
          next
        end
        ( err ||= Headless::Plugin::Metaservices_::Service_::Missing_.new ).
          host_lacks_service_for_plugin host_metasvcs, i, plugin_metasvcs
      end
      err and raise Plugin::DeclarationError, err.message_proc[]
      nil
    end
  end

  class Plugin::Metaservices_::Service_Used_

    def initialize name_i, *rest
      @normal = name_i
      eat rest
      @into_i ||= begin
        @into_method = name_i
        :instance_method
      end
    end

    attr_reader :normal, :into_i

    def into_method
      @into_method
    end

  private

    def eat rest
      while rest.length.nonzero?
        send EAT_H_[ rest.shift ], rest
      end
    end

    EAT_H_ = Plugin::EAT_H_[ self,
      ivar: :eat_ivar,
      method: :eat_instance_method,
      proxy: :eat_proxy
    ]

    def eat_ivar rest
      @into_i = :ivar
      @into_ivar = if rest.length.nonzero? and at? rest
        rest.shift
      else
        :"@#{ @normal }"
      end
      nil
    end

    define_method :at?, & Plugin::AT_

    def into_ivar
      @into_ivar
    end
    public :into_ivar

    def eat_instance_method rest
      @into_method = rest.fetch( 0 ) ; rest.shift
      @into_i = :instance_method
      nil
    end

    def eat_proxy _
      @into_i = :proxy
      nil
    end
  end

  # ~ facet 3 - eventpoints ~

  class Plugin::Host::Conduit_

    def eventpoints *x_a
      @story.concat_eventpoints x_a
      nil
    end
  end

  class Plugin::Host::Metaservices_ < Plugin::Metaservices__

    def self.concat_eventpoints x_a
      epts = const! :EVENTPOINTS_ do Eventpoints_.new end
      x_a.each do | (name_i, *rest_xa) |
        epts.add name_i, Eventpoint_.new( name_i, * rest_xa )
      end
      nil
    end

    def self.eventpoints
      self::EVENTPOINTS_
    end

    def self.fetch_eventpoint i
      eventpoints.fetch i do
        raise Plugin::DeclarationError, "undeclared eventpoint #{
          }\"#{ i }\" for this plugin host story. declared evenpoints are #{
          }(#{ eventpoints.get_names * ', ' })."
      end
    end

    def eventpoints
      self.class.eventpoints
    end
  end

  class Plugin::Host::Metaservices_::Eventpoints_ < Plugin::Box_
  end

  class Plugin::Host::Metaservices_::Eventpoint_

    def initialize name_i
      @normal = name_i
    end

    attr_reader :normal

    def as_method_name
      @as_method_name ||= :"receive_#{ @normal }_plugin_eventpoint"
    end
  end

  module Plugin::Host::InstanceMethods_

  private

    def emit_eventpoint name_i, *a, &b
      emit_customized_eventpoint name_i, -> _ { a }, &b
    end

    def emit_customized_eventpoint name_i, f, &b
      ep = plugin_host_metaservices_class.fetch_eventpoint name_i
      if has_hot_plugins
        @hot_plugin_a.each do |pi|
          b and bb = -> *aa do
            b[ pi, *aa ]
          end
          pi.receive_plugin_eventpoint_notification ep, f[ pi ], &bb
        end
      end
      nil
    end
  end

  # --*--

  class Plugin::Conduit_

    def eventpoints_subscribed_to * x_a
      @story.concat_eventpoints_subscribed_to x_a
    end
  end

  class Plugin::Metaservices_

    def self.concat_eventpoints_subscribed_to x_a
      box = const! :EVENTPOINTS_SUBSCRIBED_TO_ do
        add_facet :EVENTPOINTS_SUBSCRIBED_TO_
        def self.eventpoints
          const_get :EVENTPOINTS_SUBSCRIBED_TO_, false
        end
        Eventpoints_Subscribed_To_.new
      end
      x_a.each do | (name_i, *rest) |
        box.add name_i, Eventpoint_Subscribed_To_.new( name_i, *rest )
      end
      nil
    end

    def subscribed_to_eventpoint? i
      self.class.eventpoints.has? i
    end
  end

  class Plugin::Metaservices_::Eventpoints_Subscribed_To_ < Plugin::Box_

    def receive_flush_notification kls
      @a.each do |i|
        kls.send :define_singleton_method, i do |*a, &b|
          m = :"receive_#{ i }_plugin_eventpoint"
          if a.length.zero?
            define_method m, &b
          else
            b and raise DeclarationError, "can't have args and block here."
            define_method m do |&bb|
              bb[ * a ]
            end
          end
        end
      end
    end

    def receive_attachment_notification plugin, metasvcs
      if (( miss_a = @a - metasvcs.eventpoints._a )).length.nonzero?
        raise Plugin::DeclarationError, "unrecognized eventpoint(s) #{
          }subscribed to by #{ plugin.class }. declare them? - #{
          }(#{ miss_a * ', ' })"
      end
      nil
    end
  end

  class Plugin::Metaservices_::Eventpoint_Subscribed_To_

    def initialize normal_i
      @normal = normal_i
    end

    attr_reader :normal
  end

  # ~ facet 4 - determining plugins ~

  class Plugin::Host::Conduit_
    def plugin_box_module x
      @story.set_determiner :Plugins_Box_Module_, x
      nil
    end
  end

  class Plugin::Host::Metaservices_  # re-open

    def self.set_determiner i, x
      const_defined? :DETERMINER_I_, false and fail "determiner already set"
      const_set :DETERMINER_I_, i
      const_set :DETERMINER_X_, x
      nil
    end

    def self.any_determiner_func_and_arg
      if const_defined? :DETERMINER_I_, false
        [ Plugin::Determiners_.const_get(
            ( const_get :DETERMINER_I_, false ), false ),
          ( const_get :DETERMINER_X_, false ) ]
      end
    end
  end

  module Plugin::Determiners_
  end

  Plugin::Determiners_::Plugins_Box_Module_ = -> host, box_f do
    box = box_f.call
    box.constants.each do |const|
      mod = box.const_get const, false  # (below is pursuant to [#077])
      host.attach_hot_plugin_with_name_proc(
        ( ::Class == mod.class ? mod : mod.const_get( :Client, false ) ).new,
        Headless::Name::Function::From::Constant.new( const ) )
    end
  end

  # ~ facet 5 - metastory ~

  module Plugin
    METASTORY_METHOD_ = -> do
      self.class.class_exec( & Plugin::Metastory_::METHOD_ )
    end
  end

  module Plugin::InstanceMethods_
    define_method :plugin_metastory, & Plugin::METASTORY_METHOD_
  end

  module Plugin::Host::InstanceMethods_
    define_method :plugin_metastory, & Plugin::METASTORY_METHOD_
  end
end
