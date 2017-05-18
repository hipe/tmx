module Skylab::Brazen

  class Magnetics::Item_via_OperatorBranch < Common_::MagneticBySimpleModel  # :[#085]

    #   - for the familiar (and now universal) interface of an operator
    #     branch, we want to offer this as default implementation of
    #     `procure`, which is like a `lookup_softly` that takes a listener
    #     and emits an emission suitable for UI on failure.
    #
    #   - really this doesn't do much other than wrap a call to
    #     `lookup_softly` that leverages another magnetic on failure.
    #
    #   - oh also it can dispatch to a fuzzy lookup with default settings

    # -
      def initialize
        @be_fuzzy = false
        @item_lemma_symbol = nil
        @primary_channel_symbol = nil
        super
      end

      def will_be_fuzzy
        @be_fuzzy = true
      end

      attr_writer(
        :item_lemma_symbol,
        :listener,
        :needle_item,
        :operator_branch,
        :primary_channel_symbol,
      )

      def execute

        lr = @operator_branch.lookup_softly @needle_item.normal_symbol
          # (might change the above to pass the whole item)
          # ("lr" stands for "loadable reference")

        if lr
          lr
        elsif @be_fuzzy
          __attempt_fuzzy
        else
          __when_not_found
        end
      end

      def __attempt_fuzzy

        _qkn = __qualified_knownness

        _maybe_item = FYZZY.call_by do |o|

          o.qualified_knownness = _qkn

          o.string_via_item_by do |item|
            item.natural_key_string  # ..
          end

          o.item_stream_by do
            @operator_branch.to_loadable_reference_stream
          end

          o.string_via_target = -> item do
            item.natural_key_string  # ..
          end

          o.levenshtein_number = 3
            # reduce the "did you mean.." to near this amount
            # if this is nil or not set, no "splay" is expressed on failure
            # -1 means "splay all of them"
            # we have it hardcoded to exercise the levenshtein'ing but we can expose it whenever

          o.result_via_found = nil  # no need to map the single found item to anything

          o.result_via_matching = nil  # no need to map every matching item to anything

          # o.be_case_sensitive  # by default it is case insensitive

          o.suffixed_contextualization_message_proc = nil  # pass-thru

          o.listener = @listener
        end

        _maybe_item  # hi.
      end

      def __qualified_knownness
        _sym = @item_lemma_symbol || :item
        Common_::QualifiedKnownKnown.via_value_and_symbol @needle_item, _sym
      end

      def __when_not_found

        Home_.lib_.zerk::ArgumentScanner::When::UnknownBranchItem.call_by do |o|

          o.strange_value_by = -> do
            @needle_item.normal_symbol
          end

          o.available_item_internable_stream_by = -> do
            @operator_branch.to_loadable_reference_stream  # ..
          end

          o.item_lemma_symbol = @item_lemma_symbol  # nil OK
          o.shape_symbol = :business_item
          o.terminal_channel_symbol = :business_item_not_found
          o.primary_channel_symbol = @primary_channel_symbol  # nil OK
          o.listener = @listener
        end
        NIL
      end
    # -

    # ==

    class FYZZY < Common_::MagneticBySimpleModel

      # (this node is an interesting case study)

      # it adds a layer of UI around its dependency

      # (at #tombstone-B.1 we changed this to a magnetic by simple model,
      # at which time we broke indentation so we could keep history.)

      def initialize
        @be_case_sensitive = false
        @levenshtein_number = nil
        @result_via_found = nil
        @result_via_matching = nil
        @string_via_item = nil
        @string_via_target = nil
        @suffixed_contextualization_message_proc = nil
        super
      end

      def will_be_case_sensitive
        @be_case_sensitive = true ; nil
      end

      def item_stream_by & p
        @item_stream_proc = p ; nil
      end

      def result_via_found_by & p
        @result_via_found = p ; nil
      end

      def string_via_item_by & p
        @string_via_item = p ; nil
      end

      attr_writer(

        :result_via_matching,  # each candidate that is matched off the input stream
        # (even when more than one) is mapped through this optional mapper.
        # this is typically used to un-flyweight a flyweight, so error-
        # reporting works in cases of ambiguity.

        :levenshtein_number,  # if provided, will be used to reduce the
        # number of items in the "did you mean [..]?"-type expressions.

        :string_via_item,  # how do we resolve a string-like name from each
        # candidate item? if not provided, the assumption is that the
        # candidate items are string-like (or perhaps only that they are
        # `=~` compatible).
        #
        # this function is never used against the "needle" item.

        :listener,  # (required) a [#ca-001] selective listener
        # proc to call in case not exactly one match can be resolved.

        :qualified_knownness,  # (required) wrap your target value in
        # this [#ca-004] which associates a name function with the value.

        :be_case_sensitive,  # case sensitivity is OFF by default

        :item_stream_proc,  # (required) build the candidate stream. we need
        # a builder and not the stream itself because in case one match
        # is not resolved, we need the whole stream anew to report on it.

        :result_via_found,  # if exactly one match is resolved from the stream
        # of items, before it is presented as the final result it will be
        # mapped through this proc if provided.
        #
        # if `result_via_matching` was also used, the subject map is applied
        # in addition to that one (not instead of it); and is applied to its
        # result.

        :string_via_target,  # for the purposes of matching each candidate against
        # the target value (in the qkn), alter the target in this way

        :suffixed_contextualization_message_proc,  # (pass-thru)
      )

      def set_qualified_knownness_value_and_symbol x, sym
        @qualified_knownness =
          Common_::QualifiedKnownKnown.via_value_and_symbol x, sym
        NIL_
      end

      def set_qualified_knownness_value_and_name x, nf
        @qualified_knownness =
          Common_::QualifiedKnownKnown.via_value_and_association x, nf
      end

      def execute

        @_use_string_via_item = @string_via_item || IDENTITY_
        @_use_string_via_target = @string_via_target || IDENTITY_

        _s = @_use_string_via_target[ @qualified_knownness.value ]

        a = Home_.lib_.basic::Fuzzy.call_by do |o|
          o.string = _s
          o.stream = @item_stream_proc.call
          o.string_via_item = @string_via_item
          o.result_via_matching = @result_via_matching
          o.be_case_sensitive = @be_case_sensitive
        end

        case 1 <=> a.length
        when 0
          x = a.fetch 0
          if @result_via_found
            @result_via_found[ x ]
          else
            x
          end

        when 1
          __when_not_found

        when -1
          __when_ambiguous a
        end
      end

      def __when_ambiguous a

        @listener.call :error, :ambiguous_property do
          Home_.lib_.fields::Events::Ambiguous.new(  # CUSTOM #[#co-070.2]
            a,
            @qualified_knownness.value,
            @qualified_knownness.name,
            & @string_via_item
          )
        end

        UNABLE_
      end

      def __when_not_found

        qkn = @qualified_knownness

        @listener.call :error, :item_not_found do

          d = @levenshtein_number
          if d

            st = @item_stream_proc.call

            string_via_item = @string_via_item
            if string_via_item
              st = st.map_by do |item|
                string_via_item[ item ]  # hi.
              end
            end

            if -1 == d

              _Lev = Home_.lib_.human::Levenshtein

              a = _Lev.via(
                :item_string, qkn.value,
                :items, st,
                :closest_N_items, d,
              )
            else
              a = st.to_a
            end
          end

          if a && a.length.nonzero?
            did_you_mean_s_a = a
          end

          _needle_as_string = @_use_string_via_target[ qkn.value ]

          Home_.lib_.fields::Events::Extra.with(
            :unrecognized_token, _needle_as_string,
            :did_you_mean_tokens, did_you_mean_s_a,
            :noun_lemma, qkn.name.as_human,
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
# #tombstone-B.1 (can be temporary)
# #tombstone-B (can be temporary) "collection actor"
# #history: "byte stream identifiers" extracted from here to [ba]
