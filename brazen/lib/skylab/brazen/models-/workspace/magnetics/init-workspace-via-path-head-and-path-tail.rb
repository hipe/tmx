module Skylab::Brazen

  class Models_::Workspace

    class Magnetics::InitWorkspace_via_PathHead_and_PathTail

      # :+#non-atomic with regards to filesystem interaction.

      Attributes_actor_.call( self,
        :is_dry,
        :surrounding_path,
        :config_filename,
        :prop,
        :app_name_string,
      )

      def initialize & _
        @listener = _
      end

      def execute

        init_max_number_of_directories_to_make
        ok = __resolve_document
        ok && partition
        ok &&= __validate_depth_of_directories_to_create
        ok &&= create_any_directories
        ok && maybe_write_document
      end

      def init_max_number_of_directories_to_make
        @maximum_number_of_directories_to_make = Home_.lib_.basic::String.
          count_occurrences_in_string_of_regex(
            @config_filename,
            RX___ )
        NIL_
      end

      s = ::Regexp.escape ::File::SEPARATOR
      RX___ = /(?<!\A|#{ s })(?:#{ s }){1,}(?!\z|#{ s })/
        # treat repeating '/' as one separator. don't count any
        # separator anchored to the head of the string or the tail.

      def __resolve_document

        @document = Home_::CollectionAdapters::GitConfig::Mutable.new_empty_document

        @document.add_comment "created by #{ @app_name_string } #{
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

      def __validate_depth_of_directories_to_create

        a = @make_these_directories

        if a

          max = @maximum_number_of_directories_to_make

          if 0 <= max  # (sanity: if max is a sane number..)

            if max < a.length  # if the value exceeds max..

              when_must_exist a[ - ( max + 1 ) ]
            else
              ACHIEVED_
            end
          else
            UNABLE_
          end
        else

          ACHIEVED_  # no directories to create. valid.
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

          kn = Home_.lib_.system_lib::Filesystem::Normalizations::ExistentDirectory.via(

            :path, dir,
            :create,
            :is_dry_run, @is_dry,
            :filesystem, Home_.lib_.system.filesystem,
            & @listener )

          if ! kn
            ok = kn
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
          @document.write_to_path_by do |o|
            o.path = @path
            o.is_dry = @is_dry
            o.listener = @listener
          end
        end
      end

      def when_exist

        @listener.call :error, :directory_already_has_config_file do

          Common_::Event.inline_not_OK_with(
            :directory_already_has_config_file,
           :config_path, @path,
           :prop, @prop )
        end
      end
    end
  end
end
