module Skylab::Brazen

  module Autonomous_Component_System

    module Reflection

      To_qualified_knownness_stream = -> acs do

        To_association_stream[ acs ].map_by do | asc |

          ivar = asc.name.as_ivar
          if acs.instance_variable_defined? ivar
            had = true
            x = acs.instance_variable_get ivar
          end

          Callback_::Qualified_Knownness.via_value_and_had_and_association(
            x, had, asc )
        end
      end

      To_association_stream = -> acs do

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
          Method_index_of_class__[ acs.class ].association_name_symbols
        end
      end

      Model_is_compound = -> mdl do

        if mdl.respond_to? :method_defined?

          if mdl.method_defined? :component_association_symbols
            true
          else
            ! Method_index_of_class__[ mdl ].association_name_symbols.nil?
          end
        end
      end

      Method_index_of_class__ = -> cls do

        cls.class_exec do

          @___ACS_method_index ||=
            Method_Index___.new( cls.instance_methods( false ) )
        end
      end

      class Method_Index___

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
    end
  end
end
