module Skylab::Fields

  module Event_

    Home_::Events::Extra = Common_::Event.prototype_with(

      :extra_properties,

      # (see #here-1 about 2 others)
      :did_you_mean_tokens, nil,
      :prefixed_conjunctive_phrase_context_proc, nil,
      :prefixed_conjunctive_phrase_context_stack, nil,
      :suffixed_prepositional_phrase_context_proc, nil,
      :noun_lemma, DEFAULT_PROPERTY_LEMMA_,  # string or symbol OK
      :adjective_lemma, "unrecognized",
      :levenschtein_limit, 3,
      :invite_to_action, nil,
      :exception_class_by, -> { Home_::ArgumentError },
      :error_category, :argument_error,
      :ok, false,

    ) do |y, o|
      otr = o.dup
      otr.extend Home_::Events::Extra::ExpressionMethods___
      otr.__init( y, self ).express
    end

    class Home_::Events::Extra

      module ExpressionMethods___

        def __init y, expag
          @_line_downstream = y ; @_expression_agent = expag
          @_words = [] ; self
        end

        def express
          __express_first_line
          __express_second_line
          remove_instance_variable :@_line_downstream
        end

        def __express_first_line

      # e.g: "couldn't wizzle - unrecognized property 'foo' in blah blah"

          _express_any_this :@prefixed_conjunctive_phrase_context_proc

          s = @adjective_lemma
          s and @_words.push s

          __express_splay @_words, self

          _express_any_this :@suffixed_prepositional_phrase_context_proc

          __flush_words
        end

        def __express_splay a, o

          @_expression_agent.simple_inflection do

            # -

        # "unrecognized property 'mlem'" | "unrecogized properties 'mlem' and 'baz'"

        _scn = Scanner_[ o.unrecognized_tokens ]

        buff = oxford_join _scn do |x|  # determine the count
          ick_mixed x
        end

            # -

            s = o.noun_lemma
            s and a.push n s  # use the count
            a.push buff
          end
        end

        def __express_second_line

          if @did_you_mean_tokens
            __do_express_second_line
          end
        end

        def __do_express_second_line

          if __has_only_one_unrecognized_item &&
            __has_one_or_more_did_you_means &&
            __the_number_of_did_you_means_exceeds_a_levenstein_limit &&
            __the_unrecognized_thing_is_a_token_type &&
            true
          then
            _x_a = __reduce_using_levenshtein
            _express_did_you_mean _x_a
          else
            _express_did_you_mean @did_you_mean_tokens
          end
        end

        def __reduce_using_levenshtein  # #coverpoint1.7

          # reduce the long list to a short list by finding the N closest
          # matches using levenshtein distance. internally the remote
          # facility needs the items to be strings but we need the resultant
          # list to be of the same items we started with (strings or symbols,
          # probably).

          _x = @did_you_mean_tokens.fetch 0

          if _x.respond_to? :id2name
            stringify_by = :id2name.to_proc
          else
            stringify_by = -> x { x }  # IDENTITY_
          end

          _wat = Home_.lib_.human::Levenshtein.via(
            :item_string, @_compare_against_string,
            :items, @did_you_mean_tokens,
            :aggregate_by, -> x_a do
              x_a  # hi. #todo
            end,
            # :map_result_items_by, map_result_items_by,
            :stringify_by, stringify_by,  # when comparing
            :closest_N_items, @levenschtein_limit,
          )
          _wat  # #hi. #todo
        end

        def __the_unrecognized_thing_is_a_token_type
          x = @unrecognized_tokens.fetch 0
          if x.respond_to? :ascii_only?
            @_compare_against_string = x ; true
          elsif x.respond_to? :id2name
            @_compare_against_string = x.id2name ; true
          end
        end

        def __the_number_of_did_you_means_exceeds_a_levenstein_limit
          if @levenschtein_limit
            @levenschtein_limit < @did_you_mean_tokens.length
          end
        end

        def __has_one_or_more_did_you_means
          @did_you_mean_tokens.length.nonzero?
        end

        def __has_only_one_unrecognized_item
          1 == @unrecognized_tokens.length
        end

        def _express_did_you_mean sym_a  # actually sym_a or s_a

          y = @_line_downstream
          @_expression_agent.calculate do
            # -

        _m = respond_to?( :code ) ? :code : :ick_mixed
        code = method _m

        simple_inflection do
          buff = "did you mean "
          oxford_join buff, Scanner_[ sym_a ], " or " do |sym|
            code[ sym ]
          end
          buff << "?"
          y << buff
        end
            # -
          end
        end

        def _express_any_this ivar
          p = instance_variable_get ivar
          if p
            @_expression_agent.calculate @_words, self, & p
          end
        end

        def __flush_words

          @_line_downstream << @_words.join( SPACE_ )
          @_words.clear ; nil
        end
      end

      # - #here-1

        def unrecognized_token=
          _same :push
        end

        def unrecognized_tokens=
          _same :concat
        end

        def _same m
          _x = @_argument_scanner_.gets_one
          ( @unrecognized_tokens ||= [] ).send m, _x ; KEEP_PARSING_
        end

        def unrecognized_token
          @unrecognized_tokens.fetch 0
        end

        attr_reader :unrecognized_tokens
      # -

      # ==
      # ==
    end
  end
end
# #tombstone (can be temporary) used to be a custom [#co-070.2]
