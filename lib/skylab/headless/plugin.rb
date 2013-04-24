module Skylab::Headless

  module Plugin

    # (this whole sub-library experimentally has its own issue namespace,
    # as a subnode whose root is at [#hl-070].)

    # (name conventions throughout in this file: modules ending with an
    # `Underscore_` are api private - that is, knowledge of their shape
    # or existence should not in theory be necessary outside of this
    # library.)

  end

  module Plugin::Host

    # `Plugin::Host` is just a namespsce module, but it wraps the main
    # entrypoint to the whole library - `Plugin::Host.enhance`, which gives
    # a ruby class the strength and agility of being a host application that
    # operates with plugins.

    # `enhance` (is sticking with a nascent pattern - we tried other names:
    # `confer`, `bestow`, `declare`, `define`, `extend_to` ..)
    # (#todo a unit test that display a normative example.)

    def self.enhance host_mod, &blk
      _enhance host_mod, -> do
        Plugin::Host::Story.new host_mod
      end, nil, Conduit_.new, blk
    end

    # `_enhance` - quietly expose the ever living life out of it for hacks
    # yes this could stand to be cleaned up. and no it is not used outside
    # of this library OOPS

    def self._enhance host_mod, build_story, sty, cnd, define
      if ! host_mod.const_defined? :Plugin, false
        host_mod.const_set :Plugin, ::Module.new
      end
      story = if host_mod::Plugin.const_defined? :STORY_, false
        host_mod::Plugin::STORY_
      else
        host_mod::Plugin::const_set :STORY_, build_story[]
      end
      sty and sty[ story ]
      dslify_svc_a = nil
      cnd.instance_variable_set :@h, ::Hash[ Conduit_::A_.zip( [
        -> m { story.add_available_plugins_box_module m },
        -> *a { story.add_ordinary_eventpoints a },
        -> *a { story.add_fuzzy_ordered_aggregation_eventpoints a },
        -> *a { story.add_services a },
        -> *a do
          ( dslify_svc_a ||= [ ] ).concat a.flatten
          story.add_services a
        end,
        -> i, a { story.services_delegated_to i, a }
      ] ) ]

      host_mod.send :include, Plugin::Host::InstanceMethods  # consider order

      cnd.instance_exec( & define ) if define  # allow empty blocks

      if dslify_svc_a
        dslify_svc_a.each do |i|
          host_mod.define_singleton_method i do | & def_blk |
            define_method i, & def_blk
          end
        end
      end

      nil
    end

    Conduit_ = MetaHell::Enhance::Conduit.raw %i|
      add_plugins_box_module
      eventpoints
      fuzzy_ordered_aggregation_eventpoint
      services
      services_dslified
      services_delegated_to
    |
    class Conduit_
      alias_method :plugin_box_module, :add_plugins_box_module  # #experimental
    end
  end

  #         ~ a quick note about Stories and Conduits ~
  #
  # in several places here we make use of these two constructs, so they
  # bear some explanation - A Conduit object is a short-lived object passed
  # to a "contained DSL" block. it's only purpose is to be a conduit
  # of information from the (developer) client to this library. You can
  # think of it as a method signature to a function call. (Conduit's
  # earliest recognizable ancestor was called "Joystick".)
  #
  # the Story, on the other end, is the model of the information gathered
  # during that DSL block from the conduit. The story object is the internal
  # datastructure that keeps track of whatever client-specific customizations
  # happened during the DSL block. (we have also called this 'Metadata'
  # elsewhere. you can safely substitute this term anywhere you see "Story"
  # if you prefer it.)
  #
  # unlike the Conduit, the Story is not (or should not) be thought of as
  # mutable - hence it does not need to concern itself with maintaining an
  # interface for being edited (* at least not as far as you know).
  #
  # conversely, Conduit's only job is to be written to, so it need not
  # concern itself about maintaining any protected methods or complex
  # internal state that must be encapsulated.
  #
  # the separation between Story and Conduit is important - it gives us a
  # separation of concerns, and a layer of insulation. The Conduit classes
  # effectively constitute the public API of this library (and is ironically
  # an api private class .. #todo)
  #
  # the separation between Story and the client (user developer) classes
  # is also important - it externalizes our storage of data so we don't crowd
  # the ivar namespace, as well as externalizing any support method needed
  # for (ideally read-only) methods (e.g reflection methods), which in
  # a plugin architecture, are just about the most important thing! ^_^
  #
  class Plugin::Story  # (re-opened below)
  end

  Plugin::Story::FUN = -> do  # functions used by stories

    o = { }

    o[:_add] = -> aa, h, a, builder=nil do
      a = a[0] if 1 == a.length and a[0].respond_to? :each_index # allow 2 forms
      if builder
        a.each do |i|
          x = builder[ i ]
          if h.key? i
            xx = h.fetch i
            if true != xx
              fail "merge not yet implemented for #{ x.class }"
            end
          end
          h[ i ] = x
          aa << i
        end
      else
        a.each do |i|
          h.fetch i do
            h[ i ] = true
            aa << i
          end
        end
      end
      nil
    end

    ::Struct.new( * o.keys ).new( * o.values )
  end.call

  class Plugin::Host::Story

    # all metadata for the plugin host application at compiletime.

    # ( experimentally we are ordering the below methods as grouped by per-axis,
    # writers then readers. but note that mutability is very much in flux
    # for stories. )

    def add_available_plugins_box_module mod
      @available_plugins_box_a << [ :module_ref, mod ]
      mod
    end

    def available_plugin_box_modules
      ::Enumerator.new do |y|
        @available_plugins_box_a.each do | type, x |
          if :module_ref == type  # future
            if x.respond_to? :call
              y << x.call
            else
              y << x
            end
          end
        end
      end
    end

    def add_ordinary_eventpoints a
      add_eventpoints a
    end

    def add_fuzzy_ordered_aggregation_eventpoints a
      add_eventpoints a, :is_fuzzy, :is_ordered, :is_aggregation
    end

    # `add_eventpoints` - and related (including readers)

    def add_eventpoints a, *predicate_a
      _add @eventpoint_a, @eventpoint_h, a, -> sym do
        Plugin::Event::Point[ sym, *predicate_a ]
      end
      nil
    end
    protected :add_eventpoints

    define_method :_add, & Plugin::Story::FUN._add

    def all_eventpoint_names
      @eventpoint_a.dup  # callers can't guarantee that they won't mutate it
    end

    def fetch_eventpoint x, &b
      if b
        @eventpoint_h.fetch x, &b
      else
        @eventpoint_h.fetch x do
          raise Plugin::Event::Point::NameError, "undeclared eventpoint - #{ x}"
        end
      end
    end  # is it better? [#bm-001]

    # `add_services` and related (including readers)

    def add_services a
      _add @service_a, @service_h, a, -> i do
        Plugin::Host::Service_[ i ]
      end
    end

    def services_delegated_to sym, a
      _add @service_a, @service_h, a, -> i do
        Plugin::Host::Service_[ i, sym ]
      end
    end

    # `all_service_names` - used to generate host proxies

    def all_service_names
      @service_a.dup
    end

    class Plugin::Host::Service_
      class << self
        alias_method :[], :new
      end
      attr_reader :normalized_local_name, :delegates_to, :is_a_delegation
      def initialize i, d=nil
        if d
          @delegates_to = d
          @is_a_delegation = true
        end
        @normalized_local_name = i
      end
    end

    def has_service? svc
      @service_h.key? svc
    end

    def if_service svc, yes, no
      ok = true
      res = @service_h.fetch svc do ok = false end
      if ok then yes[ res ] else no[ ] end
    end

    # (note very little of the story is internal. it is essentially a data
    # conduit.)

    def initialize host_module
      @host_module = host_module
      @available_plugins_box_a = [ ]
      @eventpoint_a = [ ] ; @eventpoint_h = { }
      @service_a = [ ] ; @service_h = { }
    end
  end

  module Plugin::Event
  end

  class Plugin::Event::Point

    # (see note at Plugin::Host::InstanceMethods#emit_eventpoint about
    # the eventpoint architecture)

    class << self
      alias_method :[], :new
    end

    attr_reader :name, :is_fuzzy, :is_ordered, :is_aggregation,
      :as_method_name

    -> do  # `initialize`

      ivar_h = ::Hash[ %i| fuzzy ordered aggregation |.map do |i|
        [ "is_#{ i }".intern, "@is_#{ i }".intern ]
      end ]

      define_method :initialize do |name, * predicate_a|
        @name = name
        predicate_a.each { |p| instance_variable_set ivar_h.fetch( p ), true }
        @as_method_name = "#{ name }_eventpoint".intern
      end
    end.call
  end

  module Plugin::Host::InstanceMethods

    # this I.M module tries to add adds as few public methods as
    # is necessary - whether you as a host
    # application want to expose your plugin API as part of your own API
    # is your business but it sounds strange and so is not the default
    # behavior. (exceptions to this will be noted with comments - some
    # of the instances of support classes will need to call some methods
    # that this module adds, or otherwise route calls through this host
    # application for ease of customizing behavior..)

  protected

    def is_plugin_host
      true
    end

    # `emit_eventpoint` - note we want to keep the signature lithe and
    # minimal here. if plugins need more information about the event
    # they should query the state of the host application via services
    # (#experimental!)
    #
    # One thing this gains us is simplicity of implementation. we can
    # litter our host application class with eventpoints and nobody cares.
    # Another thing is efficiency - if we don't have to build a metadata
    # payload about the eventpoint in situ, then we didn't waste those
    # resources in the case where nobody is listening.
    #
    # (the flipside of this, of course, is that we have to be careful
    # to make adequate plugin services etc..)
    #
    # But what if i told you "just kidding, maybe we *do* want to have
    # an argument payload come along with evenpoints -- that's not so bad,
    # is it?"? So, the takeaway is: we have no idea what we are doing.

    def emit_eventpoint name_symbol, *a, &b
      plugin_manager.emit_eventpoint name_symbol, a, &b
    end

    # `emit_eventpoint_to_each_client` see downstream.

    def emit_eventpoint_to_each_client i, &block
      plugin_manager.emit_eventpoint_to_each_client i, block
    end

    # `plugin_manager` - central interface point (as an external object)
    # for the host application to notify the plugins e.g of eventpoints.
    # lazy-loaded the first time it is used, in case the application is
    # shortlived and does not need to load (all) its plugins to fulfill its
    # particular request.

    def plugin_manager
      @plugin_manager ||= Plugin::Manager.load_for_host_application self
    end

    # `plugin_services` - ( host i.m edition ) exposed for hacking, only
    # called outside of this library.

    def plugin_services
      plugin_manager.plugin_services
    end
    public :plugin_services

    # `plugin_host_story` - will be called by the plugin manager once
    # when it inits. is a hookpoint for possible future hackery.

    def plugin_host_story

      # (note we need to search superclasses here because of some
      # headless architectures that define a core app and then modailiy
      # apps that subclass it.)

      self.class.const_get( :Plugin ).const_get( :STORY_, false )
    end
    public :plugin_host_story  # called by plugin manager

    # `plugin_host_proxy_aref` - route calls for `host[]` from plugins
    # thru the host application in case it wants to customize the behavior.
    # the default behavior is: if one argument, call the service named by
    # the argument with no arguments or block and our result is its result.
    #
    # otherwise, if not 1 argument, result is always an array of the same
    # length as the number of arguments, with each element corresponding
    # to the result of that service call (goofy sugar).
    #
    # (details:  calls come from host services. the name `aref` is borrowd from
    # the ruby source as the way they say `[]`, but what does "aref" mean?)

    def plugin_host_proxy_aref i_a, plugin_story
      if 1 == i_a.length
        @plugin_manager.plugin_services.call_host_service plugin_story,
          i_a.fetch( 0 )
      else
        m = [ ] ; svc = @plugin_manager.plugin_services
        # frame-free reduce (tail-call recursion ha) saves 1 frame :/
        while i_a.length.nonzero?
          m << svc.call_host_service( plugin_story, i_a.shift )
        end
        m
      end
    end
    public :plugin_host_proxy_aref  # called by host services

    def plugin_flatten ea, &block
      eac = ::Enumerator.new do |y|
        ea.each do |x_a, client|
          x_a.each do |rest|
            y.yield( *rest, client )
          end
        end
      end
      if block
        eac.each( & block )
      else
        eac
      end
    end

    # `plugin_flatten_and_sort` - experimental useful thing.
    # might become a function. this promises to iterate over the enumerable.
    # `item` must respond to `[]` and will be passed the flattened data
    # for each item, including the plugin. its result will be what makes up
    # your result.

    def plugin_flatten_and_sort ea, func=nil, &block
      func && block and raise ::ArgumentError, "too much proc (2 for (1..2))"
      id = 0 ; count_no_priority = 0 ; no_priority_base = - 0.1
      pri_h = { } ; raw_a = [ ] ; raw_h = { } ; nam_h = { } ; cli_h = { }
      ea.each do |item_a, client|
        item_a.each do |name, priority, *rest|
          id += 1
          if ! ( 0.0 < priority && priority < 1.0 )   # limit & normalize
            priority = ( count_no_priority += 1 ) * no_priority_base
          end
          pri_h[ id ] = priority
          raw_a << id
          raw_h[ id ] = [ *rest, name, client, priority ]
          if name
            cli_h[ id ] = client
            taken_by = nam_h.fetch( name ) do
              nam_h[ name ] = id
              nil
            end
            if taken_by
              raise Plugin::RuntimeError, "plugin comprehension sorting #{
                }conflict - name conflict with #{ name } from #{
                }both #{ cli_h[ taken_by ].plugin_slug } #{
                }and #{ client.plugin_slug }"
            end
          end
        end
      end
      raw_a.sort_by!( & pri_h.method( :fetch ) )
      ea = ::Enumerator.new do |y| # WATCHOUT clobber original `ea`
        if func
          raw_a.each do |ident|
            y << func[ * raw_h.fetch( ident ) ]
          end
        else
          raw_a.each do |ident|
            y.yield( * raw_h.fetch( ident ) )  # structs don't survive this
          end
        end
      end
      if func
        ea.to_a
      elsif block
        ea.each( & block )
      else
        ea
      end
    end

    # ( sadly this is actually the host application validating the
    # client application. also it is just a debugging feature. )
    def plugin_validate_client client, &b
      @plugin_manager.validate_client client, &b
    end

    # `call_plugin_host_service` - called by host services,
    # assume that access has already been checked.

    def call_plugin_host_service svc_i, a, b
      send svc_i, *a, &b
    end
    public :call_plugin_host_service

    # `call_delegated_plugin_service` - this extension-like thing we
    # keep talking about. called from host services. if you look at the
    # wikipedia illustration and follow an arrow, imagine this going
    # up from a plugin thru the host proxy into the service and then
    # into the host app which sends the request thru the plugin manager
    # back down to another plugin, and then all the way back out again!
    # #experimental.

    def call_delegated_plugin_service plugin_instance_key, service_name, a, b
      @plugin_manager.fetch_client( plugin_instance_key ).
        call_plugin_service( service_name, a, b )  # validates name
    end
    public :call_delegated_plugin_service  # called by host services
  end

  class Plugin::Manager

    # based off of a drawing we saw on wikipedia

    def self.load_for_host_application host_application
      pm = new host_application
      pm.init && pm.load_plugins  # NOTE result is `pm` (or ..)
    end

    def initialize host_application
      @host_application = host_application
      @a = [ ] ; @h = { }  # the plugin manager is a box.
    end

    # `init` - called by a module method in this selfsame class (or elsewhere)
    # in a separate step from our `initialize` call (possibly giving the
    # host application time to think), we memoize the story, which will be
    # used a lot here. for now we always succeed, but result is a success
    # boolean for future-proofing.

    def init
      @story = @host_application.plugin_host_story
      true
    end

    # `load_plugins` - this is only to be called from a module method in this
    # selfsame class. result must be self on success, or falseish on failure.
    # It is the thing that resolves and initializes a hot Client instance of
    # each plugin.

    def load_plugins
      svcs = plugin_services
      eventpoints = all_eventpoint_names
      available_plugin_modules.each do |box_mod|
        story = box_mod.plugin_story
        client = story.plugin_client_class.new  # pursuant to #api-point [#002]
        client = client.load_plugin story, svcs  # give the client a chance etc
        story = client.plugin_story  # give the client a chance to change class
        sym = story.normalized_local_name
        @h.key? sym and fail "sanity: load same plugin more than once? - #{sym}"
        a = client.plugin_eventpoints - eventpoints
        a.length.nonzero? and raise Plugin::DeclarationError, "unrecognized #{
          }eventpoint(s) subscribed to by \"#{ sym }\" #{
          }plugin (declare it/them?) - #{ a }"
        @a << sym
        @h[ sym ] = client
      end
      self
    end

    # `plugin_services` ( plugin manager edition )
    # called internally from `load_plugins` - an interface object which
    # facilitates communication from plugin to host application.
    # (based off of a drawing we saw on wikipedia)

    def plugin_services
      @plugin_services ||= Plugin::Host::Services.new @host_application
    end
    public :plugin_services  # exposed for hacking, also may be called from host

    # `available_plugin_modules`
    # TL;DR: the result is an enumeration of all the available plugins Modules.
    # Details: in a world where every plugin is wrapped in its own (ruby)
    # module (or more interestingly, referenced by a constant, that perhaps
    # resides in a plugins box module) - given that there might be multiple
    # plugin box modules for e.g (plugin collections, plugin sources, whatever),
    # this function's result is an enumerator that iterates over a *flat*
    # list of all the (ruby) modules of those boxes.

    def available_plugin_modules
      ::Enumerator.new do |y|
        @story.available_plugin_box_modules.each do |box_mod|
          box_mod.constants.each do |const|
            y << box_mod.const_get( const, false )
          end
        end
        nil
      end
    end
    protected :available_plugin_modules

    #         ~ eventpoint-related stuff happens to happen here ~

    def all_eventpoint_names
      @story.all_eventpoint_names
    end
    protected :all_eventpoint_names

    # `emit_eventpoint` - a sacred cow flagship workhorse
    # if block is given, it will receive an enumerator of the non-nil
    # responses from the plugins receiving the eventpoint notification.
    # NOTE - if you use the block from and don't iterate over the resultset,
    # the plugins don't get notified!
    # if no block given, each subscribed plugin will get notified of the
    # event, but result is undefined.

    def emit_eventpoint sym, a, &block
      ep = fetch_eventpoint sym  # raises custom exception
      ea = ::Enumerator.new do |y|
        hot_plugins.each do |client|
          res = client.plugin_eventpoint ep, a
          if ! res.nil?
            y.yield( res, client )   # don't flatten res here
          end
        end
        nil
      end
      if block
        block[ ea ]
      else
        ea.count # runs the enumerator - result is shh
      end
    end

    # `emit_eventpoint_to_each_client` - compare to the above method,
    # this form is for when you want to customize either the
    # client's arguments (don't) or response based on the individual client.
    # note they grey area of redundancy with above.
    #
    # the normative example is decorating each response from a plugin
    # with the slug (name) of the plugin, for e.g. but NOTE watch for
    # smells here. the host application should not hav detailed knowlege
    # of the plugins!
    #
    # this form does not provide enumerators nor capture responses from
    # client (yet) although leave room for the signature of this method
    # to expand for something like that..
    #

    def emit_eventpoint_to_each_client i, f
      ep = fetch_eventpoint i  # raises custom exception
      count = 0
      hot_plugins.each do |client|
        if client.plugin_subscribed? i  # with the cost of calling this twice
          # per client, we get the benefit of calling `f` only when necessary.
          a = * f[ client ]  # ERMAHGERD
          client.plugin_eventpoint ep, a  # RESULT IGNORED NOTE
          count += 1
        end
      end
      count
    end

    # `fetch_eventpoint` - used internally and used by client hacks

    def fetch_eventpoint sym, &b
      @story.fetch_eventpoint sym, &b
    end
    # public.

    # `hot_plugins` - a placeholder for etc ([#001])
    # within the library it is only called from above (for now)
    # but we expose it as public for hacks.

    def hot_plugins
      ::Enumerator.new do |y|
        @a.each do |norm_name|
          y << ( @h.fetch norm_name )
        end
      end
    end

    # `validate_client` - experimental & for debugging

    def validate_client client, &err
      miss_a = client.plugin_story.service_a.reduce [] do |m, svc|
        m << svc if ! @story.has_service? svc
        m
      end
      if miss_a.length.zero? then true else
        err ||= -> msg { raise msg }
        err[ "#{ @host_application.class } has not declared these #{
          }services requested by #{ client.class } - #{ miss_a * ', ' }" ]
      end
    end

    #  `fetch_client` - experimental - not for normal invocation. for hacks
    # where the host application wants to request a plugin client
    # by name.

    def fetch_client sym
      @h.fetch sym
    end
  end

  class Plugin::Host::Services

    # `Plugin::Host::Services` - the idea for this is from a drawing that
    # that we saw on wikipedia. it constitues _the_ interface that each
    # and every plugin will go through to talk to the host application.
    #
    # By default plugin clients will get a handle on a host proxy,
    # and not this services instance. but under the hood calls to the proxy
    # will all end up as calls to this, which can be thought of as
    # a middleman controller-ish between the host proxy and the actual
    # host. We keep it around because the host proxy has a necessarily
    # restricted method namespace, so we aren't going to go adding logic
    # there; and we don't want to clutter the instance method namespace
    # of the actual host application with our willy nilly logic, which
    # hence lives here.
    #
    # for now to keep things simple, by default we give the plugin clients
    # only a host proxy. but if she needs it, the industrious plugin client
    # can override `load_plugin` to hold on to a handle on this (however,
    # plugin clients should only ever be interacting with the host through
    # the host services, which all should be exposed by the proxy, so they
    # should never need a handle on these services, so ignore that i said
    # that.)

    # `build_host_proxy` - the client calls this in `load_plugin`.
    # this is how the plugin client typically accesses host services.

    def build_host_proxy plugin_client
      host_proxy_class.new plugin_client.plugin_story, @host_application, self
    end

  private

    # NOTE we either will or won't stabilize the choice between these
    # two or more alternatives when it comes to the proxy class(es) that
    # we by default build - 1) once per host application (class) we generate
    # one proxy class, and somehow use instances of it per plugin client
    # and still enforce the declared services the plugin says it needs
    # 2) we enforce this de-facto by generating one proxy class **per
    # plugin**..
    #
    # We will go with the former for now, but note that we might one
    # one day make a custom proxy class per plugin story based on the
    # services it declares it needs access to, rather than checking at
    # runtime as we do below! that's why this is whole schlew is private
    # for now (that's not a word)..
    #
    # (one benefit of the former is that we get more helpful error messages
    # when we have an access error. on the other hand, the latter wouldn't
    # be so bad when you look at how we are doing it anyway below..)

    def host_proxy_class
      @host_proxy_class ||= resolve_host_proxy_class
    end

    # `resolve_host_proxy_class` - see upstream comments
    # here, would you like `Plugin::Host_Proxy` to be defined right inside
    # of your host class?

    def resolve_host_proxy_class
      if @host_mod::Plugin.const_defined? :Host_Proxy, false
        @host_mod::Plugin.const_get :Host_Proxy, false
      else
        @host_mod::Plugin.const_set :Host_Proxy, build_host_proxy_class
      end
    end

    # `build_host_proxy_class` - see upstream comments

    def build_host_proxy_class

      # let's lock the above list down as to mean only those services
      # that exist the at the time we generate this class .. we aren't
      # so fancy as yet that we have a dynamic list of services. that
      # sounds like a terrible idea.

      service_name_a = @story.all_service_names

      # ( made more dynamic than necessary for one purpose as an exercize )
      # #todo we should look into how wasteful it is, however

      ::Class.new.class_exec do
        define_method :initialize do |pstory, ha, svc|
          define_singleton_method :[] do |*i_a|
            ha.plugin_host_proxy_aref i_a, pstory
          end
          service_name_a.each do |i|
            define_singleton_method i do |*a, &b|
              svc.call_host_service pstory, i, a, b
            end
          end
        end
        self
      end
    end

  public

    # `call_host_service` - this is expected normally to be called
    # from host proxies but here you can have it if you want.

    def call_host_service pstory, service_i, a=nil, b=nil
      svc = @story.if_service service_i, -> sv { svc = sv }, -> do
        raise Plugin::Service::NameError, "what service are you #{
          }talking about willis - #{ service_i }"
      end
      if svc
        # what would be neat is rather than doing this at runtime,
        # make the instance methods dynamically (at plugin load time)
        # that raise the same errors ERMAGHERD
        # on the flippy, this approach allows for (GULP) dynamically
        # changing what services are registered, or some even just
        # a shotgun whitelist.
        if pstory.registered_for_service? service_i
          if svc.is_a_delegation
            @host_application.call_delegated_plugin_service svc.delegates_to,
              svc.normalized_local_name, a, b
          else
            @host_application.call_plugin_host_service service_i, a, b
            # (note the confusing name change because we like to keep
            # "plugin" in the name of application code i.m's)
          end
        else
          raise Plugin::Service::AccessError, "the \"#{ service_i }\" #{
            }service must be but was not registered for by the #{
            }\"#{ pstory.local_slug }\" plugin (just add it to the #{
            }plugin's list of desired services?)."
        end
      end
    end

    def initialize host_application   # assumes `Plugin` sub-mod of its class
      @host_mod = host_application.class
      @host_application = host_application
      @story = host_application.plugin_host_story
    end
  end


  module Plugin

    def self.[] particular_plugin_box_mod
      enhance particular_plugin_box_mod do end
      particular_plugin_box_mod  # allow nesting of different [ ] calls
    end

    def self.enhance particular_plugin_box_mod, &defn
      _enhance particular_plugin_box_mod, -> do
        Plugin::Story.new( particular_plugin_box_mod )
      end, nil, Conduit_.new, defn
    end

    # `_enhance` - experiments

    def self._enhance particular_plugin_box_mod, bld_sty, sty, cnd, def_blk

      story = if particular_plugin_box_mod.const_defined? :STORY_, false
        particular_plugin_box_mod.const_get :STORY_, false
      else
        particular_plugin_box_mod.const_set :STORY_, bld_sty[]
      end
      sty and sty[ story ]

      cnd.instance_variable_set :@h, ::Hash[ Conduit_::A_.zip( [
        -> client_class_function do
          story.set_client_class_function client_class_function
        end, -> *eventpoints do
          story.add_eventpoints eventpoints
        end, -> do # `dslify_eventpoint_names`
          story.do_dslify_eventpoint_names = true
        end, -> *services do
          story.add_services services
        end, -> *plugin_service_i_a do
          story.add_plugin_services plugin_service_i_a
        end
      ] ) ]

      flush = -> do

        # now, kick the plugin client class - users will have had a chance to
        # override this by now. but typically what happens next is they re-open
        # the client class and it is convenient to have it auto-vivified first
        # with the appropriate base class and I.M's (the default behavior).

        story.plugin_client_class  # kick
      end

      particular_plugin_box_mod.extend Plugin::ModuleMethods

      if def_blk
        cnd.instance_exec( & def_blk )
        flush[ ]
        nil
      else
        cnd.class::One_Shot_.new cnd, flush
      end
    end

    Conduit_ = MetaHell::Enhance::Conduit.raw %i|
      client_class
      eventpoints
      dslify_eventpoint_names
      services
      plugin_services
    |
  end

  class Plugin::Story

    # experimentally, we present the below public methods grouped by
    # logical aspect (any writer then any reader for each aspect).
    # but note that the mutability of the story is a design consideration
    # that is in flux!

    attr_reader :normalized_local_name  # set during construction

    def local_slug
      @local_slug ||= normalized_local_name.to_s
    end

    # `client_class` (writer, reader)

    def set_client_class_function f
      @client_class_function and raise Plugin::DeclarationError, "won't #{
        }clobber existing client class function."
      f.respond_to? :call or raise Plugin::DeclarationError, "sorry, for #{
        }now we only support functions here (had: #{ f })"
      @client_class_function = f
    end

    def plugin_client_class
      @client_class_function.call
    end

    # `dslify_eventpoint_names` (writer, reader)

    attr_accessor :do_dslify_eventpoint_names

    # eventpoints-related methods - `add_eventpoints`, `subscribed?`, [..]

    def add_eventpoints a
      _add @eventpoint_a, @eventpoint_h, a
    end

    define_method :_add, & Plugin::Story::FUN._add

    def subscribed? eventpoint_name_sym
      @eventpoint_h[ eventpoint_name_sym ]
    end

    def plugin_eventpoints
      @eventpoint_a.dup  # no guarantee that client won't mutate.
    end

    # services-related methods

    def add_services a
      _add @service_a, @service_h, a
    end

    def service_a
      @service_a.dup  # a conspiring pluing manager might accidentally mutate
    end

    # `registered_for_service?` - used for interface validation at runtime

    def registered_for_service? i
      @service_h.key? i
    end

    # experimental plugin-services (like extensions uh-oh)

    def add_plugin_services a
      _add @plugin_service_a, @plugin_service_h, a
    end

    def has_plugin_service? i
      @plugin_service_h.key? i
    end

  protected

    def initialize particular_plugin_box_module
      @do_dslify_eventpoint_names = true  # experimental!
      @particular_plugin_box_module = particular_plugin_box_module
      @client_class_function = -> do
        default_client_class
      end
      @normalized_local_name = -> do
        # ::Foo::Bar::BiffBaz -> :"biff-baz"
        name = particular_plugin_box_module.name
        ::Skylab::Autoloader::Inflection::FUN.pathify[
          name[ name.rindex( ':' ) + 1 .. -1 ]
        ].intern
      end.call
      @eventpoint_a = [ ] ; @eventpoint_h = { }
      @service_a = [ ] ; @service_h = { }
      @plugin_service_a = [ ] ; @plugin_service_h = { }
    end

    # `default_client_class` - NOTE this has side-effects on the particular
    # box module (which can be avoided..). this is the default implementation
    # for @client_class_function - its job is to resolve the client class for
    # the plugin (every plugin has to have one). a plugin implementor
    # can in theory write any arbitrary client class she wants for the
    # particular plugin, and set it with `client_class` in the DSL block.
    # However this is not yet tested (#todo) and would at least require
    # that she include Plugin::Client::InstanceMethods, or worse (strongly
    # discoured) implement every method in it (just don't do it).
    #
    # Most often what happens is that this below function runs, creates
    # a plugin client class by subclassing our internal stub class,
    # and then she (the developer) re-opens it and writes the actual
    # application code in the plugin.
    #
    # Experimentally the particular plugin box module and the plugin
    # client class can be one and the same .. this happens if you call
    # `Plugin.enhance` on a class instead of a module. It assumes that the
    # class *is* the implementation for the plugin - and will probably
    # mutate the hell out of it..

    def default_client_class
      if @particular_plugin_box_module.const_defined? :Client, false
        @particular_plugin_box_module.const_get :Client, false
      else  # ( no matter what, set Client constant. )
        if ::Class === @particular_plugin_box_module
          kls = @particular_plugin_box_module
          if ! kls.method_defined? :plugin_story
            kls.send :include, Plugin::Client::InstanceMethods
          end
          use_dsl = @do_dslify_eventpoint_names  # ..
        else
          kls = ::Class.new  # NOTE we used to sublcass a base class here, but
          kls.send :include, Plugin::Client::InstanceMethods  # ..no reason to
          use_dsl = @do_dslify_eventpoint_names  # yes always
        end

        @particular_plugin_box_module.const_set :Client, kls  # yes always

        # (yes for the one case this sets Foo::Client = Foo. When dealing
        # with constants like modules and classes we like to use the modules
        # themselves as the datstore, as opposed to hashes or ivars)

        if use_dsl
          eventpoint_dsl kls
        end
        kls
      end
    end

    def eventpoint_dsl kls
      ea = @eventpoint_a
      kls.class_exec do
        ea.each do |i|
          define_singleton_method i do |*a, &b|
            x = a.length + ( b ? 1 : 0 )
            x > 1 and raise ::ArgumentError, "too many (#{ x } for 0..1)"
            m = "#{ i }_eventpoint"
            if b
              define_method m, &b
            else
              res = a[ 0 ]  # LOOK nil ok
              define_method m do res end
            end
          end
        end
      end
      nil
    end
  end

  module Plugin::Client

    # `Plugin::Client` - the plugin itself is an abstract floaty etheral
    # thing. The way that the plugin manager talks to a plugin (the floaty
    # thing) is through the plugin's client. how can you capture a rainbow?

    # (this used to be a default base class, but then there was
    # no reason to use it b.c everything moved into the I.M)

  end

  module Plugin::Client::InstanceMethods

    # unlike e.g Host::InstanceMethods, this hellof adds public methods

    # `load_plugin` - formerly `initialize`, then `init_plugin`,
    # this sets these crucial ivars, and/or gives the plugin client
    # "change itself" to an instance of a different class
    # based on whatever. assume this is the first plugin-related
    # call this object receives.
    #
    # a note about `@plugin_host_proxy` - we used to set the
    # `@plugin_services` ivar instead, but using the `host proxy` solely
    # feels cleaner. if you need a handle on the services object, by
    # all means override this method in your plugin client.

    def load_plugin plugin_story, plugin_services
      @plugin_story = plugin_story
      @plugin_host_proxy = plugin_services.build_host_proxy self
      self  # important
    end

    # `host` - because it is used so often, this is the *only* instance
    # method that your client plugin class gets that does not have "plugin"
    # in its name. used to call up to a host service.

    def host
      @plugin_host_proxy
    end
    protected :host  # but it is inteded to be used internally

    # `is_plugin_host` - this is necessary for some interesting hacks
    # elsewhere. a plugin (client) can certainly be a plugin host itself!

    def is_plugin_host
      false
    end

    # `plugin_story` - called by plugin manager `load_plugins`.

    def plugin_story
      @plugin_story or raise "no @plugin_story - call `load_plugin` first? #{
        }- #{ self.class }"
    end

    # `plugin_slug` - an informal way to refer to the plugin by a name.
    # NOTE we avoid the use of `plugin_name` because it's too ambiguous
    # and could cause problems based on what the assumed meaning of "name"
    # is. (plugins maybe can have local names in the host application.
    # maybe the same, maybe different is a "plugin instance key" that the
    # plugin manager in the host application uses to identify the particular
    # instances. maybe multiple plugin instances come from the same class..
    # multiple plugin implementations may exist in the unversve with the
    # same "name" but they may do very different things.. etc.)

    def plugin_slug
      @plugin_story.local_slug
    end

    #      ~ eventpoint-related reflection and then notification ~

    def plugin_eventpoints
      @plugin_story.plugin_eventpoints
    end

    def plugin_eventpoint ep, a
      if plugin_subscribed? ep.name
        send ep.as_method_name, *a
      end
    end

    # `plugin_subscribed?`  - *definitely* leave room for this to
    # change during runtime for the particular plugin client (for now..)

    def plugin_subscribed? name_sym
      @plugin_story.subscribed? name_sym
    end
    # public for hacks

    # `call_plugin_service` - this implements the top of the long round-trip
    # for the expermental "plugin services" (extension-like) facility.
    # this call probably came in from the host application, and represents
    # a service call that the host application wants us to fill (weird).
    # (*that* call may very well have originated from another plugin..)
    # for now it is our job to validate access.

    def call_plugin_service name_sym, a, b
      if @plugin_story.has_plugin_service? name_sym
        send name_sym, *a, &b
      else
        raise Plugin::Service::NameError,
          "not a plugin service of #{ self.class } - #{ name_sym }"
      end
    end
  end

  module Plugin::ModuleMethods

    # (this is for the particular plugin box module)

    def plugin_story
      const_get :STORY_, false
    end
  end

  # custom error classes - these are used as sort of a marker for when
  # a simple `fail "sanity -"` or `raise "foo"` becomes something a bit
  # more officially part of the API.

  class Plugin::DeclarationError < ::RuntimeError
  end

  class Plugin::RuntimeError < ::RuntimeError
  end

  # (the above two classes intentionally don't share a parent class from this
  # library because they are mutually exclusive in their scope. the one happens
  # during declaration (DSL blocks) and the other during "runtime" as the
  # plugin world sees "runtime".

  module Plugin::Service
    # (one day this might become etc)
  end

  class Plugin::Service::NameError < Plugin::RuntimeError

    # *now* we make a taxonomy out of it, just for fun ..
    # raised when an invalid service name is requested (for now this check
    # happens at runtime as opposed to declaration time only when dealing
    # with the experimental delegated services.)

  end

  class Plugin::Service::AccessError < Plugin::RuntimeError

    # if the plugin requests a service that it did not register for

  end

  class Plugin::Event::Point::NameError < Plugin::RuntimeError

    # emitted when a host application emits an eventpoint whose name
    # was not declared.

  end
end
