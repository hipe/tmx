module Skylab::Snag

  class Models_::Node

    module ExpressionAdapters::CLI

      class << self

        def express_of_via_into_under_of y, expag, first

          sess = Home_.lib_.string_lib::Yamlizer.new

          sess.register_properties do | o |

            _rw = ACS_[]::Magnetics::OperatorBranch_via_ACS.for_componentesque first

            comp_assoc_for = _rw.association_reader

            first.formal_properties.each do |prp|

              _asc = comp_assoc_for[ prp.name_symbol ]
              _CLI = _asc.component_model::ExpressionAdapters::CLI
              _p = _CLI.express_of_via_under expag

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
