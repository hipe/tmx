module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::JSON

      class Interpret  # notes in [#083]:on-JSON-interpretation

        def initialize & p

          @context_x = nil
          @_oes_p = p
        end

        def prepend_more_specific_context_by & desc_p

          @context_x = Home_.lib_.basic::List::Linked[ @context_x, desc_p ]
          NIL_
        end

        attr_writer(
          :ACS,
          :context_x,
          :JSON,
        )

        def execute

          _x = Home_.lib_.JSON.parse(
            remove_instance_variable( :@JSON ),
            symbolize_names: true,
          )

          rec = Recurse_.new(
            _x,
            remove_instance_variable( :@context_x ),
            @ACS,
            & @_oes_p )

          rec._execute
        end
      end

      class Interpret::Recurse_

        def initialize x, context_x, acs, & p
          @ACS = acs
          @context_x = context_x
          @_oes_p = p
          @_x = x
        end

        def _execute

          ok = __resolve_pair_stream
          ok && __prepare_to_accept_values
          ok &&= __lineup
          ok &&= __go_deep
          ok &&= __go_shallow
          ok && __flush
        end

        def __prepare_to_accept_values

          @_did_any_assignments = false

          p = ACS_::Interpretation_::Writer[ @ACS ]

          @_accept_qkn = -> qkn do

            @_did_any_assignments = true
            @_accept_qkn = p
            p[ qkn ]
          end

          NIL_
        end

        def __resolve_pair_stream

          x = remove_instance_variable :@_x
          if x.respond_to? :each_pair
             @_pair_stream = Home_.lib_.basic::Hash.pair_stream x
             ACHIEVED_
          else
            Modalities::JSON::When_[ x, self, :Shape ]
          end
        end

        def __lineup

          deeps = nil
          shallows = nil

          bxish = ___build_boxish
          st = remove_instance_variable :@_pair_stream

          begin

            pair = st.gets
            pair or break
            sym = pair.name_symbol
            x = pair.value_x

            had = true
            qkn = bxish.fetch sym do
              had = false
            end

            if ! had
              has_extra = true
              break
            end

            _is = qkn.association.model_classifications.looks_compound

            _category = if _is
              ( deeps ||= [] )
            else
              ( shallows ||= [] )
            end

            _category.push qkn.new_with_value x

            redo
          end while nil

          if has_extra
            __when_extra sym, st
          else
            @_boxish = bxish
            @_unorderd_deeps = deeps
            @_unorderd_shallows = shallows
            ACHIEVED_
          end
        end

        def ___build_boxish

          _st = ACS_::For_Serialization::To_stream[ @ACS ]

          _st.flush_to_immutable_with_random_access_keyed_to_method(
            :name_symbol )
        end

        def __when_extra sym, st

          extra_a = []
          begin
            extra_a.push sym
            pair = st.gets
            pair or break
            extra_a.push pair.name_symbol
            redo
          end while nil
          Modalities::JSON::When_[ extra_a, self, :Extra ]
          UNABLE_
        end

        def __go_deep

          if @_unorderd_deeps
             ___do_go_deep
          else
            ACHIEVED_
          end
        end

        def ___do_go_deep

          a = remove_instance_variable :@_unorderd_deeps
          _sort a
          ok = true
          a.each do | qkn |
            ok = ___go_deep_on qkn
            ok or break
          end
          ok
        end

        def ___go_deep_on qkn

          wv = ___resolve_branch_component_recursively qkn
          if wv

            _qkn_ = qkn.new_with_value wv.value_x

            @_accept_qkn[ _qkn_ ]

            ACHIEVED_
          else
            wv
          end
        end

        def ___resolve_branch_component_recursively qkn

          # (evntually, fall back on using the normal constructors)

          _on_component = if qkn.is_effectively_known

            -> acs do

              # the model itself does the actual contsruction, and once we
              # get this "empty" component, we can populate it by recursing

              ___recurse_into acs, qkn
            end
          else

            # experimentally, the model can build from null if it
            # accepts `nil` for the proc

            NIL_
          end

          asc = qkn.association

          @_did_resolve_event_model ||= _resolve_event_model

          if :cold == @_ACS_event_model

            use_p = @_x_p

            # if the ACS uses the "cold" model, use the client (call) handler

          else

            # for under what we assume is the "hot" model, build the
            # "special" handler explicitly so we have a handle on it. this
            # is the same handler that would be created by the builder by
            # default, but with a handle on it we can pass this handler to
            # the recursions so that when there is a failure "down deep",
            # the event can be contextualized..

            use_p = ACS_::Interpretation::Component_handler[ asc, @ACS ]
          end

          @_component_oes_p = use_p

          o = ACS_::Interpretation_::Build_value.new(
            _on_component, asc, @ACS, & use_p )

          o.construction_method = :interpret_compound_component

          o.execute
        end

        def ___recurse_into cmp, qkn

          _desc_p = -> do

            _nf = qkn.association.name

            "in #{ ick _nf.as_lowercase_with_underscores_symbol.id2name }"
          end

          _ctx_ = ::Skylab::Basic::List::Linked[ @context_x, _desc_p ]

          _x = qkn.value_x

          o = self.class.new( _x, _ctx_, cmp, & @_component_oes_p )

          _xx_ = o._execute

          # (hi.)

          _xx_
        end

        def __go_shallow

          if @_unorderd_shallows
            ___do_go_shallow
          else
            ACHIEVED_
          end
        end

        def ___do_go_shallow

          a = remove_instance_variable :@_unorderd_shallows
          _sort a
          ok = true
          a.each do | qkn |
            ok = ___go_shallow qkn
            ok or break
          end
          ok
        end

        def ___go_shallow qkn

          # accept each of these in a batch manner. we don't bother with
          # UOW any more: we are in the middle of a depth-first building
          # of a compound component.

          _arg_st = ACS_::Interpretation::Value_Popper[ qkn.value_x ]

          # using the "value popper" (a shortlived proxy that looks like
          # a stream but only wraps one value) is our way of leveraging
          # the same validation & normalization used in "edit sessions"
          # for unserialization.. (interface experimental)

          _asc = qkn.association

          @_did_resolve_event_model ||= _resolve_event_model

          wv = ACS_::Interpretation_::Build_value[ _arg_st, _asc, @ACS, & @_x_p ]

          if wv

            # the name value pair that used to hold e.g "color":"red"..

            _qkn_ = qkn.new_with_value( wv.value_x )

            # .. now has for its value a Color object (for example)

            @_accept_qkn[ _qkn_ ]

            ACHIEVED_
          else
            wv
          end
        end

        def _resolve_event_model

          # read [#085]:#Event-models. this is the first codepoint where we
          # must know which event-model is being used, because it determines
          # how the component is built - do we pass the construction method
          # a "special" handler or the raw "modality" handler? the ACS (not
          # the component) decides whether/how to bind the component.

          sym = @ACS.component_event_model
          @_ACS_event_model = sym

          if :cold == sym

            any_p = @_oes_p

            # under the cold model, the component constructor is passed
            # the exact same handler that we got from modality space.
          end

          # for any value other than `cold` we assume `hot`, which if this
          # is not what it is, it will probably result in noisy failure.
          # by passing no block (the `nil` below) to the component builder,
          # it will assume the hot model.

          @_x_p = any_p
          ACHIEVED_
        end

        def _sort qkn_a

          # processing the assignments in "formal order" as opposed to
          # received order helps us normalize failures: two different JSON
          # payloads with a different ordering of their members but the same
          # underlying structure will in this way be processed identically,
          # making unserialization errors consistent with respect to content,
          # not surface representation.

          bx = @_boxish

          qkn_a.sort_by do | qkn |

            bx.index qkn.name_symbol
          end
          NIL_
        end

        def __flush

          if @_did_any_assignments
            @ACS
          else
            Modalities::JSON::When_[ self, :Empty ]
          end
        end

        # ~ for "when"s

        def context_x
          @context_x
        end

        def on_event_selectively
          @_oes_p
        end
      end
    end
  end
end
