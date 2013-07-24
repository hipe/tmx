module Skylab::Face

  class API::Action

    # this API::Action base class reifies the API API so that in your API
    # Action you can focus on your business logic and let everything else fit
    # together like magical greased lego's.
    #
    # everthing is of course experimental; but note it is a very designed,
    # thought-out experiment, with both eyes focused squarely on the big dream.

    # the API Action lifecycle :[#fa-021]:
    #
    # the lifecycle of the API Action happens thusly (ignoring how we got
    # to an API Action instance for a moment):
    #
    #
    # [_this_state_] -> `will_receive_this_message` -> [_and_go_to_this_state_]
    #
    #     [primordial] --o          just been created. no ivars at all (as far
    #                     \         as this API knows). is is probably right
    #                      \        after a call to `new`     [#fa-016]
    #                       \
    #                        o->   expression/event wiring    [#fa-017]
    #                         /
    #                        /      resolves how to express itself: any
    #     [wired]      <---o        listeners subscribe to its events, and/or
    #                  -o           it gets an expression agent set.
    #                    \
    #                     o--->   `resolve_services`          [#fa-018]
    #                        /
    #     [plugged-in]  <---o       it resolves fulfillment strategies for
    #                   -o          the services it declared as using, e.g
    #                     \         implemented by the [hl] plugin susbsystem.
    #                      \
    #                       o-->  `normalize`                 [#fa-019]
    #                         /
    #     [executable]  <----o       with its formal and/or actual parameters,
    #                   -o           with all its field-level assertions of
    #                     \          correctness that can be represented
    #                      \         declaratively (think DSL), assert them
    #                       \        now, result is soft failure or ivars.
    #                        \
    #                         o-> `execute`                   [#fa-020]
    #                          /
    #                         /      we now run this method that you wrote,
    #                        /       with your business logic in it.
    #     [executed]    <---o        probably we are done with the action now.
    #
    # The sequence of the steps above is based (perhaps aesthetically and/or
    # arbitrarily) on the notion that each successive state might depend on the
    # state before it: executing of course happens at the end, normalization
    # may require services, resolving services (and, more likely normalizing)
    # may require that the action has event listeners wired to it. wiring event
    # listeners requires nothing.
    #
    # Each of these steps may also have corresponding DSL-ish facets that this
    # class reveals (namely, `emits`, `services` and `params`) which we present
    # below in the corresponding order and inline with the corresponding
    # instance method (callbacks) enumerated above. So, any time you wonder
    # where you might find something here, think to the lifecycle first. yay.
    #
    # we break this into numbered sections corresponding to the lifecycle
    # point. there is for now no "section 1" because we are avoiding
    # implementing an `initialize` here, wanting to leave that wide open for
    # the client, which we will one day document at [#fa-016].
    # there will be no "section 5" because that is for you to write.
    #
    # [1] - and/or it get an expression agent set

    #                       ~ events (section 2) ~

    mutex = MetaHell::Module.mutex  # (we frequently want the facet-y DSL
    # calls to be processed atomic-ly, monadic-ly, er: zero or once each;
    # for ease of implementation. can be complexified as needed.)

    # `has_emit_facet` - fulfill [#fa-027]. public.
    # for this facet we default to true to let a modality client decide how /
    # whether to wire the action for itself (although we override this method
    # here in a sibling class..)

    def has_emit_facet
      true
    end

    def self.taxonomic_streams *a, &b
      API::Action::Emit[ self, :taxonomic_streams, a, b ]
    end

    def self.emits *a, &b
      API::Action::Emit[ self, :emits, a, b ]
    end

    def set_expression_agent x
      did = false
      @expression_agent ||= begin ; did = true ; x end
      did or fail "sanity - expression agent is write once."
      nil
    end

    def some_expression_agent
      @expression_agent or fail "sanity - expression agent was not set #{
        }set for this intance of #{ self.class }"
    end
    private :some_expression_agent

    #                      ~ services (section 3) ~

    def has_service_facet  # fullfil [#fa-027].
      false
    end

    define_singleton_method :services, & mutex[ -> *a do
      API::Action::Service[ self, a ]
    end, :services ]

    #                ~ parameters & normalization (section 4) ~

    def has_param_facet  # fulfill [#fa-027]
      false
    end

    Normalize_ = -> y, par_h do

      # mutates par_h. see client.rb [#fa-019]. [#bs-013] this func wants
      # to be a method, but we let it stay funcy for one hack for now..
      # this is a bit like [#sl-116] the one true algorithm.

      miss_a = nil ; r = false ; before = y.count
      field_box.each do |i, fld|
        x = ( par_h.delete i if par_h and par_h.key? i )
        accept_field_value fld, x
        if fld.has_normalizer || fld.has_default  # yes after
          x = field_normalize y, fld, x
        end
        fld.is_required && x.nil? and ( miss_a ||= [] ) << fld
      end
      begin
        Some_[ par_h ] and break( y << "undeclared #{
          }parameter(s) - (#{ par_h.keys * ', ' }) for #{ self.class }. #{
          }(declare it/them with `params` macro?)" )
        miss_a and break( y << "missing required parameter(s) - (#{
          }#{ miss_a.map( & :local_normal_name ) * ', ' }) #{
          }for #{ self.class }." )
        y.count > before and break
        r = true
      end while nil
      r
    end

    # (predecessor to the function chain was removed with this line #posterity)

    define_method :normalize, & Normalize_

  private

    def field_box
      EMPTY_FIELD_BOX_
    end
    EMPTY_FIELD_BOX_ = Services::Basic::Field::Box.new.freeze

    def accept_field_value fld, x
      ivar = fld.as_host_ivar
      instance_variable_defined? ivar and !
        instance_variable_get( ivar ).nil? and
          fail "sanity - ivar collision: #{ ivar }"
      instance_variable_set ivar, x
      nil
    end

    def field_normalize y, fld, x  # result per [#034]

      # any notices/errors written to `y`.
      # `x` is the input value and then result value of field `fld`.

      ivar = fld.as_host_ivar

      fld.has_default && x.nil? and
        x = instance_variable_set( ivar,
          instance_exec( & fld.default_value ) )  # always a proc

      if fld.has_normalizer
        true == (( p = fld.normalizer_value )) and
          p = method( :"normalize_#{ fld.local_normal_name }" )

        x = instance_exec y, x, -> normalized_x do
          instance_variable_set ivar, normalized_x
          nil
        end, & p
      end

      x  # the system wants to know the particular nil-ish-ness of x
    end

  public

    def absorb_params_using_message_yielder y, *a
      yy = Services::Basic::Yielder::Counting.new( & y.method( :<< ) )
      bx = field_box
      while a.length.nonzero?
        i = a.shift ; x = a.fetch 0 ; a.shift
        fld = bx.fetch i
        accept_field_value fld, x
        fld.has_normalizer and field_normalize yy, fld, x
      end
      yy.count.zero?
    end

    # `self.params` - rabbit hole .. er "facet" [#fa-013]
    # placed here because it fits in semantically with the `normalize`
    # step of the API Action lifecycle.

    def self.meta_params * x_a
      ( @_meta_param_a ||= [ ] ).concat x_a
      nil
    end

    class << self
      attr_reader :_meta_param_a
      private :_meta_param_a
    end

    define_singleton_method :params, & mutex[ ->( * a ) do
      # if you call this with empty `a`, it is the same as not calling it,
      # which gives you The empty field box above.
      if a.length.nonzero?
        # if it is a flat list of symbol names, that is shorthand for:
        if ! a.index { |x| ::Symbol != x.class }
          a.map! { |x| [ x, :arity, :one ] }
        end
        API::Action::Param[ self, a, _meta_param_a ]
        nil
      end
    end, :params ]

    # ~ facet 5.6x - metastories [#fa-035] ~

    Magic_Touch_.enhance -> { API::Action::Metastory.touch },
      [ self, :singleton, :public, :metastory ]

  end
end
