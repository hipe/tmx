require 'assess/util/uber-alles-array.rb'
require 'assess/code-adapter/framework-common/wishy-washy-path'
require 'assess/code-adapter/framework-common/app-info'


module Hipe
  module Assess
    module FrameworkCommon
      extend CommonInstanceMethods
      class << self
        def dispatch_migrate ui, opts
          AppInfo.current.orm_manager.process_migrate_request ui, opts
        end
        def dispatch_merge_data ui, sin, opts
          AppInfo.current.orm_manager.process_merge_data_request ui, sin, opts
        end
        def dispatch_db_check opts, *args
          AppInfo.current.orm_manager.db_check opts, *args
        end

        SafeWord = 'ok-to-erase'
        SafeRe = Regexp.new(Regexp.escape(SafeWord)+'/[^/]+\Z')

        # erase anything in any previous tmpdir with that name
        # should write what it does to ui
        def empty_tmpdir_for! name
          aip = AppInfo.current.persistent
          if path = aip.tmpdirs[name]
            emtpy_tmpdir_from_persistent path, name
          else
            path = File.join(CodeBuilder.new_tmpdir,SafeWord,name)
            make_tmpdir_from_nonexistant_path path, name
            aip.tmpdirs[name] = path
          end
          path
        end
      private
        def emtpy_tmpdir_from_persistent path, name
          if File.exist?(path)
            rm_contents_of_existing_tmpdir path, name
          else
            make_tmpdir_from_nonexistant_path path, name
          end
          path
        end
        def me
          humanize(underscore(class_basename(self)))
        end
        def ui; Cmd.ui end
        def ui_puts_once msg
          @putted ||= {}
          return if @putted[msg]
          @putted[msg] = true
          ui.puts(msg)
        end
        def make_tmpdir_from_nonexistant_path path, name
          fail("huh?") if File.exist?(path)
          ui.print("new #{name} tmpdir by #{me} - ")
          FileUtils.mkdir_p(path, :verbose=>true)
          nil
        end
        def rm_contents_of_existing_tmpdir path, name
          fail('huh?') if ! File.directory?(path)
          if SafeRe !~ path
            fail("i'm not comfortable erasing this path, it doesn't have "<<
            "the safeword (\"#{SafeWord}\") in it in the right place: "<<
            " #{path}")
          end
          if (filez = Dir[File.join(path,'/*')]).any?
            these = truncate(oxford_comma(filez.map{|x|File.basename(x)}))
            these[0,0] = "  \n" if these.length > 40
            ui.puts("removing contents of exsiting tmpdir (#{me}): #{these}")
            FileUtils.remove_entry_secure(path)
            FileUtils.mkdir(path,:verbose => true)
          else
            ui_puts_once("tmpdir already empty (#{me}): #{path}")
          end
        end
      public
        def tmpdir_for name
          @tmpdir_for ||= {}
          @tmpdir_for[name] ||= begin
            aip = AppInfo.current.persistent
            found_dir = nil
            if aip['last_temp_dir']
              last_temp_dir = aip['last_temp_dir'][1]
              found_dir = last_temp_dir if File.exist?(last_temp_dir)
            end
            if ! found_dir
              found_dir = File.join(CodeBuilder.tmpdir, name)
              aip['last_temp_dir'] = found_dir
            end
            found_dir
          end
        end
      end
    end
  end
end
