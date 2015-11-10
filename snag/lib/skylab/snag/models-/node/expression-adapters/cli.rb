module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::CLI

      class << self

        def express_of_via_into_under_of y, expag, first

          sess = Home_.lib_.string_lib.yamlizer.new

          sess.register_properties do | o |

            comp_assoc_for = ACS_[]::Component_Association.reader_for first

            first.formal_properties.each do | prp |

              _p = comp_assoc_for[ prp.name_symbol ].
                component_model::Expression_Adapters::CLI.
                  express_of_via_under expag

              o.register_property prp, & _p
            end
          end

          sess.line_downstream = y

          -> item do
            sess << item
            y
          end
        end
      end  # >>
    end
  end
end
