module Skylab::TanMan

  module Models_::Starter

    class Actions::Get

      # the design challege is posed of what exactly it should mean to "get"
      # a starter. there are many predictable failpoints, only some of which
      # have unsurprising design consequences:
      #
      #   - the workspace config file could be not found
      #   - the config file could be unopenable/not a file/deleted
      #   - the config file could fail to parse
      #   - the config might not have the target section
      #   - under the target section it might not have the target assignment
      #   - there could (hypothetically?) be multiple assignments to the same name
      #   - the target assignment value could be any of several possible types
      #   - the target assignment could have a missing referent (:#here1)
      #   - the path's referent could be unopenable/not a file/deleted
      #   - the referent's content could fail to parse.
      #
      # for now what we do is that if we get as far as just before #here1,
      # we result in our internal structure for an item. this result happens
      # regardless of any of the failpoints that could occur after that point.
      #
      # if the failcase *at* #here1 does occur, then we emit an informational
      # event explaining this. but note we continue to result the value.

      # -

        def definition

          _these = Home_::DocumentMagnetics_::CommonAssociations.to_workspace_related_stream_

          [
            :properties, _these,
          ]
        end

        def initialize
          extend Home_::Model_::CommonActionMethods
          init_action_ yield
        end

        def execute
          with_immutable_workspace_ do
            @__document = @_immutable_workspace_.immutable_document
            __work
          end
        end

        def __work
          if __resolve_starter_tail
            __via_starter_tail
          end
        end

        # -- B.

        def __via_starter_tail

          sct = Actions::Ls.lookup_starter_by_ do |o|
            o.starter_tail = remove_instance_variable :@__unsanitized_starter_tail
            o.primary_channel_symbol = :info  # per :#here1
            o.microservice_invocation = @_microservice_invocation_
            o.listener = _listener_
          end

          if sct.did_find
            sct.found_item  # as covered
          else
            sct.needle_item  # as covered
          end
        end

        # -- A.

        def __resolve_starter_tail
          @_section_symbol = :digraph
          _sects = @__document.sections
          sect = _sects.lookup_softly @_section_symbol
          if sect
            tail = sect.assignments.lookup_softly :starter
            if tail
              @__unsanitized_starter_tail = tail ; true
            else
              _when_section_not_found
            end
          else
            _when_section_not_found
          end
        end

        def _when_section_not_found

          # #open [#097] this won't stay here

          _listener_.call :error, :expression, :component_not_found do |y|

            y << "no starter is set in config"
          end

          # #would-invite

          UNABLE_
        end
      # -
    end
  end
end
# #history-A: broke out of model file years after, full rewrite during [br] ween
