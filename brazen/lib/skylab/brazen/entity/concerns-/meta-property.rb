module Skylab::Brazen

  module Entity

    module Concerns_::Meta_Property

      class Property_Normalizer

        def initialize sess

          @_mprp_a = sess.property_class.const_get METAPROPERTIES_WITH_HOOKS_
        end

        def normalize_mutable_property prp

          # • assume that there is one or more metaproperties with hooks
          #
          # • you never know whether or not a new meta-property has been
          #   added since the last time you received a property, so we
          #   memoize nothing like that here.
          #
          # • we pass no event handler because to fail normalization of a
          #   property against a metaproperty is not hookable: it is supposed
          #   to fail loudly and early always.

          Home_::Home_::Normalization::Against_model_stream[

            prp, Callback_::Stream.via_nonsparse_array( @_mprp_a ) ]

          NIL_  # exceptions must be raised on failure
        end
      end

      class Processor

        def initialize sess
          @_cls = nil
          @_sess = sess
        end

        def << mprp

          @_cls || __init_mutable_property_class

          send :"__when_argument_arity_of__#{ mprp.argument_arity }__", mprp

          if mprp.is_normalizable__
            __memoize_metapropery_because_it_has_a_hook mprp
          end

          self
        end

        def __init_mutable_property_class

          mod = @_sess.client
          if mod.const_defined? :Property
            if mod.const_defined? :Property, false
              @_cls = mod.const_get :Property
            else
              @_cls = ::Class.new mod.const_get :Property
              mod.const_set :Property, @_cls
              @_sess.pcls_changed
            end
          else
            @_cls = ::Class.new Property
            mod.const_set :Property, @_cls
            @_sess.pcls_changed
          end
          NIL_
        end

        def __when_argument_arity_of__zero__ prp

          nm = prp.name
          ivar = nm.as_ivar
          rm = nm.as_variegated_symbol
          wm = prp.conventional_polymorphic_writer_method_name

          @_cls.class_exec do

            attr_accessor rm
            alias_method :"set_#{ rm }", wm

            define_method wm do
              instance_variable_set ivar, true
              KEEP_PARSING_
            end

            private wm
          end

          NIL_
        end

        def __when_argument_arity_of__one__ prp

          nm = prp.name
          ivar = nm.as_ivar
          rm = nm.as_variegated_symbol
          wm = prp.conventional_polymorphic_writer_method_name

          @_cls.class_exec do

            attr_accessor rm
            alias_method :"set_#{ rm }", wm

            define_method wm do

              instance_variable_set ivar, gets_one_polymorphic_value
              KEEP_PARSING_
            end

            private wm
          end

          NIL_
        end

        def __when_argument_arity_of__custom__ prp

          mutate_entity_against_upstream = prp.mutate_entity_proc_
          wm = prp.conventional_polymorphic_writer_method_name

          @_cls.class_exec do

            define_method wm do

              mutate_entity_against_upstream[ self, @_polymorphic_upstream_ ]
            end

            private wm
          end
          NIL_
        end

        def __memoize_metapropery_because_it_has_a_hook mprp

          cls = @_cls

          if cls.const_defined? CONST__
            if cls.const_defined? CONST__, false
              a = cls.const_get CONST__
            else
              a = cls.const_get CONST__
              a = a.dup
              cls.const_set CONST__, a
            end
          else
            a = []
            cls.const_set CONST__, a
          end
          a.push mprp
          NIL_
        end

        CONST__ = METAPROPERTIES_WITH_HOOKS_
      end
    end
  end
end
