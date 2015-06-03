module Skylab::Brazen

  class Models_::Workspace

    class Actors__::Init

      # :+#non-atomic with regards to filesystem interaction.

      Actor_.call self, :properties,
        :is_dry,
        :surrounding_path,
        :config_filename,
        :prop,
        :app_name

      def execute
        init_max_number_of_directories_to_make
        ok = resolve_document
        ok && partition
        ok &&= ensure_directory
        ok &&= create_any_directories
        ok && maybe_write_document
      end

      def init_max_number_of_directories_to_make
        @maximum_number_of_directories_to_make = LIB_.basic::String.
          count_occurrences_in_string_of_regex(
            @config_filename,
            RX___ )
        nil
      end

      s = ::Regexp.escape ::File::SEPARATOR
      RX___ = /(?<!\A|#{ s })(?:#{ s }){1,}(?!\z|#{ s })/
        # treat repeating '/' as one separator. don't count any
        # separator anchored to the head of the string or the tail.

      def resolve_document
        @document = Brazen_::Collection_Adapters::Git_Config::Mutable.new(
          & @on_event_selectively )
        into_document_add_comment
      end

      def into_document_add_comment
        @document.add_comment "created by #{ @app_name } #{
          }#{ ::Time.now.strftime '%Y-%m-%d %H:%M:%S' }"
      end

      def partition

        @config_path = ::File.join @surrounding_path, @config_filename
        current_path = @config_path
        make_these_directories = nil

        begin
          dir = ::File.dirname current_path
          if ::File.directory? dir
            break
          end
          make_these_directories ||= []
          make_these_directories.push dir
          current_path = dir
          redo
        end while nil

        if make_these_directories
          make_these_directories.reverse!
          @make_these_directories = make_these_directories
        else
          @make_these_directories = nil
        end
        nil
      end

      def ensure_directory
        a = @make_these_directories
        max = @maximum_number_of_directories_to_make
        if a
          if 0 <= max  # sanity
            if max < a.length
              when_must_exist a[ - ( max + 1 ) ]
            else
              ACHIEVED_
            end
          else
            UNABLE_
          end
        else
          ACHIEVED_
        end
      end

      def when_must_exist dir
        self._COVER_ME
      end

      def create_any_directories
        if @make_these_directories
          create_directories
        else
          ACHIEVED_
        end
      end

      def create_directories
        ok = true
        @make_these_directories.each do | dir |

          same_dir = LIB_.system.filesystem.normalization.downstream_IO(
            :ftype, 'directory', :path, dir,
            :is_dry_run, @is_dry,
            :on_event_selectively, @on_event_selectively )  # (because entity)

          if ! same_dir
            ok = same_dir
            break
          end
        end
        ok
      end

      def maybe_write_document
        @path = ::File.join @surrounding_path, @config_filename
        if ::File.exist? @path
          when_exist
        else
          @document.write_to_path @path, :is_dry, @is_dry
        end
      end

      def when_exist

        @on_event_selectively.call :error, :directory_already_has_config_file do

          Callback_::Event.inline_not_OK_with(
            :directory_already_has_config_file,
           :config_path, @path,
           :prop, @prop )
        end
      end
    end
  end
end
