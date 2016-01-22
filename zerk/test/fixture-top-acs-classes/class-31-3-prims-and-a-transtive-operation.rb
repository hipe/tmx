module Skylab::Zerk::TestSupport

  class Examples::Example_01_Zombies

    # (this is named "zombies" because we had just seen mockingjay p.2..)

    # model an ACS with three components, each leaf-like. the first and
    # third components have no specially defined operations, so a "set"-
    # like operation is assumed. the second component has two simply-defined
    # operations. `set` is a special operation name here - it will effect
    # the same UI mechanics used for the assumed "set" operations (experimental).
    # all other operations besides `set` need the ACS to define the operation
    # explicitly, as we have done here with `delete`.

    def initialize & oes_p

      # (we only emit events, we don't need e.g to write directly to stdout
      # which is why we disreagard the first argument above.)

      @_oes_p = oes_p
    end

    def __fozzer__component_association

      File_Name_Model_
    end

    def __fizzie_nizzie__component_association

      yield :can, :set, :delete

      File_Name_Model_
    end

    def __biz_nappe__component_association

      File_Name_Model_
    end

    def __delete__component asc, & _x_p

      # per #thread-one we are not passed an
      # emission handler proc as an argument for now.

      pd = "pretending to delete '#{ asc.name.as_slug }'"

      @_oes_p.call :info, :expression do |y|  # use #thread-one
        y << "#{ pd } two"
      end

      :_yep_
    end

    def result_for_component_mutation_session_when_changed ch, & _

      ch.last_delivery_result
    end
  end
end
