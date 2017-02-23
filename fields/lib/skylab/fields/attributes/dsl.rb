module Skylab::Fields

  class Attributes

    class DSL  # ancient history in [#009] (was [#.A])

      # (this is being thrown back in for fun. it is ANCIENT in spirit)
      #
      # (also, it is a proof of concept. it is not used in production,
      #  and does not have all the features we would probably want. however
      #  do *not* yet consider this a #feature-island *yet* -- it's a dog-
      #  ear on a feature we might certainly want..)

      def initialize attrs, x_a, & x_p
        x_p and self._FUN

        @attributes = attrs
        @sexpesque = x_a
      end

      def execute

        mattrs_cls = @attributes.meta_attributes__
        if ! mattrs_cls
          mattrs_cls = __begin_mutable_meta_attributes_class
        end

        atr_cls = @attributes.attribute_class__
        if ! atr_cls
          atr_cls = __begin_mutable_attribute_class
        end

        sexp = remove_instance_variable :@sexpesque

        o = Here_::N_Meta_Attribute::Build.new mattrs_cls, Meta_Attribute___

        o.build_N_plus_one_interpreter = method :__build_interpreter

        o.finish_attribute = MONADIC_EMPTINESS_  # for now

        o.attribute_services = self

        @_is_method_definer = false

        matr = o.flush_for_build_and_process_attribute_ sexp.pop, sexp

        if @_is_method_definer
          matr.deffers_.each do |p|
            p[ atr_cls ]
          end
        end

        # here's the rub:

        mattrs_cls.send :define_method, matr.name_symbol do

          matr._interpret @_
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

      def __build_interpreter bld_N

        mmattrs = Meta_Meta_Attributes___.new bld_N

        -> k do
          mmattrs.__send__ k
        end
      end

      def __begin_mutable_meta_attributes_class

        cls = ::Class.new Here_::MetaAttributes

        @attributes.const_set :MetaAttributes, cls

        @attributes.meta_attributes = cls

        cls
      end

      def __begin_mutable_attribute_class

        cls = ::Class.new Meta_Attribute___

        @attributes.const_set :Attribute, cls

        @attributes.attribute_class = cls

        cls
      end

      class Meta_Meta_Attributes___ < ::BasicObject

        def initialize bld
          @_ = bld
        end

        def flag

          # CASE STUDY: this has similar semantics to a a counerpart method
          # of the same name in the N-1 class, but how they differ is
          # exemplary of how meta-meta-attributes differ from meta-attributes
          # (i.e why they are not implemented in the exact same way).
          #
          # the MA in this case merely changes the interpretation reader
          # from the default one to one that doesn't consume a token and
          # always results in `true`. *this* one (the MMA) however, does that
          # and also modifies the attribute *class*.
          #
          # the former doesn't also do this because modern meta-attributes
          # are not typically in the business of modifying entity classes
          # because the instance method namespace of the entity class is
          # purely for ad-hoc business. however, we being a high-level DSL
          # *do* go this extra distance and modify the attribute *class*.

          ca = @_.current_attribute
          st = @_.sexp_stream_for_current_attribute
          if st.unparsed_exists && :reader_method_name == st.head_as_is
            st.advance_one
            m = st.gets_one
          end

          ca.reader_by_ do
            NILADIC_TRUTH_
          end

          @_.add_methods_definer_by_ do |atr|

            orig_m = atr.name_symbol

            if ! m
              m = :"is_#{ atr.name_symbol }"
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

      class Meta_Attribute___ < Here_::DefinedAttribute
        # (hi.)
      end
    end
  end
end
# #history: broke out at #spot-3
