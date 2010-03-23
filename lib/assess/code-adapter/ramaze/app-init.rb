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
        def my_prototype_dir opts
          require 'ramaze'
          @my_prototype_dir ||= begin
            dir = Assess.writable_temp!
            ramaze_default = "ramaze-default-app-#{::Ramaze::VERSION}"
            if ! dir.has_child?(ramaze_default)
              app_path = File.join(dir.path, ramaze_default)
              generate_ramaze_default_app app_path
              dir.refresh!
            end
            proto_dir = dir.get_child(ramaze_default)
            make_my_prototype_dir_from_prototype_dir(proto_dir, opts)
          end
        end
        def make_my_prototype_dir_from_prototype_dir proto_dir, opts
          dir = CodeBuilder::Folder.intermediate_deep_copy('./',proto_dir)
          dir.at_path('model').destroy!
          dir.at_path('controller/init.rb').replace_node(
            'require __DIR__("main")',
            dir.at_path('controller/main.rb')
          )
          dir.at_path('controller/main.rb').destroy!
          dir.at_path('controller').special_prune_hack!
          dir
        end
        def generate_ramaze_default_app path
          Open3.popen3("ramaze create #{path}") do |sin,sout,serr|
            err = serr.read
            flail("huh? - #{err}") unless "" == err
            ui.write sout.read
            debugger; 'x'

          end
        end
      end
    end
  end
end

