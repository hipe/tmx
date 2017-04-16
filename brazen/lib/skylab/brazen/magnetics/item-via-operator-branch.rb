module Skylab::Brazen

  class Magnetics::Item_via_OperatorBranch < Common_::MagneticBySimpleModel  # :[#085]

    #   - for the familiar (and now universal) interface of an operator
    #     branch, we want to offer this as default implementation of
    #     `procure`, which is like a `lookup_softly` that takes a listener
    #     and emits an emission suitable for UI on failure.
    #
    #   - really this doesn't do much other than wrap a call to
    #     `lookup_softly` that leverages another magnetic on failure.

    # -
      def initialize
        @primary_channel_symbol = nil
        super
      end

      attr_writer(
        :listener,
        :needle_item,
        :operator_branch,
        :primary_channel_symbol,
      )

      def execute

        lr = @operator_branch.lookup_softly @needle_item.normal_symbol
          # (might change the above to pass the whole item)
          # ("lr" stands for "loadable reference")

        if ! lr
          __when
        end
        lr
      end

      def __when

        Home_.lib_.zerk::ArgumentScanner::When::UnknownBranchItem.call_by do |o|

          o.strange_value_by = -> do
            @needle_item.normal_symbol
          end

          o.available_item_internable_stream_by = -> do
            @operator_branch.to_loadable_reference_stream  # ..
          end

          o.shape_symbol = :business_item
          o.terminal_channel_symbol = :business_item_not_found
          o.primary_channel_symbol = @primary_channel_symbol  # nil OK
          o.listener = @listener
        end
        NIL
      end
    # -

    # ==

    class FYZZY

      # (this node is an interesting case study)

      class << self

        def _call kn, stream_builder, & oes_p

          o = new( & oes_p )

          o.found_map = -> x do
            x.dup  # flyweights
          end

          o.name_map = -> x do
            x.name.as_slug
          end

          o.qualified_knownness = kn

          o.stream_builder = stream_builder

          o.execute
        end

        alias_method :[], :_call
        alias_method :call, :_call
      end  # >>

      def initialize & oes_p

        @be_case_sensitive = false
        @found_map = nil
        @levenshtein_number = nil
        @name_map = nil
        @on_event_selectively = oes_p
        @success_map = nil
        @suffixed_contextualization_message_proc = nil
        @target_map = nil
      end

      attr_writer(

        :found_map,  # each candidate that is matched off the input stream
        # (even when more than one) is mapped through this optional mapper.
        # this is typically used to un-flyweight a flyweight, so error-
        # reporting works in cases of ambiguity.

        :levenshtein_number,  # if provided, will be used to reduce the
        # number of items in the "did you mean [..]?"-type expressions.

        :name_map,  # how do we resolve a string-like name from each
        # candidate item? if not provided, the assumption is that the
        # candidate items are string-like (or perhaps only that they are
        # `=~` compatible.)

        :on_event_selectively,  # (required) a [#ca-001] selective listener
        # proc to call in case not exactly one match can be resolved.

        :qualified_knownness,  # (required) wrap your target value in
        # this [#ca-004] which associates a name function with the value.

        :be_case_sensitive,  # case sensitivity is OFF by default

        :stream_builder,  # (required) build the candidate stream. we need
        # a builder and not the stream itself because in case one match
        # is not resolved, we need the whole stream anew to report on it.

        :success_map,  # if exactly one match is resolved from the stream
        # of items, before it is presented as the final result it will be
        # mapped through this proc if provided.

        :target_map,  # for the purposes of matching each candidate against
        # the target value (in the qkn), alter the target in this way


        :suffixed_contextualization_message_proc,
      )

      def set_qualified_knownness_value_and_symbol x, sym
        @qualified_knownness =
          Common_::Qualified_Knownness.via_value_and_symbol x, sym
        NIL_
      end

      def set_qualified_knownness_value_and_name x, nf
        @qualified_knownness =
          Common_::Qualified_Knownness.via_value_and_association x, nf
      end

      def execute

        x = @qualified_knownness.value_x

        if @target_map
          x = @target_map[ x ]
        end

        o = Home_.lib_.basic::Fuzzy.begin
        o.string = x
        o.stream = @stream_builder.call
        o.candidate_map = @name_map
        o.result_map = @found_map
        o.be_case_sensitive = @be_case_sensitive
        a = o.execute

        case 1 <=> a.length
        when 0
          x = a.fetch 0
          if @success_map
            @success_map[ x ]
          else
            x
          end

        when 1
          __not_found

        when -1
          ___ambiguous a
        end
      end

      def ___ambiguous a

        @on_event_selectively.call :error, :ambiguous_property do
          Home_.lib_.fields::Events::Ambiguous.new(  # CUSTOM #[#co-070.2]
            a,
            @qualified_knownness.value_x,
            @qualified_knownness.name,
            & @name_map
          )
        end

        UNABLE_
      end

      def __not_found

        @on_event_selectively.call :error, :extra_properties do

          kn = @qualified_knownness
          name_map = @name_map
          _st = @stream_builder.call

          did_you_mean_s_a = _st.map_by do | ent |
            name_map[ ent ]
          end.to_a

          d = @levenshtein_number
          if d

            _Lev = Home_.lib_.human::Levenshtein

            a = _Lev.via(
              :item_string, kn.value_x,
              :items, did_you_mean_s_a,
              :closest_N_items, d,
            )

            if a && a.length.nonzero?
              did_you_mean_s_a = a
            end
          end

          Home_.lib_.fields::Events::Extra.with(
            :unrecognized_token, kn.value_x,
            :did_you_mean_tokens, did_you_mean_s_a,
            :noun_lemma, kn.name.as_human,
            :suffixed_prepositional_phrase_context_proc,
              @suffixed_contextualization_message_proc,
          )
        end

        UNABLE_
      end
    end

    # ==
    # ==
  end
end
# #tombstone-B (can be temporary) "collection actor"
# #history: "byte stream identifiers" extracted from here to [ba]
