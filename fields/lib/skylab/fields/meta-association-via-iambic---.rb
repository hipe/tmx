module Skylab::Fields

  class Attributes

    class DSL  # ancient history in [#009] (was [#.A])

      # (this is being thrown back in for fun. it is ANCIENT in spirit)
      #
      # (also, it is a proof of concept. it is not used in production,
      #  and does not have all the features we would probably want. however
      #  do *not* yet consider this a #feature-island *yet* -- it's a dog-
      #  ear on a feature we might certainly want..)

      def initialize ascs, x_a
        @associations = ascs
        @sexpesque = x_a
      end

      def execute

        mascs_cls = @associations.meta_associations__
        if ! mascs_cls
          mascs_cls = __begin_mutable_meta_associations_class
        end

        asc_cls = @associations.association_class__
        if ! asc_cls
          asc_cls = __begin_mutable_association_class
        end

        _this = Here_::N_Meta_Attribute.define do |o|

          o.N_plus_one_interpreter_by = method :__build_interpreter

          o.meta_associations_class = mascs_cls

          o.association_class = MetaAssociation___

          o.finish_association_by = -> asc do
            NOTHING_  # hi.
          end

          o.indexing_callbacks = self
        end

        @_is_method_definer = false
        sexp = remove_instance_variable :@sexpesque
        masc = _this.flush_for_build_and_process_association_ sexp.pop, sexp  # :#spot-1-1

        if @_is_method_definer
          masc.effect_definition_into_ asc_cls
        end

        # here's the rub:

        mascs_cls.send :define_method, masc.name_symbol do

          masc.as_association_interpret_ @_
        end

        NIL_
      end

      def add_to_the_static_index_ _k, meta_k
        send SI_OP_H___.fetch meta_k
      end

      SI_OP_H___ = {
        method_definers: :__index_as_method_definer,
      }

      def __index_as_method_definer
        @_is_method_definer = true
        NIL_
      end

      def __build_interpreter is  # interpretation services

        mmascs = MetaMetaAssociations___.new is

        -> k do
          mmascs.__send__ k
        end
      end

      def __begin_mutable_meta_associations_class

        cls = ::Class.new Here_::MetaAttributes

        @associations.const_set :MetaAttributes, cls

        @associations.meta_associations = cls

        cls
      end

      def __begin_mutable_association_class

        cls = ::Class.new MetaAssociation___

        @associations.const_set :Attribute, cls

        @associations.association_class = cls

        cls
      end

      class MetaMetaAssociations___

        def initialize is  # interpretation services
          @_ = is
        end

        def flag

          # CASE STUDY: this has similar semantics to a counerpart method of
          # the same name in the N-1 class, but how they differ is exemplary
          # of how meta-meta-associations differ from meta-associations
          # (i.e why they are not implemented in the exact same way):
          #
          # the MA in this case merely changes the interpretation reader
          # from the default one to one that doesn't consume a token and
          # always results in `true`. *this* one (the MMA) however, does that
          # and also modifies the association *class*.
          #
          # the former doesn't also do this because modern meta-associations
          # are not typically in the business of modifying entity classes
          # because the instance method namespace of the entity class is
          # purely for ad-hoc business. however, we being a high-level DSL
          # *do* go this extra distance and modify the association *class*.

          ca = @_.current_association_
          scn = @_.argument_scanner_for_current_association_
          if scn.unparsed_exists && :reader_method_name == scn.head_as_is
            scn.advance_one
            m = scn.gets_one
          end

          ca.reader_by_ do
            NILADIC_TRUTH_
          end

          @_.add_methods_definer_by_ do |asc|

            orig_m = asc.name_symbol

            if ! m
              m = :"is_#{ asc.name_symbol }"
            end

            -> mod do

              mod.module_exec do
                attr_reader orig_m
                alias_method m, orig_m
                remove_method orig_m
              end

              NIL_
            end
          end

          NIL_
        end

        Etc___ = -> k do
          :"is_#{ k }"
        end
      end

      MetaAssociation___ = ::Class.new Here_::DefinedAttribute  # hi.

      # ==
      # ==

    end
  end
end
# #history: broke out at #spot-3
