module Skylab::TaskExamples

  class TaskTypes::TarballTo < Common_task_[]

    depends_on_parameters(

      build_dir: :_from_context,
      filesystem: nil,
      tarball_to: nil,
      url: nil,
    )

    depends_on_call :Get, :parameter, :get, :via_parameter, :url

    def execute

      source = @Get.units_of_work.last.destination_path
      dest = @tarball_to

      p = Home_::Library_::Shellwords.method :shellescape

      @_oes_p_.call :info, :expression, :fake_shell do |y|
        y << "mv #{ p[ source ] } #{ p[ dest ] }"
      end

      d = @filesystem.rename source, dest
      if d.zero?
        ACHIEVED_
      else
        self._COVER_ME_failed_to_rename_file
      end
    end

    module Constants

      TARBALL_EXT = /\.tar\.(?:gz|bz2)|\.tgz/ # #bound

      TARBALL_EXTENSION = /(?:#{TARBALL_EXT.source})\z/ # #bound
    end
  end
end
