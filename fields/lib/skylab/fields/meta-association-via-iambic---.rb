module Skylab::Fields

  class MetaAssociation_via_Iambic___

    # -
      # (this is being thrown back in for fun. it is ANCIENT in spirit)
      #
      # (also, it is a proof of concept. it is not used in production,
      #  and does not have all the features we would probably want. however
      #  do *not* yet consider this a #feature-island *yet* -- it's a dog-
      #  ear on a feature we might certainly want..)

      def initialize ascs, x_a

        @__meta_meta_argument_scanner = Scanner_[ x_a ]

        @associations = ascs  # i.e a "defined attributes" set
      end

      def execute

        # (with the lvars, we still talk in terms of "associations"
        # and "meta associations" but note there is acutally one degree
        # more of meta than that! yikes)

        # under the assumption that individual custom meta-associations
        # aren't created very many times, we're just going to use this
        # association interpreter for one (N) association, not multiple.

        _ai = Home_::Interpretation_::AssociationInterpreter.define do |o|

          o.association_class = MetaAssociation___
          o.meta_associations_module = MetaMetaAssociations___
          o.indexing_callbacks = self
        end

        @_is_enhancer = false

        scn = remove_instance_variable :@__meta_meta_argument_scanner

        _meta_association_name_symbol = scn.gets_one

        meta_asc = _ai.interpret_association_ _meta_association_name_symbol, scn

        # SO if the custom meta-association has "enhancement" to do to the
        # association class (for example DSL friendly readers), touch a
        # mutuable association subclass and apply the enhancement on that:

        if @_is_enhancer

          _asc_cls = @associations.touch_writable_association_class__

          meta_asc.enhance_this_entity_class_ _asc_cls
        end

        # AND here's the main thing: creating a new meta association will
        # mean adding it to a "mutable" grammar "primary" module (presumably
        # one that itself includes the common primaries, but who knows):

        _meta_assocs_module = @associations.touch_writable_meta_associations_module___

        _meta_assocs_module.module_exec do

          define_method meta_asc.name_symbol do

            meta_asc.as_association_interpret_ @_association_interpreter_
          end
        end

        NIL
      end

      def add_to_the_static_index_ _k, meta_k
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

        NIL_
      end
    end

    # ==

    class MetaAssociation___  # EXPERIMENT - GO IT ALONE

      include Home_::AssociationValueProducerConsumerMethods_

      def initialize k

        init_association_value_producer_consumer_ivars_

        @name_symbol = k

        yield self

        close_association_value_producer_consumer_mutable_session_
      end

      def as_association_interpret_ ai
        super  # hi.
      end

      attr_reader(
        :name_symbol,  # #here
      )
    end

    # ==
    # ==
  end
end
# #tombstone-B: deleted "meta-attributes" document which had ancient notes of ours
# #history: broke out at #spot-3
