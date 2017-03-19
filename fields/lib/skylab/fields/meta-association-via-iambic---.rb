module Skylab::Fields

  class MetaAssociation_via_Iambic___  # :[#002.9]

    # expose a DSL for creating custom meta-associations, implemented using
    # as much as possible the same infrastructure we use to interpret
    # associations, but re-using no more of that code than we need to.
    #
    # this file was created relatively recently (#history-A), but the DNA
    # here is ANCIENT, going back years and years.
    #
    # this is an intentional "feature-island" - it has code that is covered
    # by tests but is used no where in production. unlike ordinary feature
    # islands, we have no intention of sunsetting this one. it exists A) so
    # that the [#002.C] defined attributes library doesn't "feel" that much
    # weaker by not having an API for declared meta-associations, and B) as
    # a proving ground to drive theory we develop in [#002.9] and [#002.J]
    # (about N-meta associations and so on), theory that we did not attempt
    # to put into words until this code was working.

    # -

      def initialize ascs, x_a

        @__meta_meta_argument_scanner = Scanner_[ x_a ]

        @associations = ascs  # i.e a "defined attributes" set
      end

      def execute

        _ai = Home_::Interpretation_::AssociationInterpreter.define do |o|

          # (note each assignment is N+1)

          o.association_class = MetaAssociation___
          o.meta_associations_module = MetaMetaAssociations___
          o.indexing_callbacks = self  # #here1
        end

        @_is_enhancer = false

        scn = remove_instance_variable :@__meta_meta_argument_scanner

        _meta_association_name_symbol = scn.gets_one

        meta_asc = _ai.interpret_association_ _meta_association_name_symbol, scn

        # SO if the custom meta-association has "enhancement" to do to the
        # association class (for example DSL friendly readers), touch a
        # mutable association subclass and apply the enhancement on that:

        if @_is_enhancer

          _asc_cls = @associations.touch_writable_association_class__

          meta_asc.enhance_this_entity_class_ _asc_cls
        end

        # AND here's the main thing: in order to create a new meta
        # association you need (only) to define it as a method on the meta
        # associations module (one you are permitted to mutate):

        _meta_assocs_module = @associations.touch_writable_meta_associations_module___

        _meta_assocs_module.module_exec do

          define_method meta_asc.name_symbol do

            _ok = meta_asc.as_association_interpret_ @_META_NORMALIZATION_

            _ok == true || self._SANITY ; nil
          end
        end

        NIL
      end

      def add_to_the_static_index_ _k, meta_k  # #here1
        send THESE___.fetch meta_k
      end

      THESE___ = {
        this_is_an_enhancer: :__when_this_is_an_enhancer,
      }

      def __when_this_is_an_enhancer
        @_is_enhancer = true ; nil
      end

    # -

    # ==

    module MetaMetaAssociations___

      # (even if it were the case that the set of desired
      # meta-meta-associations were a clean subset of our set of default
      # meta-associations, for our own sanity A) and B) because requirements
      # are different, we do not somehow cherry-pick their re-use from there.)

      def flag

        scn = @_meta_argument_scanner_

        if scn.unparsed_exists && :reader_method_name == scn.head_as_is
          self._WORKED_ONCE_PROBABLY__but_it_aint_covered_now__
          scn.advance_one
          m = scn.gets_one
        end

        @_association_.argument_value_producer_by_ do
          NILADIC_TRUTH_
        end

        @_association_interpreter_.entity_class_enhancer_by_ do |asc|

          custom_meta_association_name_sym = asc.name_symbol

          if ! m
            m = :"is_#{ custom_meta_association_name_sym }"
          end

          -> association_class do

            association_class.class_exec do
              attr_reader custom_meta_association_name_sym
              alias_method m, custom_meta_association_name_sym
              remove_method custom_meta_association_name_sym
            end

            NIL
          end
        end

        NIL
      end
    end

    # ==

    class MetaAssociation___

      # note this is our only known modeling of a meta-association as a
      # structure. the rest of the time they are implemented in code only
      # through interpretation methods.

      include Home_::AssociationValueProducerConsumerMethods_

      def initialize k

        init_association_value_producer_consumer_ivars_

        @name_symbol = k  # setting this before below adds parsimony (again) #spot-1-1

        yield self

        close_association_value_producer_consumer_mutable_session_
      end

      def as_association_interpret_ n11n
        super  # hi.
      end

      def as_ivar
        :"@#{ @name_symbol }"
      end

      attr_reader(
        :name_symbol,
      )
    end

    # ==
    # ==
  end
end
# #tombstone-B: deleted "meta-attributes" document which had ancient notes of ours
# #history: broke out at #spot-3
