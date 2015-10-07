module Skylab::Slicer

  class Models_::Gemification

    Actions = ::Module.new

    class Actions::Gemify < Action_

      @is_promoted = true

      @description_block = -> y do
        y << "our personal spin on 'hoe' for our own uses. try it!"
      end

      edit_entity_class(
        :property, :dry_run,
        :required, :property, :sidesystem_path,
      )

      def produce_result

        task = Here_::Tasks_::Gem_File_Builds.new( & @on_event_selectively )

        task.add_parameter :sidesystem_path, @argument_box.fetch( :sidesystem_path )
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
  end
end
