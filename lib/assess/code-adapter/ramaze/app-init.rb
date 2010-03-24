require 'open3'
module Hipe
  module Assess
    module Ramaze
      module AppInit
        include CommonInstanceMethods
        extend self
        def app_init ui, opts
          def! :ui, ui
          dir = my_prototype_dir opts
          dir.execute_write_request ui,opts
        end
      private

        def tmpdir
          @tmpdir ||= begin
            CodeBuilder.create_or_get_folder(
              FrameworkCommon.tmpdir_for('ramaze')
            )
          end
        end

        def my_prototype_dir opts
          require 'ramaze'
          @my_prototype_dir ||= begin
            ramaze_default = "ramaze-default-app-#{::Ramaze::VERSION}"
            if ! tmpdir.has_child?(ramaze_default)
              app_path = File.join(tmpdir.path, ramaze_default)
              generate_ramaze_default_app app_path
              tmpdir.refresh!
            end
            proto_dir = tmpdir.get_child(ramaze_default)
            transform_ramaze_prototype(proto_dir, opts)
          end
        end

        def my_proto path
          File.join(RootDir, 'lib/assess/code-adapter/ramaze/protos', path)
        end

        def transform_ramaze_prototype proto_dir, opts
          dir = CodeBuilder::Folder.intermediate_deep_copy('./',proto_dir)
          mess_with_model dir
          mess_with_view dir
          mess_with_controller dir
          mess_with_app dir
          dir
        end

        def mess_with_model dir
          dir.at_path('model').destroy!
        end

        def mess_with_controller dir
          dir.at_path('controller/init.rb').replace_node(
            'require __DIR__("main")',
            dir.at_path('controller/main.rb')
          )
          dir.at_path('controller/main.rb').destroy!
          dir.at_path('controller').special_prune_hack!
          cnt = dir.at_path('controller.rb').codepath('class:Controller')
          cnt.codepath('call:engine')[3][1][1] = :Haml
          cnt.codepath('call:helper').destroy!
          nil
        end

        def mess_with_view dir
          layout = dir.at_path('layout/default.xhtml')
          layout.replace_token('default.haml')
          layout.replace_content_with_path(my_proto('layout-1.haml'))
          nil
        end

        def mess_with_app dir
          file = dir.at_path('app.rb')
          file.codepath('call:require/arglist/str:rubygems').parent.
            parent.destroy!
          node = file.codepath('call:__DIR__/arglist/str:model\/init')
          node[1] = "model.rb"
          node = file.codepath('call:__DIR__/arglist/str:controller\/init')
          node[1] = "controller.rb"
          nil
        end

        def generate_ramaze_default_app path
          Open3.popen3("ramaze create #{path}") do |sin,sout,serr|
            err = serr.read
            flail("huh? - #{err}") unless "" == err
            ui.write sout.read
          end
        end
      end
    end
  end
end
