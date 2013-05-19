module Skylab::Face

  class API::Client

    # `API::Client` - experimental barebones implementation: a base class for
    # your API client. perhaps the only class you will need. the first last
    # attempt at this, and the last first one. the light. the way.

    # `_enhance` - private experiment. #multi-entrant. this is the experimental
    # implementation of `Face::API#[]`. this (re-)affirms that you have under
    # your `anchor_mod`:
    #
    # 1) a module called `API` (maybe MAARS-y).
    # 2) a const `API::Client` that is MAARS-y. (if you do not have such a
    #   const, one will be provided for you in the form of a subclass of
    #   Face::API::Client.)
    # 3) an `invoke` method "on" your `API` module.
    # 4) an `Actions` box moudule - MAARS-y and Boxxy
    #
    # using `puff` for this attempts to load any releveant file first.

    -> do

      puff = MetaHell::Module::Accessors::FUN.puff

      define_singleton_method :_enhance do |amod|  # `amod` = anchor module

        API::Client::Config_DSL_[ amod ]

        puff[ amod, :API, -> { ::Module.new }, -> do

          puff[ self, :Client, -> { ::Class.new Face::API::Client } ]

          if ! respond_to? :invoke
            define_singleton_method :invoke, & FUN.invoke
          end

          puff[ self, :Actions, -> { ::Module.new }, -> do
            respond_to? :const_fetch or extend MetaHell::Boxxy
          end ]
        end ]
        nil
      end
    end.call


    #                       ~ narrative intro ~                   ( section 1 )

    o = { }

    # `invoke` - the default implementation. this is the only method that
    # (either thru adding to ancestor chain, through defining on self, or thru
    # defining on singleton class) is added in any way to your anchor module
    # (hence we add it in this strange way rather than adding a whole other
    # module to your chain). it is in this sense this function is off the chain.

    o[:invoke] = -> i_a, param_h=nil, modal_client=nil do
      e = ( @api_client ||= const_get( :Client, false ).new ).
        get_executable i_a, param_h, modal_client
      e and e.execute
    end

    # `get_executable` called from above. also may called from modality clients
    # that create their own API client, rather than rely on the memoized
    # (read: singleton) one. compare to `get_reflective_action` below.

    def get_executable i_a, param_h, modal_client
      before_each_execution
      action = build_primordial_action i_a         # [#fa-016]
      handle_events modal_client, action           # [#fa-017]
      resolve_services modal_client, action        # [#fa-018]
      normalize action, param_h                    # [#fa-019]
    end

    # `before_each_execution` - this experimental hack has obvious issues with
    # it, the same issues you run into when dealing with this in rspec

    def before_each_execution
      _conf.if? :before_each_execution, -> f do
        f.call
      end
      nil
    end
    private :before_each_execution

    # `get_reflective_action` - called from facets like "reveal" - build
    # an action instance that can reflect on itself for purposes of
    # documentation (compare to `get_executable` above). what a
    # "reflective action" entails exactly is compartmentalized here.

    def get_reflective_action i_a
      fail 'yes'
      action = build_primordial_action i_a
      if ! action.has_param_facet
        API::Action::Param[ action.class, [] ]
        # because we lazy load revelations, ich muss sein, twerk the class..
      end
      action
      # we are oppen to the possibility of needing to wire it further but
      # let it get only as complex as necessary..
    end

    def build_primordial_action i_a
      _conf.if? :action_name_white_rx, -> x do
        ( no = i_a.detect { |i| x !~ i.to_s } ) and
          raise MetaHell::Boxxy::NameNotFoundError,
            message: "no such action - \"#{ no }\"", name: no
      end
      const_x = api_actions_module.const_fetch i_a
      if const_x.respond_to? :call
        API::Action.const_get( :Proc, false )[ const_x ]
      else
        const_x.new
      end
    end
    private :build_primordial_action  # called above only

    def _conf
      @_conf ||= module_with_conf._conf
    end
    private :_conf

    # we have what we'll call "neighbor modules" whom we need to be able to
    # access at runtime to reflect on, make decisions, and load things to run.
    # If you really needed to you could change how these modules are accessed
    # by either overriding the generated method(s) below or setting the ivar
    # but eew.

    MetaHell::Module::Accessors.enhance self do

      private_module_autovivifier_reader :module_with_conf, '../..', nil, nil

      private_module_autovivifier_reader :api_actions_module, '../Actions',
      -> { ::Module.new },           # if it didn't exist, make it!
      -> { extend MetaHell::Boxxy }  # sketchily enhance it no matter what
                                     # uh-oh, this is duplicated above..

   end

    # `handle_events` - [#fa-017]
    # the API client handles no events. when invoking an API action "directly"
    # through the API, the only thing you get (for now) is the result of the
    # execute. however, if a `modal_client` is passed, we hook into that.
    # result is undefined. raise on failure.

    def handle_events modal_client, ac
      if ac.respond_to?( :has_emit_facet ) && ac.has_emit_facet && modal_client
        modal_client.handle_events ac  # easy enough
      end
      nil
    end
    private :handle_events  # called above only

    # `resolve_services` - [#fa-018] - result undefined. raises on falure.

    def resolve_services modal_client, action
      if action.respond_to?( :has_service_facet ) && action.has_service_facet
        addtl_svcs = ( if modal_client and
            modal_client.respond_to? :plugin_services then
          modal_client.plugin_services
        end )
        action.resolve_services( if addtl_svcs
          Services::Headless::Plugin::Host::Services::Chain.new [
            addtl_svcs, plugin_services ], self.class
        else
          plugin_services
        end )
      end
      nil
    end
    private :resolve_services  # called above only

    # `normalize` - :[#fa-019]: give the API action a chance to run
    # normalization (read: validation, internalization) hooks before
    # executing. note we want the specifics of this out of the mode
    # clients.
    #
    # because this is currently a "private fold method" [#bs-012] -- it is
    # only called by `get_executable` -- and *that* has a monadic, atomic,
    # unary result, then it is that the upstream caller *cannot* express an
    # arbitrary result object (e.g an `exitstatus` code) from the particular
    # API Action's normalization failure.
    #
    # this might be a good thing. it might be that if you need/want to have
    # arbitrary exit statii (or other strange results) from your normalization
    # failure, you should push that step down to your `execute` method, which
    # was designed from the ground-up to accomodate requirements like that.
    #
    # given all of the above, and given that we are the last step in the API
    # Action lifecycle [#fa-021], our result is then the result of our
    # upstream caller - false-ish or an executable.
    #
    # currently writing to `y` just hooks back into the API action instance
    # (by sending it `normalization_failure_line` with the selfsame arg that
    # `y#<<` received). this allows for evented handling of the message, e.g
    # adding meta-information about the action to the message.
    #
    # (with the above said, please see [#fa-019] for information about
    # possible future/possible current features of field-level normalization.)

    def normalize action, param_h
      if ! action.respond_to?(:normalize) && (! param_h || param_h.length.zero?)
        action  # effectively skip this step in the lifecycle IFF above is true
      else
        y = action.instance_exec do  # emitting call below might be private
          Services::Basic::Yielder::Counting.new( &
            if respond_to? :normalization_failure_line
              method :normalization_failure_line
            else
              -> msg do
                raise ::ArgumentError, msg
              end
            end )
        end
        action.normalize y, param_h  # result is undefined.
        action if y.count.zero?
      end
    end
    private :normalize


    #                  ~ API client enhancement API ~            ( section 2 )

    # some enhancements enhance your life by enhancing your entire API. the
    # class method(s?) in this section are created and exposed to be accessed
    # by enhancements such as these. That is, this is part of the API API.

    # `enhance_model_enhanced_api_client` - runs a block from which
    # enhancements can add services to the API client. We assume that this is
    # done in large part through adding particular model controllers to the
    # model, hence we affirm that we provide the below model-focused services.
    # this is designed to be re-affirmable - that is, each additional time
    # the below logic is run on the same API client class, it should have no
    # additional side-effects.

    def self.enhance_model_enhanced_api_client &blk
      me = self
      Face::Services::Headless::Plugin::Host.enhance self do
        service_names %i|
          has_model_instance
          set_new_valid_model_instance
          model
        |

        me.send :include, API::Client::Model::InstanceMethods  # wedged in here
          # in case we override above, and get overridden below

        instance_exec( & blk )  # ERMAHGERD
      end
    end

    Services::Headless::Plugin::Host.enhance self do

      # experimentally our API API is implemented via conceptualizing our
      # API client as itself a plugin host, as is hinted at above.

    end

    #                ~ experimental revelation services ~        ( section 3 )

    def revelation_services
      @revelation_services ||= API::Revelation::Services.new self
    end
    public :revelation_services


    FUN = ::Struct.new( * o.keys ).new( * o.values )

  end

  class API::Client

    module Config_DSL_

      def self.[] amod
        amod.respond_to? :_conf or amod.extend Config_DSL_::MM
        if ! amod._conf
          amod._set_conf Config_DSL_::Cnt_.new( amod )
          amod.dsl_dsl do
            atom :action_name_white_rx
            block :before_each_execution
          end
        end
        nil
      end
    end

    module Config_DSL_::MM

      attr_reader :_conf

      def _set_conf x
        _conf and fail "sanity - won't clobber existing"
        @_conf = x
        nil
      end

      def dsl_dsl &b
        @_conf._dsl_dsl b
      end
    end

    class Config_DSL_::Cnt_

      def initialize host
        @host = host
        @story = nil
        @box = MetaHell::Formal::Box::Open.new
      end

      def _dsl_dsl blk
        @story ||= MetaHell::DSL_DSL::Story_.new @host.singleton_class, @host,
          self
        @story.instance_exec( &blk )
        nil
      end

      def add_field( * )
        # meh
      end

      def add_or_change_value _host, i, x
        @box.add i, x   # note we want it to throw if set already - we want
        nil             # this to be write-once. because we might cache things.
      end               # otherwise it's clunky to check config for everything.

      attr_reader :box

      %i| fetch [] has? if? |.each do |i|
        define_method i do |*a, &b|
          @box.send i, *a, &b
        end
      end
    end
  end
end
