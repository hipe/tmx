module Skylab::Face

  class API::Action

    # experiments in a value-added API action base class with value
    # propositions for the big dream..

    # `initialize` - experimentally we do a strict unpacking of
    # `param_h`, setting corresponding ivars. this might easily
    # fall over one day..

    def initialize client_x, param_h
      init client_x  # for fun we experiemnt with `prepend` and initting
                     # the different facets.. NOTE we do not keep a handle
                     # on it ourselves, to keep things interesting.
      miss_a = self.class.param_a.dup ; par_h = self.class.param_h

      param_h.each do |k, v|  # ([#fa-el-003)
        idx = par_h[ k ] or fail "sanity - default_proc?"
        miss_a[ idx ] = nil
        instance_variable_set :"@#{ k }", v
      end
      miss_a.compact!
      miss_a.length.nonzero? and raise ::ArgumentError, "missing #{
        }argument(s) - (#{ miss_a.map( & :to_s ) * ', ' })"
    end

    # `init` - this is provided experimentally as a hook for sub-facet
    # modules to chain over using `prepend`
    def init _client_x
      # (in case you ever put anything here, please not that it will
      # (hopefully) be called after any facets have run..)
    end
    private :init

    #         ~ params related declaration & processing ~

    # `self.param_a`, `self.param_h` - hacky simple parameter validation
    # (the below are defaults for when they are not set explicitly)

    -> do
      empty_a = [ ].freeze
      define_singleton_method :param_a do empty_a end
      define_singleton_method :param_h do
        @param_h ||= ::Hash.new do |h, k|
          raise "undeclared parameter - #{ k }. (none were declared for #{
            }this action (#{ self }). declare some with `params` ?)"
        end.freeze
      end
    end.call

    # `self.params` - hacky simple parameter validation with a
    # rabbit hole to somewhere else .. NOTE #experimental hack

    define_singleton_method :params, &
        MetaHell::FUN.module_mutex[ ->( * param_a ) do
      if param_a.first.respond_to? :each_index
        param_a = API::Action::Param::Flusher[ param_a, self ]
      end
      no = param_a.detect { |x| ! ( ::Symbol === x ) }
      no and raise "invalid `params` value - #{ no.inpect } (if you meant #{
        }to use meta-fields, for now the first tuple has to be an array)"
      param_a.freeze
      param_h = ::Hash[ param_a.each.with_index.to_a ]
      param_h.default_proc = -> h, k do
        raise "undeclared parameter - #{ k } for #{ self }. #{
          }(add it to the list at the existing `params` macro?)"
      end
      param_h.freeze
      define_singleton_method :param_a do param_a end
      define_singleton_method :param_h do param_h end
    end, :params ]


    #         ~ request-time paramater management ~

    # `pack_fields_and_options` - #experimentally many methods in the
    # entity library take the "sacred four" parameters [#fa-el-001].
    # freqently requests coming in from the client will munge the
    # two namespaces (one of business-level fields, (e.g "email") and the
    # other of controller-level options (e.g `verbose`), however the
    # entity library insists on more rigidity and structure than this.

    # experimentally your API actions defines parameters (a.k.a fields)
    # using meta-fields that tag meta-info about each field, e.g whether
    # the field is a "field" field or an "option" field.

    # So, of each field in this field box reflector, along the categories of:
    #   `field` and `option`,
    # when each field falls into one (or more wtf) of these two categories
    # one hash is made for each category, with its names being the field
    # name and its values being the field's values.
    # result is always an array of two hashes.

    -> do
      a = %i( field option )
      define_method :pack_fields_and_options do
        h = ::Hash[ a.map { |k| [ k, { } ] } ]
        ks = h.keys
        fields_bound_to_ivars.each do |bf|
          ks.each do |k|
            if bf.field[ k ]
              h.fetch( k )[ bf.field.normalized_name ] = bf.value
            end
          end
        end
        a.map { |k| h.fetch k }
      end
    end.call

    #     ~ *experimental* plugin-like services declaration macro here ~

    define_singleton_method :services, & MetaHell::FUN.module_mutex[ ->(*x_a) do

      API::Action::Service::Flusher.new( self, x_a ).flush

    end, :services ]

    #         ~ *experimental* event wiring facilities up here ~

    extend Face::Services::PubSub::Emitter
      # child classes define the event stream graph.

    public :on, :with_specificity  # from emitter above, hosts like these public

    class << self
      alias_method :_face_original_emits, :emits  # #todo
    end

    define_singleton_method :emits, & MetaHell::FUN.module_mutex[ ->( *a ) do
      _face_original_emits( *a )
      @event_stream_graph.names.each do |i|
        define_method i do |x|
          emit i, x
          nil
        end
      end
      nil
    end, :emits ]
  end
end
