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

      define_singleton_method :_enhance do |anchor_mod|

        puff[ anchor_mod, :API, -> { ::Module.new }, -> do

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
    # (read: singleton) one.

    def get_executable i_a, param_h, modal_client
      r = false
      begin
        x = api_actions_module.const_fetch i_a
        if x.respond_to? :call
          action = API::Action.const_get( :Proc, false )[ x ]
        else
          action = x.new                             # [#fa-api-001]
          handle_events modal_client, action         # [#fa-api-002]
          resolve_services modal_client, action      # [#fa-api-003]
        end
        b, r = normalize action, param_h             # [#fa-api-004]
        b and break
        r = action
      end while nil
      r
    end

    # we have what we'll call "neighbor modules" whom we need to be able to
    # access at runtime to reflect on, make decisions, and load things to run.
    # If you really needed to you could change how these modules are accessed
    # by either overriding the generated method(s) below or setting the ivar
    # but eew.

    MetaHell::Module::Accessors.enhance( self ).
      private_module_autovivifier_reader :api_actions_module, '../Actions',
      -> { ::Module.new },           # if it didn't exist, make it!
      -> { extend MetaHell::Boxxy }  # sketchily enhance it no matter what
                                     # uh-oh, this is duplicated above..

    # `handle_events` - [#fa-api-002]
    # the API client handles no events. when invoking an API action "directly"
    # through the API, the only thing you get (for now) is the result of the
    # execute. however, if a `modal_client` is passed, we hook into that.
    # result is undefined. raise on failure.

    def handle_events modal_client, action
      if modal_client
        modal_client.handle_events action  # easy enough
      end
      nil
    end
    private :handle_events  # called above only

    # `resolve_services` - [#fa-api-003] - result undefined. raises on falure.

    def resolve_services modal_client, action
      if action.respond_to? :resolve_services
        addtl_svcs = ( if modal_client and
            modal_client.respond_to? :plugin_services then
          modal_client.plugin_services
        end )
        action.resolve_services( if addtl_svcs
          Services::Headless::Plugin::Host::Services::Chain.new [
            addtl_svcs, plugin_services ]
        else
          plugin_services
        end )
      end
      nil
    end
    private :resolve_services  # called above only

    #  `normalize` - this is [#fa-api-004], documented here.
    #
    # give the API action a chance to run normalization (read: validation,
    # internalization) hooks before executing. note we want the specifics of
    # this out of the mode clients.
    #
    # our result is a tuple of `alt` (t|f) and `res`. a true-ish `alt` is an
    # indication that normalization failed for the API action (and we have an
    # "alternate" ending). sending `execute` to the API action in such
    # circumstances will have undefined behavior and should *not* be done
    # by anyone ever for any reason.
    #
    # if the mode client wants it, `res` is whatever result the API action
    # resulted in in response to the normalization failure (e.g it could be an
    # exit status code, depending on the API action).
    #
    # a false-ish `alt` on the other hand is an indicaton that normalization
    # *succeeded* for the API action. `res` is then undefined and should be
    # disregarded. the mode client may now procede to send `execute` to the API
    # action.
    #
    # currently writing to `y` just hooks back into the API action instance
    # (by sending it `normalization_failure_line` with the selfsame arg that
    # `y#<<` received). this allows for evented handling of the message, e.g
    # adding meta-information about the action to the message.
    #
    # (with the above said, please see [#fa-api-004] for more details)

    def normalize action, param_h
      if action.respond_to? :normalize or param_h && param_h.length.nonzero?
        y = action.instance_exec do  # emitting call below might be private
          Services::Basic::Yielder::Counting.new( &
            if respond_to? :normalization_failure_line
              method( :normalization_failure_line )
            else
              -> msg do
                raise ::ArgumentError, msg
              end
            end )
        end
        r = action.normalize y, param_h
        [ y.count.nonzero?, r ]
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
end
