module Skylab::Face

  class API::Action

    # experiments in a value-added API action base class with value
    # propositions for the big dream..

    # `initialize` - experimentally we do a strict unpacking of
    # `param_h`, setting corresponding ivars. this might easily
    # fall over one day..
    #
    # (note that *after* `initialize` and before `execute` we still
    # expect a call to `normalize`!)

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
      nil
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

    -> do  # `param_a`, `param_h`
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

    #                ~ *experimental* normalization api ~
    #
    # this API action can assume to receive a call to this `normalize`
    # method right before the *mode* client would send `execute` to this
    # receiver. the caller assumes that this receiver will call either
    # `if_yes` or `if_no` in a monadic mutex fashion (it assumes this
    # receiver will call one of the two, and exactly once), and as the
    # result of this call.
    #
    # experimentally the API client provides us with the `y` as a future-
    # proof-y yielder to write (via `<<`) messages about normalization
    # (e.g validation) failure. For even more tangle, we can call
    # `y.count` to see how many times we called it!
    #
    # (for now, using `y` necessitates that this receiver respond to
    # `normalization_failure_line`, which the API Action subclass could
    # do by declaring that it emits an event of the same name..)
    #
    # (but see notes at [#fa-api-004] - this is exploratory! NOTE almost
    # guaranteed to change!)
    #
    # (and we also roll `required` into it, which is like a subset of
    # normalization?)

    def normalize y, call_if_yes, result_if_no
      ok = true
      begin
        has_field_box or break  # some don't opt-in
        field_box.each do |nn, fld|  # sneak this in, too
          if fld.is_required
            if instance_variable_get( fld.as_host_ivar ).nil?
              y << "needs to know \"#{ nn }\""   # #todo labels
              next
            end
          end
          fld.has_normalizer or next
          n_x = fld.get_normalizer
          if true == n_x
            n_x = method :"normalize_#{ fld.normalized_name }"
          end
          x1 = instance_variable_get fld.as_host_ivar  #eew
          instance_exec y, x1, -> x2 do
            instance_variable_set fld.as_host_ivar, x2
            nil
          end, & n_x
        end
        y.count.zero? and break
        ok = false
      end while nil
      if ok
        call_if_yes[]
      else
        result_if_no[ false ]  # my exit status - build down when needed.
      end
    end

    def has_field_box
      false  # gets overridden by Basic::Field::Reflection::InstanceMethods
    end
    private :has_field_box
  end
end
