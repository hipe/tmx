require File.expand_path('../../task', __FILE__)
require 'skylab/face/open2'

module Skylab
  module Dependency
    class TaskTypes::UnzipTarball < Task
      include ::Skylab::Face::Open2
      include ::Skylab::Face::PathTools
      attribute :unzip_tarball
      attribute :unzips_to, :required => false
      def slake
        fallback.slake or return false
        check(false) and return true
        execute
      end
      def check verbose = true
        if File.directory?(expected_unzipped_dir_path)
          _info "ok: is directory: #{pretty_path expected_unzipped_dir_path}"
          true
        else
          verbose and _info("expected unzipped dir path not found: #{pretty_path expected_unzipped_dir_path}")
        end
      end
      def check_size path
        if 0 < File.stat(path).size
          true
        else
          _info "#{me}: cannot unzip, file is zero size: #{pretty_path path}"
          false
        end
      end
      def expected_unzipped_dir_path
        if @unzips_to
          File.join(build_dir, @unzips_to)
        else
          @unzip_tarball.sub(TarballExtension, '')
        end
      end
      def execute
        unless File.exist?(@unzip_tarball)
          return _err("tarball not found: #{pretty_path @unzip_tarball}")
        end
        check_size(@unzip_tarball) or return
        cmd = "cd #{escape_path build_dir}; tar -xzvf #{escape_path File.basename(@unzip_tarball)}"
        _info cmd
        bytes, seconds = open2(cmd) do |on|
          on.out { |s| ui.err.write("#{me}: (out): #{s}") }
          on.err { |s| ui.err.write(s) }
        end
        _info "read #{bytes} bytes in #{seconds} seconds."
        check and return true
        _err "failed to unzip?"
      end
      def interpolate_stem
        fallback.interpolate_stem
      end
      def _defaults!
        if true == @unzip_tarball
          @unzip_tarball = '{build_dir}/{basename}'
        end
      end
    end
  end
end

