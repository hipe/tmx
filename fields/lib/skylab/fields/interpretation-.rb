module Skylab::Fields

  module Interpretation_

    class AssociationInterpreter < Common_::SimpleModel  # see [#017]

      # this implements the interpretation of associations through an
      # injected grammar, in a way that is spiritually similar to how we do
      # in [#029.A] with the new "E.K" system (but whereas there we use [pa]
      # to parse, here we do the parsing ourselves.)

      # use the "meta associations module" to interpret each association.

      # brazenly, in this edition we now attempt this through normal
      # normalization #history-B

      def initialize
        yield self
        MutablePrimaryReceiver___.new self do |p|
          @__INTERPRET = p
        end.extend @meta_associations_module
      end

      attr_writer(
        :association_class,  # sure you betcha
        :indexing_callbacks,  # not used for as many things but still used [#002.4]
        :meta_associations_module,  # new in this take
      )

      def interpret_association_ k, scn

        @association_class.new k do |asc|

          if scn
            __meta_normalize asc, scn
          end
        end
      end

      def __meta_normalize asc, scn

        # (we call it "meta-normalize" because you're not normalizing an
        # argument expression, you're normalizing an association expression.)

        _ok = Home_::Normalization.call_by do |o|

          o.argument_scanner = scn

          o.entity_as_ivar_store = asc

          o.receive_association_source_ self  # act like one #here1

          @current_normalization_ = o
        end

        true == _ok || self._SANITY ; nil  # because no listener, all failures should be hard
      end

      def flush_injection_for_argument_traversal sct, n11n  # #here1

        sct.association_soft_reader = method :__read_meta_association_softly  # first this

        sct.did_you_mean_by = method :__did_you_mean_tokens  # if it doesn't work out, this

        sct.argument_value_parser = method :__parse_this_meta_association  # otherwise this

        sct.extroverted_diminishing_pool = NO_LENGTH_  # [#002.H.1.1]
        NIL
      end

      def __read_meta_association_softly k

        if @meta_associations_module.method_defined? k
          @_yes = true ; k

        elsif LEADS_WITH_UNDERSCORE_RX___ =~ k
          @_yes = false ; k

        else
          NOTHING_  # hi. #cov2.11
        end
      end

      # ~ #cov2.11

      def __did_you_mean_tokens
        @meta_associations_module.instance_methods  # neet
      end

      def use_this_noun_lemma_to_mean_attribute
        "meta-association"
      end

      # ~

      def __parse_this_meta_association _

        _ == @current_normalization_.argument_scanner.head_as_is || self._SANITY  # #todo

        if @_yes
          @__INTERPRET[ @current_normalization_ ]
        else
          @indexing_callbacks.add_to_the_custom_index__ @current_normalization_
          KEEP_PARSING_
        end
      end
    end

    # ==

    class MutablePrimaryReceiver___

      # the instance of this class is extended with the one "meta
      # associations module", which implements the collection of recognized
      # meta-associations (and accompanying logic to interpret them).

      # whether that module itself has other modules in its ancestor chain
      # is none of our business, but hypothetically it could (not covered).

      # weirdly for any class ever, totally off limits in this class is:
      #   - the method namespace of this module (except `initialize`) AND
      #   - the ivar namespace!
      #
      # as such the only client of this class communicates with it strictly
      # through a block that the subject instance yields in its construction.

      # deconstructing its name "mutable" "primary" "reciever":
      #
      #   - the fact that it is mutable is a dodgy "optimization"
      #
      #   - "primary receiver" because it gets sent the [#ze-053.2]
      #     "primaries" of modifiers that define characteristics of the
      #     association.

      def initialize ai  # association interpreter

        _work = -> n11n do

          as = n11n.argument_scanner

          _meta_association_name_symbol = as.gets_one  ##spot1-1 ("parsimony")

          # the below two are used so frequently, we set them as ivars here
          # to make association interpretation code less magic looking but..

          @_meta_argument_scanner_ = as
          @_association_ = n11n.entity

          # in 1x only (for [#002.9] feature island) we need the whole n11n.
          # under purist parsimony we would use the below ivar to derive the
          # above 2 objects lazily thru methods not ivars. but those reasons.

          @_META_NORMALIZATION_ = n11n

          __send__ _meta_association_name_symbol

          # (interpreters like the one called above are written assuming
          # that we only ever fail hard so result is decidedly unreliable)

          KEEP_PARSING_
        end

        yield _work

        @_association_interpreter_ = ai
      end
    end

    # ==

    class AssociationInterpreter  # (re-open)

      # -- exposures for the meta-association implementation

      def entity_class_enhancer_by_ & p

        index_statically_ :this_is_an_enhancer
        @current_normalization_.entity.add_enhance_entity_class_proc__ p
        NIL
      end

      def index_statically_ meta_k
        @indexing_callbacks.add_to_the_static_index_ _current_association_name_symbol, meta_k
      end

      def _current_association_name_symbol
        @current_normalization_.entity.name_symbol
      end

      def current_normalization_
        @current_normalization_  # hi. for the (2) encapsulated m.a libs only
      end

      attr_reader(
        :indexing_callbacks,
      )
    end

    # ==

    LEADS_WITH_UNDERSCORE_RX___ = /\A_/  # this rule is not strictly
      # necessary but it guards against typos & API mis-matches

    # ==

    class ArgumentValueInterpretation_DSL

      # each proc produced by
      #
      #   - `argument_value_producer_by_`,
      #   - `argument_value_consumer_by_`, and
      #   - `argument_interpreter_by_`
      #
      # is executed in the context of an instance of the subject.
      # one such instance is created per occurrence of association
      # surface expression in the argument stream.

      def initialize listener=nil, asc, n11n
        @_argument_scanner = nil
        @_association_ = asc
        @__listener = listener
        @_normalization_ = n11n  # changing to this style
        # for now, don't freeze only because #this-1
      end

      def mutate_for_redirect_ x, asc  # :#this-1 is why we didn't freeze
        @_argument_scanner = Argument_scanner_via_value[ x ]
        @_association_ = asc ; nil
      end

      # -- facility "C" replacement

      def as_DSL_flush_commonly_for_interpretation__  # result in kp

        x = calculate( & @_association_.produce_argument_value_by__ )

        if x.nil? && _defaulting_exists
          x = _default_value_that_hopefully_didnt_fail  # :#coverpoint1.9
        end

        calculate x, @__listener, & @_association_.consume_argument_value_by__
      end

      def __as_DSL_flush_commonly_for_normalize_in_place_  # result in kp

        if __any_stored_value_is_effectively_nil

          if _defaulting_exists
            __change_working_value_to_default_value
          end

          # (no ad-hoc normalization (why?))

          __maybe_write
        else
          KEEP_PARSING_  # if it is set to any non-nil value, leave it alone ([#012.5.3])
        end
      end

      # -- exposures

      alias_method :calculate, :instance_exec

      def write_association_value_ x

        @_normalization_.valid_value_store.write_via_association x, @_association_
        KEEP_PARSING_  # in-memory writes may not fail. provided as convenience.
      end

      def argument_scanner_
        @_argument_scanner || @_normalization_.argument_scanner
      end

      # -- common language for old facility "C"

      def __maybe_write

        if __is_required
          if _working_value_is_nil
            __memo_this_missing_required_association
          else
            _write
          end
        elsif _working_value_is_nil
          if ! @__was_defined
            _write  # [#012.J.4] nilify
          end
        else
          _write
        end

        KEEP_PARSING_
      end

      def __any_stored_value_is_effectively_nil

        vvs = @_normalization_.valid_value_store  # :#spot1-2

        if vvs.knows_value_for_association @_association_
          was_defined = true
          x = vvs.dereference_association @_association_
        end

        if x.nil?
          @__valid_value_store = vvs
          @__was_defined = was_defined
          @_working_value = nil
          TRUE
        end
      end

      # -- defaulting

      def _defaulting_exists
        @_association_.default_proc  # i.e `Has_default`
      end

      def __change_working_value_to_default_value
        # (violate [#012.E.2] (defaulting can fail) (legacy, KISS))
        @_working_value = _default_value_that_hopefully_didnt_fail
        NIL
      end

      def _default_value_that_hopefully_didnt_fail
        @_association_.default_proc.call
      end

      # -- ad-hoc normalization NOTE

      # (there is no treatment of ad-hoc normalization; probably you
      #  should use method-based associations..)

      # -- requiredness

      def __is_required

        # (implementation of [#002.4] is 1x redundant)

        if @_association_.parameter_arity_is_known
          Is_required[ @_association_ ]
        else
          @_normalization_.association_index.required_is_default_
        end
      end

      def __memo_this_missing_required_association
        @_normalization_.add_missing_required_MIXED_association_ @_association_
        NIL
      end

      # -- support

      def _working_value_is_nil
        @_working_value.nil?
      end

      def _write
        _x = remove_instance_variable :@_working_value
        @__valid_value_store.write_via_association _x, @_association_
      end

      attr_reader(
        :_normalization,
      )
    end

    # ==
    # ==
  end
end
# #history-B: begin usign normal normalization to interpret associations
# #tombstone-A: massively simplified and restricted how assocs are built here
