module Skylab::Zerk::TestSupport

  class Fixture_Top_ACS_Classes::Class_23_Multi_Intent_Root

    def __resourcez__component_association
      yield :intent, :API
      :_ok_
    end

    def __floofie__component_association
      yield :intent, :UI
      :_ok_
    end

    def __both__component_association
      yield :intent, :interface
      :_ok_
    end
  end
end
