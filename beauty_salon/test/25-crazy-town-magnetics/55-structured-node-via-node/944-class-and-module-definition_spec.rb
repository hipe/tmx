require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - class and module definition', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    # #covers:`class` #covers:`module`

    context '(basicest of basic class)' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'this class has no superclass, as you can see' do
        _x = at_ _class_component_for_superclass
        _x.nil? || fail
      end

      it 'this class has no body, as you can see' do
        _x = at_ _class_component_for_body
        _x.nil? || fail
      end

      it 'what about this, the module identifier' do
        _x = at_ _class_or_module_component_for_module_identifier
        _x.symbol == :Foo || fail  # woot
      end

      shared_subject :structured_node_ do
        structured_node_via_string_ "class Foo\nend\n"
      end
    end

    context '(module with some trickery)' do

      it 'builds' do
        structured_node_ || fail
      end

      it 'what about this, the module identifier' do
        _x = at_ _class_or_module_component_for_module_identifier
        _x.symbol == :Bar || fail  # woot
      end

      shared_subject :structured_node_ do
        structured_node_via_string_ "module @wee::Bar\nend\n"
        # (we'll test the above crazy const in its own file)
      end
    end

    # --

    def _class_or_module_component_for_module_identifier
      :module_identifier_const
    end

    def _class_component_for_superclass
      :any_superclass_expression
    end

    def _class_component_for_body
      :any_body_expression
    end

    # ==
    # ==
  end
end
# #born.
