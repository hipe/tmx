module Skylab::DocTest

  class TestDocumentMutationMagnetics_::TransitionCharacterization_via_LeftNode_and_TestDocumentIndex

    # this broke out of a sibling and is *very* close in its scope of
    # concerns, so much so that it might again dissolve. but the idea
    # here is a pure separation of mechanism from policy ([#145]) so
    # for example there is no emission here, only the production of a
    # cold structure without and "judgement" of what it means (except
    # to the extent that we characterize the transition with a verb).
    #
    # with the "left and right" metaphor we use here there is always this
    # caveat: the "left side" represents the "new" information and right,
    # the existing information. so don't think of it as what's on the left
    # "becoming" what's on the right; rather the opposite: so for example
    # if you have a branch node on the *left* and an item node on the
    # *right*, this is an "upgrade" (and likewise the opposite is a
    # downgrade). :#here

    def initialize ln, tdi
      @left_node = ln
      @test_document_index = tdi
    end

    def execute
      ok = __resolve_left_identifying_string
      ok && __via_left_identifying_string
    end

    def __via_left_identifying_string

      @_left_is_of_branch = Paraphernalia_::Is_branch[ @left_node ]

      eni = @test_document_index.lookup_via_identifying_string @_left_identifying_string
      if eni
        @_existing_node_index = eni
        __when_existing
      else
        __when_no_existing
      end
    end

    def __when_no_existing

      Create___.by do |o|
        o.identifying_string = @_left_identifying_string
        o.is_of_branch = @_left_is_of_branch
      end
    end

    def __when_existing

      right_is_of_branch = @_existing_node_index.is_of_branch

      if @_left_is_of_branch == right_is_of_branch
        SameShape___.by do |o|
          o.existing_node_index = @_existing_node_index
          o.identifying_string = @_left_identifying_string
          o.is_of_branch = right_is_of_branch
        end
      else
        ChangeShape___.by do |o|
          o.existing_node_index = @_existing_node_index
          o.identifying_string = @_left_identifying_string
          o.right_is_of_branch = right_is_of_branch
          o.verb_symbol = right_is_of_branch ? :downgrade : :upgrade
        end
      end
    end

    def __resolve_left_identifying_string
      _ok = _store :@_left_identifying_string, @left_node.identifying_string
      if ! _ok
        self._COVER_ME__node_did_not_have_identifying_string_for_whatever_reason
      end
      _ok
    end

    def _store ivar, x
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        x
      end
    end

    # ==

    class CommonLocalModel_

      class << self
        def by
          o = new
          yield o
          o.freeze
        end
        private :new
      end  # >>

      attr_accessor(
        :identifying_string,
      )
    end

    class ChangeShape___ < CommonLocalModel_

      attr_accessor(
        :existing_node_index,
        :right_is_of_branch,
        :verb_symbol,
      )
    end

    class SameShape___ < CommonLocalModel_

      attr_accessor(
        :existing_node_index,
        :is_of_branch,
      )

      def verb_symbol
        :same_shape
      end
    end

    class Create___ < CommonLocalModel_

      attr_accessor(
        :is_of_branch,
      )

      def verb_symbol
        :create
      end
    end
  end
end
# #history: broke out of sibling
