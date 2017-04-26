module Skylab::TanMan

  module Models_::Starter

    class Actions::Get

      # the design challenge is posed of what exactly it should mean to "get"
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

      class << self

        def default_starter__ ms_invo
          me = new do ms_invo end
          me._will_use_default_starter_tail
          _hi = me._via_starter_tail
          _hi  # hi. #todo  CAN FAIL
        end

        def call_directly_ ms_invo
          op = new { ms_invo }
          yield op  # (exposed parameters are #here2)
          op.execute
        end
      end  # >>

      # -

        def definition

          _these = Home_::DocumentMagnetics_::CommonAssociations.to_workspace_related_stream_

          [
            :properties, _these,
          ]
        end

        def initialize
          @_execute = :__execute_normally
          extend Home_::Model_::CommonActionMethods
          init_action_ yield
        end

        # -- :#here2

        def mutable_workspace= mw
          @_execute = :__execute_specially
          @_immutable_workspace = :__mutable_as_immutable
          @_mutable_workspace_ = mw
        end

        attr_writer(
          :config_filename,
          :max_num_dirs_to_look,
          :workspace_path,
        )

        # --

        def execute
          send @_execute
        end

        def __execute_specially

          # (this "special" form of execute (cobbled together to get us over
          # the finish line) is just a synthesis of everything we've already
          # done, but in one method: A) use the mutable document we already
          # have instead of an immutable document we derive and B) use the
          # default starter nothing is in the workspace.)

          @_document = @_mutable_workspace_.mutable_document
          _ok = _resolve_starter_tail
          if ! _ok
            _will_use_default_starter_tail
          end
          _via_starter_tail
        end

        def __execute_normally
          @_immutable_workspace = :__immu_via_immu
          with_immutable_workspace_ do
            @_document = @_immutable_workspace_.immutable_document
            __work
          end
        end

        def __work
          if _resolve_starter_tail
            _via_starter_tail
          end
        end

        # -- B.

        def _will_use_default_starter_tail
          @_unsanitized_starter_tail = DEFAULT_STARTER_ ; nil
        end

        def _via_starter_tail

          sct = Actions::Ls.lookup_starter_by_ do |o|
            o.starter_tail = remove_instance_variable :@_unsanitized_starter_tail
            o.primary_channel_symbol = :info  # per :#here1
            o.microservice_invocation = @_microservice_invocation_
            o.listener = _listener_
          end

          if sct.did_find
            sct.found_item  # as covered
          else
            # sct.needle_item  # as covered
            $stderr.puts "CHANGING THIS TO MAKE MORE SENSE"  # #todo
            NOTHING_
          end
        end

        # -- A.

        def _resolve_starter_tail

          _ = __effectively_immutable_workspace.procure_component_by_ do |o|
            o.assigment :starter, :digraph
            # o.will_be_asset_path  -  no. leave as tail
            o.would_invite_by { [ :starter, :set ] }
            o.listener = _listener_
          end

          _store_ :@_unsanitized_starter_tail, _
        end

        def __effectively_immutable_workspace
          send @_immutable_workspace
        end

        def __mutable_as_immutable
          @_mutable_workspace_
        end

        def __immu_via_immu
          @_immutable_workspace_
        end

      # -

      # ==
      # ==
    end
  end
end
# #history-A: broke out of model file years after, full rewrite during [br] ween
