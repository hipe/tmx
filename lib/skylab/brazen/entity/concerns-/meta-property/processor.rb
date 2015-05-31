module Skylab::Brazen

  module Entity

    module Concerns_::Meta_Property

      class Processor

        def initialize sess
          @_cls = nil
          @_sess = sess
        end

        def << prp

          @_cls || __init_mutable_property_class

          send :"__when_argument_arity_of__#{ prp.argument_arity }__", prp

          if prp.has_default || prp.norm_box_
            __memoize_metapropery_because_it_has_a_hook prp
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

              mutate_entity_against_upstream[ self, @polymorphic_upstream_ ]
            end

            private wm
          end
          NIL_
        end

        def __memoize_metapropery_because_it_has_a_hook prp

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
          a.push prp
          NIL_
        end

        CONST__ = METAPROPERTIES_WITH_HOOKS_
      end
    end
  end
end
