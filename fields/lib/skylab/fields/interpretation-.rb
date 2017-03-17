module Skylab::Fields

  module Interpretation_

    class AssociationInterpreter < Common_::SimpleModel  # see [#017]

      # this implements the interpretation of associations through an
      # injected grammar, in a way that is spiritually similar to how we do
      # in [#029.A] with the new "E.K" system (but whereas there we use [pa]
      # to parse, here we do the parsing ourselves.)

      # use the "meta associations module" to interpret each association.

      def initialize
        yield self
        __initialize
      end

      attr_writer(
        :association_class,  # sure you betcha
        :indexing_callbacks,  # as explained at [#002.C.6]
        :meta_associations_module,  # new in this take
      )

      def __initialize

        mod = remove_instance_variable :@meta_associations_module

        _mpr = MutablePrimaryReceiver___.new mod, self do |p|
          @__interpret_association = p
        end
        _mpr.extend mod
        NIL
      end

      def interpret_association_ k, scn

        @association_class.new k do |asc|

          if scn
            @__current_name_symbol = k
            @_current_association = asc
            @meta_argument_scanner_ = scn
            @__interpret_association[ asc, k, scn ]
          end
        end
      end
    end

    class MutablePrimaryReceiver___

      # SO: objects of this class will always be extended with exactly one
      # "meta associations module", which implements the collection of
      # recognized meta-associations (and logic to interpret them).

      # (maybe one day we will extend this in the expected way)

      # as such, the method namespace of this class is *wholly* off-limits.
      # its API (to its only client) is exposed strictly through the
      # callback method it sends back at construction time.

      # as well (#experimental in this edition), the ivar-space is totally
      # off-limits (except for its public API exposures) too! WEEEE!!!

      # its name is "mutable" "primary" "reciever":
      #
      #   - the fact that it is mutable is a dodgy "optimization"
      #
      #   - "primary receiver" because it gets sent the [#ze-053.2]
      #     "primaries" of modifiers that define characteristics of the
      #     association.

      def initialize mod, ai

        _p = -> asc, asc_sym, scn do

          @_meta_argument_scanner_ = scn
          @_association_ = asc

          begin

            k = scn.gets_one

            if mod.method_defined? k
              __send__ k
              NIL  # hi.

            elsif LEADS_WITH_UNDERSCORE_RX___ =~ k
              ai.indexing_callbacks.add_to_the_custom_index_ asc_sym, k
              NIL  # hi.

            else

              raise Build_this_one_exception___[ k, mod ]
            end

          end until scn.no_unparsed_exists

          NIL
        end

        yield _p

        @_association_interpreter_ = ai
      end
    end

    # ==

    class AssociationInterpreter  # (re-open)

      # -- exposures for meta meta (WRONG)  # #open [#015.1]

      def as_normalization_write_via_association_ x, asc  # THIS IS WRONG HERE
        @_current_association.instance_variable_set :"@#{ asc.name_symbol }", x
        NIL
      end

      # -- exposures for the meta-association implemention

      def entity_class_enhancer_by_ & p

        index_statically_ :this_is_an_enhancer
        @_current_association.add_enhance_entity_class_proc__ p ; nil
      end

      def index_statically_ meta_k
        @indexing_callbacks.add_to_the_static_index_ @__current_name_symbol, meta_k
      end

      def association_
        @_current_association
      end

      def meta_argument_scanner_
        @meta_argument_scanner_  # hi.
      end

      attr_reader(
        :indexing_callbacks,  # for above
      )
    end

    # ==

    Build_this_one_exception___ = -> k, meta_asc_mod do

      _m_a = meta_asc_mod.instance_methods false

      _nf = Common_::Name.via_variegated_symbol :meta_association

      _ev = Home_::CommonMetaAssociations::Enum::Build_extra_value_event.call(
        k, _m_a, _nf )

      _ex = _ev.to_exception

      _ex  # hi.
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
        @_normalization_.as_normalization_write_via_association_ x, @_association_
        KEEP_PARSING_  # in-memory writes may not fail. provided as convenience.
      end

      def argument_scanner
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

        vvs = @_normalization_.valid_value_store  # :#spot-1-2

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
# #tombstone-A: massively simplified and restricted how assocs are built here
