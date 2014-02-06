module Skylab::Face

  class API::Action

    # this API::Action base class reifies the API API so that in your API
    # Action you can focus on your business logic and let everything else fit
    # together like magical greased lego's.
    #
    # everthing is of course experimental; but note it is a very designed,
    # thought-out experiment, with both eyes focused squarely on the big dream.

    # the API Action lifecycle :[#021]:
    #
    # the lifecycle of the API Action happens thusly (ignoring how we got
    # to an API Action instance for a moment):
    #
    #
    # [_this_state_] -> `will_receive_this_message` -> [_and_go_to_this_state_]
    #
    #     [primordial] --o          just been created. no ivars at all (as far
    #                     \         as this API knows). is is probably right
    #                      \        after a call to `new`     [#016]
    #                       \
    #                        o->   expression/event wiring    [#017]
    #                         /
    #                        /      resolves how to express itself: any
    #     [wired]      <---o        listeners subscribe to its events, and/or
    #                  -o           it gets an expression agent set.
    #                    \
    #                     o--->   `resolve_services`          [#018]
    #                        /
    #     [plugged-in]  <---o       it resolves fulfillment strategies for
    #                   -o          the services it declared as using, e.g
    #                     \         implemented by the [hl] plugin subsystem,
    #                      \
    #                       o-->  `normalize`                 [#019]
    #                         /
    #     [executable]  <----o       with its formal and/or actual parameters,
    #                   -o           with all its field-level assertions of
    #                     \          correctness that can be represented
    #                      \         declaratively (think DSL), assert them
    #                       \        now, result is soft failure or ivars.
    #                        \
    #                         o-> `execute`                   [#020]
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
    # class reveals (namely, `listeners_digraph`, `services` and `params`) which we present
    # below in the corresponding order and inline with the corresponding
    # instance method (callbacks) enumerated above. So, any time you wonder
    # where you might find something here, think to the lifecycle first. yay.
    #
    # we break this into numbered sections corresponding to the lifecycle
    # point. there is for now no "section 1" because we are avoiding
    # implementing an `initialize` here, wanting to leave that wide open for
    # the client, which we will one day document at [#016].
    # there will be no "section 5" because that is for you to write.
    #
    # [1] - and/or it get an expression agent set

    #                       ~ events (section 2) ~

    mutex = MetaHell::Module::Mutex  # (we frequently want the facet-y DSL
    # calls to be processed atomic-ly, monadic-ly, er: zero or once each;
    # for ease of implementation. can be complexified as needed.)

    # `has_emit_facet` - fulfill [#027]. public.
    # for this facet we default to true to let a modality client decide how /
    # whether to wire the action for itself (although we override this method
    # here in a sibling class..)

    def has_emit_facet
      true
    end

    def self.taxonomic_streams *a, &b
      API::Action::Emit[ self, :taxonomic_streams, a, b ]
    end

    def self.listeners_digraph *a, &b
      API::Action::Emit[ self, :listeners_digraph, a, b ]
    end

    def set_expression_agent x
      did = false
      @expression_agent ||= begin ; did = true ; x end
      did or fail "sanity - expression agent is write once."
      nil
    end

    attr_reader :expression_agent

  private

    def some_expression_agent
      @expression_agent or fail "sanity - expression agent was not set #{
        }set for this intance of #{ self.class }"
    end

    private :expression_agent
    alias_method :any_expression_agent, :expression_agent

  public

    #                      ~ services (section 3) ~

    def has_service_facet  # fullfil [#027].
      false
    end

    define_singleton_method :services, & mutex[ -> *a do
      API::Action::Service[ self, a ]
    end, :services ]

    #                ~ parameters & normalization (section 4) ~

    def has_param_facet  # fulfill [#027]
      false
    end

    # (predecessor to the function chain was removed with this line #posterity)

  private

    def field_box
      EMPTY_FIELD_BOX_
    end
    EMPTY_FIELD_BOX_ = Library_::Basic::Field::Box.new.freeze

  public

    def absorb_params_using_message_yielder y, *a
      yy = Library_::Basic::Yielder::Counting.new( & y.method( :<< ) )
      bx = field_box
      while a.length.nonzero?
        i = a.shift ; x = a.fetch 0 ; a.shift
        fld = bx.fetch i
        field_value_notify fld, x
        fld.has_normalizer and field_normalize yy, fld, x
      end
      yy.count.zero?
    end

    # `self.params` - rabbit hole .. er "facet" [#013]
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
        API::Params_.enhance_client_with_param_a_and_meta_param_a(
          self, a, _meta_param_a )
        nil
      end
    end, :params ]

    API::Normalizer_.enhance_client_class self, :conventional
      # needed whether params or no

    # ~ facet 5.6x - metastories [#035] ~

    Magic_Touch_.enhance -> { API::Action::Metastory.touch },
      [ self, :singleton, :public, :metastory ]

  end
end
