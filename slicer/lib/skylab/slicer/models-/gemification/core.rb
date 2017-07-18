module Skylab::Slicer

  class Models_::Gemification

    Actions = ::Module.new

    class Actions::Gemify < Action_

      @is_promoted = true

      @instance_description_proc = -> y do
        y << "our personal spin on 'hoe' for our own uses. try it!"
      end

      edit_entity_class(
        :flag, :property, :dry_run,
        :required, :property, :sidesystem_path,
        :property, :script_invocation,  # API-only :(
      )

      def produce_result

        task = Here_::Tasks_::Installed_Gem.new( & @on_event_selectively )

        task.add_parameter :sidesystem_path, @argument_box.fetch( :sidesystem_path )
        task.add_parameter :script_invocation, @argument_box[ :script_invocation ]
        task.add_parameter :filesystem, ::File

        task.execute_as_front_task
      end
    end

    module Tasks_
      Autoloader_[ self, :boxxy ]
    end

    Here_ = self

    Task_ = -> do
      Home_.lib_.task
    end

    # ==
    # ==
  end
end
