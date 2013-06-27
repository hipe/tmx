module Skylab::Face

  module CLI::API_Integration

    def self.touch ; nil end      #kick-the-loading-warninglessly-and-trackably
  end

  CLI::Metastory.touch

  class CLI::Metastory__
    def _can_broker_plugin_metaservices  # #api-private while possible
      @metastory_subject.client_can_broker_plugin_metaservices
      # this assumes you are using plugin host proxy and not host.
      # essentially it indirectly assumes `isomorphic argument syntax` [#015]
    end
  end

  class CLI  # #re-open for facet

    def self.client_can_broker_plugin_metaservices  # used above..
      false                                         #  ..changed elsewhere
    end
  end

  class CLI_Mechanics_  # #re-open for facet

    #  ~ class section 1 - singleton methods (none currently) ~

    #  ~ class section 2 - public instance methods ~

    def has_api_plugin_metaservices
      parent_shell.class.metastory._can_broker_plugin_metaservices
        # note we don't call i.m's on parent_shell b.c of [#037]
    end

    def api_modality_proxy  # override parent, [#fa-010] explains why
      self
    end

    def api_plugin_metaservices  # unofficial `modal services` api
      parent_shell.instance_variable_get( :@plugin_host ).
        plugin_host_metaservices
    end

    def set_last_api_executable exe
      @last_api_executable = exe
      nil
    end

    attr_reader :last_api_executable  # #called-by `cull` #todo

    # `handle_events` - #called-by API client as a hookback to our
    # `get_executable`, straightforward implementation. implement this mode
    # client's implementation of this hook (hook explained in [#fa-017]).

    def handle_events action
      if action.respond_to? :with_specificity  # else not a pub-subber.
        a, h = parent_shell_module.api_stream_box
        action.with_specificity do
          a.each do |stream_i|
            if action.emits? stream_i
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
    # something like that in the spirit sort of maybe near [#fa-009]

    def api_client_class
      @api_client_class ||= begin
        amod = application_module
        if ! amod.const_defined? :CLI, false
          fail "sanity - for now we follow convention strictly because of #{
            }the wide blast radius of our autogeneration .. expected that #{
            }the CLI Client exist inside of a `CLI` module. no such module#{
            } - #{ amod }::CLI"  # maybe magic one day - [#fa-009]
        end
        Face::API[ amod ]  # no need to check anything, ok to repeat this.
        amod.const_get( :API, false ).const_get( :Client, false )
      end
    end

    MetaHell::Module::Accessors.enhance self do
      private_methods do
        # we are Mine::CLI::Client::Mechanics
        module_reader :parent_shell_module, '..'
        module_reader :application_module, '../../../'
      end
    end

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

    undef_method :api  # was a loader stub.

    def api *args
      action = api_executable args
      action.execute if action
    end

    undef_method :call_api  # was a loader stub.

    def call_api nx, par_h=nil
      action = api_executable par_h, nx
      action.execute if action
    end

    undef_method :api_services  # was a loader stub.

    def api_services
      @api_services ||= CLI::API_Integration::Services_.new self
    end

    def api_executable par_x, nx=nil
      norm_a = if nx then [ * nx ] else
        @last_hot.anchored_last
      end
      ac = api_client
      ph = if par_x.respond_to? :each_pair then par_x else
                finish_param_h_for_api par_x end
      exe = ac.get_executable norm_a, ph, api_modality_proxy
      exe and api_modality_proxy.set_last_api_executable exe
      exe
    end

    def api_client  # #called-by self as parent (if you know what i mean)
      parent_services.api_client
    end

    def api_modality_proxy   # see same method in child class
      parent_services.api_modality_proxy
    end

  private

    # `finish_param_h_for_api` - this is a convenience hack that places the
    # business function's args into the param_h array based on the positions
    # of the args vis-a-vis ruby's reflection API's reporting of the names of
    # the formal arguments. `args` is not a straight up superglob of all your
    # arguments - it is a fixed-length array (fixed for some function) that
    # is a tuple of the formal arguments.

    def finish_param_h_for_api args, cmd_i=nil
      sht = @sheet.fetch_constituent( cmd_i ||
        Services::Headless::Name::FUN.metholate[
          @last_hot.name.as_slug ].intern )
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
