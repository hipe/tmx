module Skylab::Snag

  class Models::Manifest

    class Tmpdir_produce__ < Agent_

      Entity_[ self, :fields,
        :file_utils,
        :is_dry_run,
        :tmpdir_pathname,
        :listener ]

      def execute
        if @tmpdir_pathname.exist?
          @tmpdir_pathname
        else
          create
        end
      end

    private

      def create
        if @tmpdir_pathname.dirname.exist?
          @file_utils.mkdir @tmpdir_pathname.to_path, noop: @is_dry_run
          @tmpdir_pathname
        else
          when_dirname_not_exist
        end
      end

      def when_dirname_not_exist
        _ev = bld_directory_must_exist_event
        bork_via_event _ev
      end

      def bld_directory_must_exist_event
        Snag_::Model_::Event.inline :directory_must_exist,
            :tmpdir_pathname, @tmpdir_pathname do |y, o|
          pn = o.tmpdir_pathname
          y << "won't create more than one directory. Parent directory #{
           }of our tmpdir (#{ pn.basename }) must exist: #{ pth pn.dirname }"
        end
      end
    end
  end
end
