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

    def self._enhance amod  # anchor module

      API::Client::Config_DSL_[ amod ]

      Puff_[ amod, :API, -> { ::Module.new }, -> do

        Puff_[ self, :Client, -> { ::Class.new Face::API::Client } ]

        respond_to? :invoke or define_singleton_method :invoke, & Invoke_

        Puff_[ self, :Actions, -> { ::Module.new }, -> do
          respond_to? :const_fetch or MetaHell::Boxxy[ self ]
        end ]
      end ]
      nil
    end

    Puff_ = MetaHell::Module::Accessors::Puff

    #                       ~ narrative intro ~                   ( section 1 )

    Invoke_ = -> name_x, par_h=nil do  # this is the only method that is
      # added by any means to the e.g 'API' module of your application (hence
      # we add it in this strange way rather than clutter your ancetor chain).
      # in this sense this function is off the chain. (note too, an application
      # may want to manage its own version of the API client created below,
      # rather than call this; to leverage the several other options availble
      # when creating API executables not utilized here.) #raw-API

      c = @system_api_client ||= const_get( :Client, false ).new
      e = c.get_raw_executable_for name_x, par_h
      e and e.execute
    end

    def get_raw_executable_for name_x, par_h
      y = [ :name_i_a, [ * name_x ] ]
      par_h and y << :param_h << par_h
      raw_request_param_a_notify y
      get_executable_with( * y )
    end

  private

    def raw_request_param_a_notify y
      y << :service_provider_p << -> ex do
        service_provider_for ex
      end
    end

    def service_provider_for ex
    end

  public

    def get_executable_with *a  # the lower-level, fully customizable interface.
      o = Executable_Request_[ * a ]
      get_executable_with_notify
      action = build_primordial_action o.name_i_a    # [#fa-016]
      wire_for_expression action, o                  # [#fa-017]
      resolve_services action, o                     # [#fa-018]
      normalize action, o.param_h                    # [#fa-019]
    end

    class Executable_Request_
      MetaHell::FUN::Fields_[ :client, self, :struct_like, :field_i_a,
        [ :name_i_a, :param_h, :expression_agent_p, :event_listener,
          :service_provider_p ] ]
    end

    def get_reflective_action i_a  # for documentation, not execution
      action = build_primordial_action i_a
      if ! action.has_param_facet
        API::Params_.
          enhance_client_with_param_a_and_meta_param_a action.class, [], nil
        # because we lazy load revelations, ich muss sein, twerk the class..
      end
      # we are open to the possibility of needing to wire it further but
      # let it get only as complex as necessary..
      action
    end

  private

    def get_executable_with_notify  # this experimental hack has obvious issues
      # with it, the same issues you run into when dealing with this in rspec
      _conf.if? :before_each_execution, -> f do
        f.call
      end
      nil
    end

    def build_primordial_action i_a
      const_x = action_const_fetch i_a do |ne|
        raise "isomorphic API action resolution failed - there is no #{
          }constant that isomorphs with \"#{ ne.name }\" of the constants #{
          }of #{ ne.module }"  # we could keep it granulated but this is a
          # hard error. you are not supposed to recover from it. we
          # articulate it like this just for dev courtesy
      end
      if const_x.respond_to? :call
        API::Action.const_get( :Proc, false )[ const_x ]
      else
        const_x.new
      end
    end

    def action_const_fetch i_a, &oth
      _conf.if? :action_name_white_rx, -> x do
        ( no = i_a.detect { |i| x !~ i.to_s } ) and
          raise MetaHell::Boxxy::NameNotFoundError,
            message: "no such action - \"#{ no }\"", name: no
      end
      api_actions_module.const_fetch i_a, &oth
    end
    public :action_const_fetch   # (public for enhancements like verbosity.)

    def _conf
      @_conf ||= module_with_conf._conf
    end

    # we have what we'll call "neighbor modules" whom we need to be able to
    # access at runtime to reflect on, make decisions, and load things to run.
    # If you really needed to you could change how these modules are accessed
    # by either overriding the generated method(s) below or setting the ivar
    # but eew.

    MetaHell::Module::Accessors.enhance self do

      private_module_autovivifier_reader :module_with_conf, '../..', nil, nil

      private_module_autovivifier_reader :api_actions_module, '../Actions',
      -> { ::Module.new },           # if it didn't exist, make it!
      -> { MetaHell::Boxxy[ self ] }  # sketchily enhance it no matter what
                                     # uh-oh, this is duplicated above..

    end

    def wire_for_expression ex, o

      if o.expression_agent_p  # a simpler #experimental alternative to events..
        ex.set_expression_agent o.expression_agent_p[ ex ]
      end

      # the API client is blissfully ignorant of events - the only thing you
      # get from a raw API call "out of the box" is its final result and
      # whatever side-effects it does. but if an event listener was passed
      # in the field we simply hook back to that. result undefined, raise
      # o failure [#fa-017]

      if ex.respond_to?( :has_emit_facet ) && ex.has_emit_facet &&
        o.event_listener then
          o.event_listener.handle_events ex
      end

      nil
    end

    def resolve_services action, o
      # result undefined, raise on failure. [#fa-018]
      if action.respond_to?( :has_service_facet ) && action.has_service_facet
        ms = get_metaservices_for_of action, o.service_provider_p
        if o.param_h
          action.absorb_any_services_from_parameters_notify o.param_h
        end
        action.resolve_services ms
      end
      nil
    end

    def get_metaservices_for_of action, any_service_provider_p
      begin
        my_ms = plugin_host_metaservices
        any_service_provider_p or break
        sp = any_service_provider_p[ action ] or break
        sp.class.client_can_broker_plugin_metaservices or fail "sanity"
        object_id == sp.object_id and break  # passed self in as the sp, fine
        r = build_metaservices_chain action, sp.plugin_host_metaservices, my_ms
      end while nil
      r ||= my_ms
      r
    end

    def build_metaservices_chain action, *a
      Plugin_::Const_bang__[ action.class,
        :Plugin_Metaservices_Chain, -> do
          Plugin_::Host::Metaservices_::Chain_.new a.map( & :class )
        end ].new a
    end

    Plugin_ = Services::Headless::Plugin

  private

    # `normalize` - :[#fa-019]: give the API action a chance to run
    # normalization (read: validation, internalization) hooks before
    # executing. we want the specifics of this out of the particular
    # modality clients as much as possible.
    #
    # if this gets called e.g from the method that gets the executable, and
    # that method has a unary/monadic/atomic whatever result shape we cannot
    # express arbitrary result values (e.g an exitstatus) from the particular
    # API executable's normalization failure.
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
    # (by sending it `normalization_failure_line_notify` with the selfsame arg
    # that `y#<<` received). this allows for evented handling of the message,
    # e.g adding meta-information about the action to the message.
    #
    # (with the above said, please see [#fa-019] for information about
    # possible future/possible current features of field-level normalization.)

    def normalize ex, par_h
      begin
        Some_[ par_h ] and break
        ex.respond_to? :has_param_facet and ex.has_param_facet and break
        ex.respond_to? :normalize and break
        skip = true ; res = ex  # probably never gets here
      end while nil
      if skip then res else
        y = build_counting_message_yielder_for ex
        ex.normalize y, par_h  # result is undefined.
        y.count.zero? ? ex : false
      end
    end

    def build_counting_message_yielder_for ex
      ex.instance_exec do  # emitting call below might be private
        Services::Basic::Yielder::Counting.new( &
          if respond_to? :normalization_failure_line_notify
            method :normalization_failure_line_notify
          else
            -> msg do
              raise ::ArgumentError, msg
            end
          end )
      end
    end

    #                  ~ API client enhancement API ~            ( section 2 )

    # some enhancements enhance your life by enhancing your entire API. the
    # class method(s?) in this section are created and exposed to be accessed
    # by enhancements such as these. That is, this is part of the API API.

    Plugin_::Host.enhance self

      # our API API is implemented via conceptualizing our API client as
      # itself a plugin host, as is hinted at above.


    #                ~ experimental revelation services ~        ( section 3 )

    def revelation_services
      @revelation_services ||= API::Revelation::Services.new self
    end
    public :revelation_services

    #  ~ facet 5.6x - metastories ~  ( was [#fa-035] )

    Magic_Touch_.enhance -> { API::Client::Metastory.touch },
      [ self, :singleton, :public, :metastory ]

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

      def add_or_change_value _host, fld, x
        # we want this to throw if set already - we want this to be write once
        # because we might cache things - otherwise it's clunky to check config
        # for everything
        @box.add fld.nn, x
        nil
      end

      attr_reader :box

      %i| fetch [] has? if? |.each do |i|
        define_method i do |*a, &b|
          @box.send i, *a, &b
        end
      end
    end
  end
end
