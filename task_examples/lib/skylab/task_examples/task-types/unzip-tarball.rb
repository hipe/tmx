module Skylab::TaskExamples

  class TaskTypes::UnzipTarball < Common_task_[]

    depends_on_parameters(
      build_dir: [ :_from_context ],
      filesystem: nil,
      output_dir: :optional,
      unzip_tarball: nil,
    )

    def initialize
      @do_strip_version_number = true
      super
    end

    def execute

      ok = __check_that_source_tarball_exists
      ok &&= __resolve_derivative_paths
      ok &&= __check_that_source_tarball_file_is_nonzero_length
      if ok
        if __procure_that_output_path_exists
          ACHIEVED_  # skip
        else
          ___work
        end
      else
        ok
      end
    end

    def ___work

      s_a = __build_command_string_array

      __emit_this_command_string_array s_a

      _opt_h = { chdir: @build_dir }  # :#here

      err = Home_::Library_::StringIO.new

      _ = Home_.lib_.system

      bytes, seconds = _.open2 s_a, nil, nil, _opt_h do |on|

        on.out do |s|
          self._COVER_ME_probably_fine_to_just_output_this  # output this..
        end

        on.err do |s|  # usually just informational output
          err.write s
          @_oes_p_.call :info, :expression do |y|
            y << s
          end
        end
      end

      s = err.string

      if s.length.nonzero?
        _lines = s.split NEWLINE_
        a = _lines.grep %r(\bunrecognized archive format\b)i
        if a.length.nonzero?
          err_s = a.fetch 0
        end
      end

      ___conclude err_s, seconds, bytes
    end

    def ___conclude err_s, seconds, bytes

      if err_s

        @_oes_p_.call :error, :expression do |y|
          y << "Failed to unzip: #{ err_s }"
        end

        UNABLE_
      else

        if seconds >= SIGNIFICANT_SECONDS___

          @_oes_p_.call :info, :expression do |y|
            y << "read #{ bytes } bytes in #{ seconds } seconds."
          end
        end

        ACHIEVED_
      end
    end

    SIGNIFICANT_SECONDS___ = 1.0

    def __emit_this_command_string_array s_a

      esc = Home_::Library_::Shellwords.method :shellescape

      buff = "cd #{ esc[ @build_dir ] };"
      s_a.each do |s|
        buff.concat SPACE_
        buff.concat esc[ s ]
      end

      @_oes_p_.call :info, :expression, :system_command do |y|
        y << buff
      end

      NIL_
    end

    def __build_command_string_array

      s_a = [ "tar", "-xzvf" ]
      s_a.push @unzip_tarball
      s_a
    end

    def __procure_that_output_path_exists

      if @filesystem.exist? @_destination_directory
        ___express_that_output_path_exists
        true
      end
    end

    def ___express_that_output_path_exists

      path = @_destination_directory

      @_oes_p_.call :info, :expression do |y|
        y << "exists, won't tar extract: #{ pth path }"
      end
      NIL_
    end

    def __check_that_source_tarball_file_is_nonzero_length
      if @_stat.size.zero?
        ___when_zero_length_file
      else
        ACHIEVED_
      end
    end

    def ___when_zero_length_file
      path = @unzip_tarball
      @_oes_p_.call :error, :expression do |y|
        y << "tarball is zero length - #{ pth path }"
      end
      UNABLE_
    end

    def __check_that_source_tarball_exists

      begin
        stat = @filesystem.stat @unzip_tarball
      rescue ::Errno::ENOENT => e
      end

      if stat
        @_stat = stat ; ACHIEVED_
      else
        ___when_no_ent e
      end
    end

    def ___when_no_ent e

      _eek = /\A(?:(?! @).)+/.match( e.message )[ 0 ]
      path = @unzip_tarball

      @_oes_p_.call :error, :expression do |y|
        y << "#{ _eek } - #{ pth path }"
      end
      UNABLE_
    end

    def __resolve_derivative_paths

      s = ::File.basename @unzip_tarball

      s.gsub! Tarball_extension___[], EMPTY_S_

      if @do_strip_version_number
        s.gsub! Version_rx___[], EMPTY_S_
      end

      @_destination_directory = ::File.join @build_dir, s

      ACHIEVED_
    end

    Tarball_extension___ = Lazy_.call do
      Home_::TaskTypes::TarballTo::Constants::TARBALL_EXTENSION
    end

    Version_rx___ = Lazy_.call do
      /-#{ Home_::Version::REGEX.source }/
    end
  end
end
