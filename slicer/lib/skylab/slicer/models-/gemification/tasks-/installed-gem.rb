module Skylab::Slicer

  class Models_::Gemification

    class Tasks_::Installed_Gem < Task_[]

      # (this is the one that does the heavy lift back to the major lazor of dada)

      depends_on(
        :Gemspec_File,
      )

      def execute

        __init_gem_resources

        _sct = @_gem_resources.install_current_version_if_necessary_of @_resources.sidesystem_path

        # (the above should have emitted everything we could have wanted to know)

        _sct.exitstatus.zero?
      end

      def __init_gem_resources

        @_resources = @Gemspec_File.resources_

        cache = @_resources.batch_cache
        rsx = cache[ ME__ ]

        if ! rsx
          _ = @_resources.this_other_script
          load _  # yikes
        end

        @_lib = ::Skylab_Slicer_OneOff_0  # do this whether or nto above, but always at this point

        if ! rsx
          rsx = @_lib::GemsInstallationFacade.new ::File, @_resources.stderr
          cache[ ME__ ] = rsx
        end

        @_gem_resources = rsx

        NIL
      end

      # -- A.

      # ==

      ME__ = self

      # ==
      # ==
    end
  end
end
# #history-A: full rewrite to DRY-up with initial installation script
