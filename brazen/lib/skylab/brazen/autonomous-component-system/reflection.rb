module Skylab::Brazen

  module Autonomous_Component_System

    module Reflection

      To_qualified_knownness_stream = -> acs do

        To_association_stream___[ acs ].map_by do | asc |

          ivar = asc.name.as_ivar
          if acs.instance_variable_defined? ivar
            had = true
            x = acs.instance_variable_get ivar
          end

          Callback_::Qualified_Knownness.via_value_and_had_and_association(
            x, had, asc )
        end
      end

      To_association_stream___ = -> acs do

        p = Component_Association.builder_for acs

        _ = Component_association_symbols_for___[ acs ]

        Callback_::Stream.via_nonsparse_array _ do | const |

          p[ const ]
        end
      end

      Component_association_symbols_for___ = -> acs do

        if acs.respond_to? :component_association_symbols
          acs.component_association_symbols

        else
          Method_index_of[ acs ].association_name_symbols
        end
      end

      Component_is_compound = -> kn do  # assumes true-ish

        x = kn.value_x

        if x.respond_to? :component_association_symbols
          true
        else

          # experimental - rather than requiring the above method, let's see
          # how it feels to require a dedicated class that has at least one:

          if kn.association.component_model.respond_to? :class_exec

            ! Method_index_of[ x ].association_name_symbols.nil?
          end
        end
      end

      Method_index_of = -> acs do
        ivar = IVAR___
        if acs.instance_variable_defined? ivar
          mi = acs.instance_variable_get ivar
        else
          mi = Method_Index___[ acs ]
          acs.instance_variable_set ivar, mi
        end
        mi
      end

      class Method_Index___

        class << self
          def [] cmp
            new cmp.class.instance_methods false
          end
          private :new
        end  # >>

        rx = nil

        define_method :initialize do | meth_a |

          rx ||= /\A__(?<name>.+)__component_(?<which>association)\z/

          freeze_me = nil

          pp = -> ivar do

            p = -> x do
              a = []
              ( freeze_me ||= [] ).push a
              instance_variable_set ivar, a
              p = -> md do
                a.push md[ :name ].intern
                NIL_
              end
              p[ x ]
            end

            -> sym do
              p[ sym ]
            end
          end

          h = {}
          h[ :association ] = pp[ :@association_name_symbols ]

          meth_a.each do | m |

            md = rx.match m
            md or next
            h.fetch( md[ :which ].intern )[ md ]
          end

          # for now, assume some

          freeze_me.each do | a |
            a.freeze
          end
        end

        attr_reader(
          :association_name_symbols,
        )
      end

      IVAR___ = :@___component_related_method_index

      UNDER_UNDER__ = '__'
    end
  end
end
