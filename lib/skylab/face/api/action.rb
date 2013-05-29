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
    #                        o->  `handle_events`             [#fa-017]
    #                         /
    #     [wired]      <-----o      things subscribe to listen to its events:
    #                  -o           now it has some @event_listeners.
    #                    \
    #                     o--->   `resolve_services`          [#fa-018]
    #                        /
    #     [plugged-in]  <---o        now it may have a @plugin_story and a
    #                   -o           @plugin_host_proxy, (and/or aribtrary
    #                     \          ivars if you are using `ingest`..))
    #                      \
    #                       o-->  `normalize`                 [#fa-019]
    #                         /
    #     [executable]  <----o       now basic normalization has been done
    #                   -o           with parameters, that is, everything that
    #                     \          can reasonably be done "declaratively"
    #                      \         (think DSL) instead of imperatively.
    #                       \        arbitrary business ivars set now.
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

    o = { }

    # `normalize` - documented in sibling file `client.rb` [#fa-019].
    #
    # beyond that:
    #   + we mutate `param_h`

    o[:normalize] = -> y, param_h do
      bork = -> msg do
        y << msg
        false
      end
      a = [ ]  # ( break down as needed )
      a << -> par_h do
        miss_a = nil
        field_box.each do |nn, fld|
          instance_variable_defined? fld.as_host_ivar and fail "sanity - #{
            } ivar collision: #{ fld.as_host_ivar }"
          vx = ( par_h.delete nn if par_h and par_h.key? nn )  # watch `vx`!
          instance_variable_set fld.as_host_ivar, vx           # it is used
          if fld.has_normalizer || fld.has_default             # for three
            vx = field_normalize y, fld, vx                    # different
          end                                                  # axes! [#034]
          ( miss_a ||= [] ) << fld if fld.is_required and vx.nil?
        end

        par_h and par_h.length.nonzero? and break bork[ "undeclared #{
          }parameter(s) - (#{ par_h.keys * ', ' }) for #{ self.class }. #{
          }(declare it/them with `params` macro?)" ]
        miss_a and break bork[ "missing required parameter(s) - (#{
          }#{ miss_a.map( & :normalized_name ) * ', ' }) #{
          }for #{ self.class }." ]
        true
      end

      a.reduce param_h do |x, f|
        instance_exec x, & f or break
      end  # call each function in order, but if ever a function's result is
      # falseish we break out of the loop. each function's (non-false-ish,
      # then) result becomes the argument passed to each next fuction's call.

      nil
    end

    define_method :normalize, & o[:normalize]  # public.

    -> do  # `field_box`          # here because it goes with normalize above.
      empty_field_box = Services::Basic::Field::Box.new.freeze
      define_method :field_box do empty_field_box end
      private :field_box
    end.call

    # `field_normalize` - result per [#034]

    def field_normalize y, fld, vx
      if fld.has_default && vx.nil?
        vx = instance_variable_set fld.as_host_ivar,
          instance_exec( & fld.default_value )
      end
      if fld.has_normalizer
        true == ( n_x = fld.normalizer_value ) and n_x =
          method( :"normalize_#{ fld.normalized_name }" )  # #todo cleanup
        vx = instance_exec y, vx, -> good_val do
          instance_variable_set fld.as_host_ivar, good_val
          nil
        end, & n_x
      end
      vx
    end
    private :field_normalize

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

    #  ~ facet 5.6 - metastories ~  ( was [#fa-035] )

    Magic_Touch_.enhance -> { API::Action::Metastory.touch },
      [ self, :singleton, :public, :metastory ]


    FUN = ::Struct.new( * o.keys ).new( * o.values )
  end
end
