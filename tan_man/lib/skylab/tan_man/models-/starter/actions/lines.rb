module Skylab::TanMan

  module Models_::Starter

    class Actions::Lines

      class << self
        def call_directly__ ms_invo
          op = new { ms_invo }
          yield op  # (parameters exposed for this are #here1)
          op.execute
        end
      end  # >>

      # -

        def definition

          ca = Home_::DocumentMagnetics_::CommonAssociations

          # reading from the workspace is an option, but the workspace is not a precondition

          _x = ca.to_workspace_related_stream_nothing_required_

          [
            :branch_description, -> y do  # #todo change this name to ..
              y << "get a preview of what the lines would look like in a new graph"
              y << "template variables will be filled with placeholders"
            end,

            :flag, :property, :use_default,
            :description, -> y do
              y << "you can see the lines of the default starter without a workspace"
            end,

            :property, :value_provider,

            :properties, _x,
          ]
        end

        def initialize
          @_with_resolved_starter = nil
          extend Home_::Model_::CommonActionMethods
          init_action_ yield
        end

        def mutable_workspace= mw
          @_with_resolved_starter = :__with_starter_in_workspace_plus
          @_mutable_workspace_ = mw
        end

        attr_writer(
          :value_provider,
        )

        def execute

          unless __we_already_know_how_we_will_resolve_the_starter
            if __it_was_requested_that_we_use_the_default_starter
              __will_resolve_the_default_starter
            else
              __will_resolve_starter_in_workspace
            end
          end

          __with_resolved_starter do
            __lines_via_starter
          end
        end

        # -- D

        def __lines_via_starter

          _vp = __value_provider
          _tmpl = __template

          # (at #history-A we used to catch an ENOENT from template, but
          # now we are more confident that the file's existence has been
          # validated already.)

          _big_string = _tmpl.call _vp
          _fake_IO = Home_.lib_.string_IO.new _big_string
          _fake_IO  # hi. #todo
        end

        def __template
          _o = remove_instance_variable :@_starter
          _path = _o.path
          Home_.lib_.basic::String::Template.via_path _path
        end

        def __value_provider
          vp = @value_provider
          if vp
            vp
          else
            MOCKING_VALUE_PROVIDER___
          end
        end

        # -- C

        def __with_resolved_starter & p
          send remove_instance_variable( :@_with_resolved_starter ), & p
        end

        def __with_starter_in_workspace_plus
          _ok = __resolve_starter_via_workspace_plus
          _ok && yield
        end

        def __resolve_starter_via_workspace_plus

          _ = Here_::Actions::Get.call_directly_ @_microservice_invocation_ do |o|
            o.mutable_workspace = @_mutable_workspace_
          end
          _store_ :@_starter, _
        end

        def __with_starter_in_workspace
          if @workspace_path
            ok = __resolve_starter_via_workspace
            ok && __emit_thing_about_using_workspace_starter
            ok && yield
          else
            _listener_.call :error, :expression, :missing_required_parameters do |y|
              y << "need `workspace_path` or `use_default`"
            end
            NIL
          end
        end

        def __resolve_starter_via_workspace

          _ = Here_::Actions::Get.call_directly_ @_microservice_invocation_ do |o|

            o.workspace_path = @workspace_path
            o.config_filename = @config_filename
            o.max_num_dirs_to_look = @max_num_dirs_to_look
          end

          _store_ :@_starter, _
        end

        def __with_default_starter

          o = Here_::Actions::Get.default_starter__ @_microservice_invocation_
          if o
            __emit_thing_about_using_default_starter o
            @_starter = o
            yield
          else
            # assume emitted
            o
          end
        end

        def __emit_thing_about_using_workspace_starter
          o = @_starter
          _listener_.call :info, :expression, :using_starter do |y|
            y << "using starter: #{ o.natural_key_string }"
          end
        end

        def __emit_thing_about_using_default_starter o

          _listener_.call :info, :expression, :using_default_starter do |y|
            # (used to be a structured event before #history-A)
            y << "using default starter: #{ o.natural_key_string }"  # same as ::File.basename( o.path )
          end
          NIL
        end

        # -- B

        def __we_already_know_how_we_will_resolve_the_starter
          @_with_resolved_starter
        end

        def __it_was_requested_that_we_use_the_default_starter
          @use_default
        end

        def __will_resolve_the_default_starter
          @_with_resolved_starter = :__with_default_starter ; nil
        end

        def __will_resolve_starter_in_workspace
          @_with_resolved_starter = :__with_starter_in_workspace ; nil
        end
      # -

      # ==

      module MOCKING_VALUE_PROVIDER___ ; class << self

        def fetch sym

          _name = Common_::Name.via_variegated_symbol sym
          _ = _name.as_lowercase_with_underscores_string.upcase

          "{{ #{ _ } }}"
        end
      end ; end

      Actions = nil

      # ==
      # ==
    end
  end
end
# #history-A: full rewrite during ween off [br]. tombstone: used to use last starter as default
