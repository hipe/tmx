module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::CLI

      class << self

        def express_of_via_into_under_of y, expag, item_one

          cls = item_one.class
          sess = Home_.lib_.string_lib.yamlizer.new

          sess.register_properties do | o |

            item_one.formal_properties.each do | prp |

              _ = cls.send(
                :"__#{ prp.name_symbol }__component_model" )

              _p = _::Expression_Adapters::CLI.express_of_via_under expag

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
