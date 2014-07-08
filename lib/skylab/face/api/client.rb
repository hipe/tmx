module Skylab::Face

  class API::Client  # read [#055] the API client narrative #original-intro

    class << self

      def enhance_anchor_mod amod
        Config_DSL_[ amod ]
        _API = touch_and_autoloadify amod, :API do ::Module.new end
        _Client = touch_and_autoloadify _API, :Client do
          ::Class.new API::Client
        end
        _API.respond_to? :invoke or
          _API.define_singleton_method( :invoke, & Invoke__ )
        _Actions = touch_and_autoloadify _API, :Actions do
          Autoloader_[ ::Module.new, :boxxy ]
        end
        nil
      end
    private
      def touch_and_autoloadify mod, const_i, & p
        mod_ = if mod.const_defined? const_i, false
          mod.const_get const_i, false
        else
          mod.const_set const_i, p[]
        end
        if ! mod_.respond_to? :dir_pathname
          Autoloader_[ mod_ ]
        end
        mod_
      end
    end

    #                       ~ narrative intro ~                   ( section 1 )

    Invoke__ = -> name_x, par_h=nil do   # #storypoint-30
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
      action = build_primordial_action o.name_i_a    # [#016]
      wire_for_expression action, o                  # [#017]
      resolve_services action, o                     # [#018]
      normalize action, o.param_h                    # [#019]
    end

    class Executable_Request_
      Lib_::Fields_with[ :client, self, :struct_like, :field_i_a,
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
      conf.if? :before_each_execution, -> f do
        f.call
      end
      nil
    end

    def build_primordial_action i_a
      x = action_const_fetch i_a do |ne|
        raise say_bad_name ne
      end
      if x.respond_to? :call
        API::Action.const_get( :Proc, false )[ x ]
      else
        x.new
      end
    end

    def say_bad_name ne
      "isomorphic API action resolution failed - there is no constant that #{
        }isomorphs with \"#{ ne.name }\" of the constants of #{ ne.module }"
    end

    def action_const_fetch i_a, & p
      assert_that_name_passes_any_white_rx i_a
      _mod = api_actions_module
      Autoloader_.const_reduce i_a, _mod, & p
    end
    public :action_const_fetch   # (public for enhancements like verbosity.)

    def assert_that_name_passes_any_white_rx i_a
      forbidden_i = nil
      conf.if? :action_name_white_rx, -> rx do
        forbidden_i = i_a.detect { |i| rx !~ i.to_s }
      end
      forbidden_i and raise ::NameError, say_forbidden( forbidden_i )
    end

    def say_forbidden forbidden_i
      "wrong API action constant name #{ forbidden_name_part_i }"
    end

    def conf
      @conf ||= module_with_conf.conf
    end

    Lib_::Module_accessors[ self, ->  do  # #storypoint-120

      private_module_autovivifier_reader :module_with_conf, '../..', nil, nil

      private_module_autovivifier_reader :api_actions_module, '../Actions',
        -> do
          ::Module.new  # if it didn't exist, make it
        end, -> do
          # if it's not already an autoloader (of any kind?), enhance it
          respond_to? :dir_pathname or Autoloader_[ self, :boxxy ]
        end
    end ]

    def wire_for_expression ex, o

      if o.expression_agent_p  # a simpler #experimental alternative to events..
        ex.set_expression_agent o.expression_agent_p[ ex ]
      end

      if ex.respond_to?( :has_emit_facet ) && ex.has_emit_facet &&
        o.event_listener then  # #storypoint-150
          o.event_listener.handle_events ex
      end ; nil
    end

    def resolve_services action, o
      # result undefined, raise on failure. [#018]
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
        r = bld_msvcs_chain action.class, sp.plugin_host_metaservices, my_ms
      end while nil
      r || my_ms
    end

    def bld_msvcs_chain mod, * two_msvcs
      _cls = if mod.const_defined? MSVCS_CHAIN__, false
        mod.const_get MSVCS_CHAIN__
      else
        mod.const_set MSVCS_CHAIN__, bld_msvcs_chain_cls( two_msvcs )
      end
      _cls.new two_msvcs
    end

    def bld_msvcs_chain_cls two_msvcs
      Lib_::Plugin_lib[].
        build_metaservices_chain_from_class_a two_msvcs.map( & :class )
    end

    MSVCS_CHAIN__ = :Plugin_Metaservices_Chain

    def normalize ex, par_h  # #storypoint-185
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
        Lib_::Counting_yielder[
          if respond_to? :normalization_failure_line_notify
            method :normalization_failure_line_notify
          else
            -> msg do
              raise ::ArgumentError, msg
            end
          end ]
      end
    end

    #                  ~ API client enhancement API ~            ( section 2 )
    # #storypoint-210

    Lib_::Plugin_lib[]::Host.enhance self


    #                ~ experimental revelation services ~        ( section 3 )

    def revelation_services
      @revelation_services ||= API::Revelation::Services.new self
    end
    public :revelation_services

    #  ~ facet 5.6x - metastories ~  ( was [#035] )

    Magic_Touch_.enhance -> { API::Client::Metastory.touch },
      [ self, :singleton, :public, :metastory ]

  end

  class API::Client

    module Config_DSL_

      def self.[] amod
        amod.respond_to? :conf or amod.extend Config_DSL_::MM
        if ! amod.conf
          amod.set_conf Config_DSL_::Cnt_.new amod
          amod.dsl_dsl do
            atom :action_name_white_rx
            block :before_each_execution
          end
        end
        nil
      end
    end

    module Config_DSL_::MM

      attr_reader :conf

      def set_conf x
        conf and fail "sanity - won't clobber existing"
        @conf = x ; nil
      end

      def dsl_dsl & p
        @conf._dsl_dsl p
      end
    end

    class Config_DSL_::Cnt_

      def initialize host
        @host = host
        @story = nil
        @box = Lib_::Open_box[]
      end

      def _dsl_dsl blk
        @story ||= Lib_::DSL_DSL_story[ @host.singleton_class, @host, self ]
        @story.instance_exec( &blk )
        nil
      end

      def add_field( * )
        # meh
      end

      def add_or_change_value _host, fld, x  # #storypoint-280
        @box.add fld.nn, x ; nil
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
