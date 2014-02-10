class Skylab::Face::CLI

  module CLI::API_Integration

    def self.touch ; nil end      #kick-the-loading-warninglessly-and-trackably

  end

  CLI::Metastory.touch

  class CLI_Mechanics_  # #re-open for facet

    #  ~ class section 1 - singleton methods ~

    def self.client_can_broker_plugin_metaservices
      false
    end

    #  ~ class section 2 - public instance methods ~

    def event_listener_for_api_executable  # the magic thing with on_* methods
      self
    end

    def service_provider_for_api_executable _hot_action
      sf = @surface[]
      if sf.instance_variable_defined? :@plugin_host
        sf.instance_variable_get :@plugin_host
      end  # covered
    end

    def control_hub_for_api_executable  # get notified of last executable
      self
    end

    def set_last_api_executable exe
      @last_api_executable = exe
      nil
    end

    attr_reader :last_api_executable  # #called-by `cull` #todo

    def api_plugin_metaservices  # unofficial `modal services` api
      parent_shell.instance_variable_get( :@plugin_host ).
        plugin_host_metaservices
    end

    def handle_events action  # hookback [#017] #called-by API client
      if action.respond_to? :with_specificity  # else not a pub-subber.
        a, h = parent_shell_module.api_stream_box
        action.with_specificity do
          a.each do |stream_i|
            if action.callback_digraph_has? stream_i
              action.on stream_i, parent_shell.method( h.fetch stream_i )
            end
          end
        end
        check_for_unhandled_non_taxonomic_streams_for_api action
      end
      nil
    end

    def api_client  # #called-by here and children
      @api_client ||= api_client_class.new
    end

     #  ~ class section 3 - private instance methods ~

  private

    # `api_client_class` #called-by-here there is a lot we need to affirm
    # about our rigging for now .. a little more than just autovifiying some
    # sane defaults; but also, little more than just that. there is currently
    # no way to override this without actually overriding this; but watch for
    # something like that in the spirit sort of maybe near [#009]

    def api_client_class
      @api_client_class ||= begin
        amod = application_module
        if ! amod.const_defined? :CLI, false
          fail "sanity - for now we follow convention strictly because of #{
            }the wide blast radius of our autogeneration .. expected that #{
            }the CLI Client exist inside of a `CLI` module. no such module#{
            } - #{ amod }::CLI"  # maybe magic one day - [#009]
        end
        Face_::API[ amod ]  # no need to check anything, ok to repeat this.
        amod.const_get( :API, false ).const_get( :Client, false )
      end
    end

    Lib_::Module_accessors[ self, -> do
      private_methods do
        # we are Mine::CLI::Client::Mechanics
        module_reader :parent_shell_module, '..'
        module_reader :application_module, '../../../'
      end
    end ]

    # `check_for_unhandled_non_taxonomic_streams_for_api` - this might
    # necessitate that the client class defines an API::Action base class that
    # defines a list of taxonomic streams.. in which case the client
    # application must either override this method or define a list of zero or
    # more taxonomic streams, lest a method missing exception will always be
    # raised (for now..)

    def check_for_unhandled_non_taxonomic_streams_for_api action
      action.if_unhandled_non_taxonomic_streams method( :raise )
    end
  end

  class Namespace

    #  ~ class section 1 - public singleton methods added by this facet ~

    # `api_stream_box` - assume that any private method whose name starts with
    # "on_" could represent a handler for a corresponding event stream
    # (e.g. a method `on_validation_error` is for handling events of the
    # stream named `validation_error` and so on). result is lazy evaluated
    # at call time, is a memoized, frozen `a` and `h` tuple.

    -> do
      rx = /^on_(.+)/
      define_singleton_method :api_stream_box do
        @api_stream_box ||= begin
          a = [ ] ; h = { } ; private_instance_methods.each do |i|
            if rx =~ i  # eek, meh
              a << ( stream_name = $~[1].intern )
              h[ stream_name ] = i
            end
          end
          [ a.freeze, h.freeze ].freeze
        end
      end
    end.call
  end

  class NS_Mechanics_  # #re-open for facet

    undef_method :api  # #loader-stub

    def api *args
      action = get_api_executable_with :param_x, args
      action && action.execute
    end

    undef_method :call_api  # was a loader stub.

    def call_api nx, par_h=nil
      a =  [ :name_x, nx ]
      par_h and a << :param_x << par_h
      action = get_api_executable_with( * a )
      action && action.execute
    end

    undef_method :api_services  # #loader-stub

    def api_services
      @api_services ||= CLI::API_Integration::Services_.new self
    end

    class Executable_Request_
      Lib_::Fields_via[ :client, self, :struct_like, :field_i_a,
        [ :name_x, :param_x, :expression_agent_p ] ]
    end

    undef_method :get_api_executable_with  # #loader-stub

    def get_api_executable_with *a
      o = Executable_Request_[ *a ]
      norm_a = (( nx = o.name_x )) ? [ * nx ] : @last_hot.anchored_last
      y = [ :name_i_a, norm_a,
            :event_listener, event_listener_for_api_executable ]
      par_h = if (( ph = o.param_x )).respond_to? :each_pair then ph else
        finish_param_h_for_api ph
      end
      par_h and y << :param_h << par_h
      (( eap = o.expression_agent_p )) and y << :expression_agent_p << eap
      y << :service_provider_p << method(:service_provider_for_api_executable)
      ac = api_client
      exe = ac.get_executable_with( * y )
      exe and control_hub_for_api_executable.set_last_api_executable exe
      exe
    end

    def api_client  # #called-by self as parent (if you know what i mean)
      parent_services.api_client
    end

    def event_listener_for_api_executable
      parent_services.event_listener_for_api_executable
    end

    def service_provider_for_api_executable hot
      parent_services.service_provider_for_api_executable hot
    end

    def control_hub_for_api_executable
      parent_services.control_hub_for_api_executable
    end


  private

    # `finish_param_h_for_api` - this is a convenience hack that places the
    # business function's args into the param_h array based on the positions
    # of the args vis-a-vis ruby's reflection API's reporting of the names of
    # the formal arguments. `args` is not a straight up superglob of all your
    # arguments - it is a fixed-length array (fixed for some function) that
    # is a tuple of the formal arguments.

    def finish_param_h_for_api args, cmd_i=nil
      sht = @sheet.fetch_constituent( cmd_i || @last_hot.name.as_method )
      p_a = get_command_parameters sht
      len = args ? args.length : 0
      len == p_a.length or fail "sanity - #{ len } actual args for for #{
        }#{ p_a.length } formal args (formals: #{ p_a.inspect })"
      had_some, par_h = -> do
        had = p_h = nil
        parent_shell.instance_exec do
          if instance_variable_defined? :@param_h and @param_h
            had = true ; p_h = @param_h ; @param_h = nil
          end
        end
        [ had, p_h || { } ]
        # maybe you have no o.p and no arguments, we'll see..
      end.call
      p_a.each_with_index do | (_, k), i |
        par_h[ k ] = args.fetch i
      end

      # if you set @param_h elsewhere you are guaranteed to get it here.
      # elsewise you only get some if there were some params to be had.
      par_h if par_h.length.nonzero? || had_some
    end
  end
end
