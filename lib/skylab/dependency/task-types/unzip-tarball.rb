require File.expand_path('../../task', __FILE__)
require File.expand_path('../tarball-to', __FILE__)
require'skylab/face/open2'

module Skylab
  module Dependency
    class TaskTypes::UnzipTarball < Task
      include ::Skylab::Face::Open2
      include ::Skylab::Face::PathTools
      attribute :unzip_tarball
      attribute :unzips_to, :required => false
      attribute :basename, :required => false
      include TaskTypes::TarballTo::Constants
      def check
        if File.directory? expected_unzipped_dir_path
          _info "#{skp 'assuming'} unzipped already (#{yelo 'careful'} no checksums used): #{pretty_path expected_unzipped_dir_path}"
          true
        else
          false
        end
      end
      def slake
        check and return true # short circuit further work (common)
        fallback.slake or return false
        execute
      end
      def execute
        check_source or return false
        check_size(@unzip_tarball) or return false
        cmd = "cd #{escape_path build_dir}; tar -xzvf #{escape_path File.basename(@unzip_tarball)}"
        _show_bash cmd
        if dry_run?
          _pretending "above."
          bytes, seconds = [0, 0.0]
        else
          bytes, seconds = open2(cmd) do |on|
            on.out { |s| ui.err.write("#{me}: (out): #{s}") }
            on.err { |s| ui.err.write(s) }
          end
        end
        _info "read #{bytes} bytes in #{seconds} seconds."
        if File.directory?(expected_unzipped_dir_path)
          true
        elsif optimistic_dry_run?
          true
        else
          _err "expected unzipped directory did not exist: #{pretty_path expected_unzipped_dir_path}"
          false
        end
      end
      def check_source
        if File.exist? @unzip_tarball
          true
        elsif optimistic_dry_run?
          _pretending "exists", @unzip_tarball
          true
        else
          _err("tarball not found: #{pretty_path @unzip_tarball}")
        end
      end
      def check_size path
        if File.exist? path
          if 0 < File.stat(path).size
            true
          elsif optimistic_dry_run?
            _pretending "file has nonzero size", path
            true
          else
            _info "cannot unzip, file is zero size: #{pretty_path path}"
            false
          end
        elsif optimistic_dry_run?
          _pretending "file exists and has nonzero size", path
          true
        else
          _err "file not found: #{path}"
        end
      end
      def expected_unzipped_dir_path
        if @unzips_to
          File.join(build_dir, @unzips_to)
        else
          @unzip_tarball.sub(TARBALL_EXTENSION, '')
        end
      end
      def _defaults!
        if true == @unzip_tarball
          @unzip_tarball = '{build_dir}/{basename}'
        end
      end
    end
  end
end

