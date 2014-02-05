module Skylab::Git

  module CLI::Actions::Scoot

    class Plugins__::Memory

      module Prepend__
        def engage
        end
        def on_pattern_string_received s
          @pattern_s = s
          procure_fh && write_to_fh
        end
      private
        def write_to_fh
          @fh.seek 0, :END
          @fh.pos.zero? or _re = 're-'
          @y_IO.write "#{ _re }writing #{ dotfile } .."
          @fh.truncate 0
          @fh.seek 0, :SET
          @fh.puts "pattern=#{ @pattern_s }"
          @fh.close
          @y_IO.puts " done."
          SILENT_
        end

        def procure_fh
          @path = procure_dotfile_path
          @path && procure_fh_with_dotfile_path
        end

        def procure_dotfile_path
          ok = true
          dotfile_path = dotfile.sub %r(\A~) do
            procure_env_home or ok = false
          end
          ok and dotfile_path
        end

        def procure_env_home
          ::ENV[ 'HOME' ] or report_no_env_home
        end

        def report_no_env_home
          @y << "no $HOME environment variable, cannot expand path #{ dotfile }"
          CEASE_
        end

        def procure_fh_with_dotfile_path
          ok = path_must_be_of_certain_depth
          ok &&= directory_of_a_certain_shallowitude_must_exist
          ok &&= make_directory_if_necessary
          ok && now_it_is_OK_to_open_the_file
        end

        def path_must_be_of_certain_depth
          %r(/[^/]+/) =~ @path or report_path_not_deep_enough
        end

        def report_path_not_deep_enough
          @y << "path doesn't look deep enough: #{ @path }"
          CEASE_
        end

        def directory_of_a_certain_shallowitude_must_exist
          @pn = ::Pathname.new @path
          @mkdir_pn = @pn.dirname
          @eg_home_pn = @mkdir_pn.dirname
          @eg_home_pn.exist? or report_home_dir_not_exist
        end

        def report_home_dir_not_exist
          @y << "directory must exist: #{ @eg_home_pn }"
          CEASE_
        end

        def make_directory_if_necessary
          @mkdir_pn.exist? or mkdir
        end

        def mkdir
          @y << "mkdir #{ @mkdir_pn }"
          @mkdir_pn.mkdir
        end

        def now_it_is_OK_to_open_the_file
          @fh = @pn.open 'a+'
          @pn = @mkdir_pn = @eg_home_pn = nil
          @fh && PROCEDE_
        end
      end
      prepend Prepend__
    end
  end
end
