require File.expand_path('../../task', __FILE__)
require File.expand_path('../tarball-to', __FILE__)
require 'pathname'
require 'stringio'
require 'skylab/face/open2'
require 'skylab/face/path-tools'


module Skylab::Dependency
  class TaskTypes::ConfigureMakeMakeInstall < Task
    include ::Skylab::Face::Open2
    include ::Skylab::Face::PathTools
    include TaskTypes::TarballTo::Constants
    attribute :configure_make_make_install
    attribute :prefix
    attribute :configure_with, :required => false
    attribute :basename, :required => false
    def slake
      fallback.slake or return false
      dependencies_slake or return false
      execute false
    end
    def check
      execute true
    end
    def execute just_checking
      @just_checking = just_checking
      Pathname.new(@configure_make_make_install).tap do |p|
        dirname, basename = [p.dirname.to_s, p.basename.to_s]
        basename = get_dir_basename(basename) or return false
        @dir = File.join(dirname, basename)
      end
      if ! File.directory? @dir
        if dry_run?
          _pretending "directory exists", @dir
        else
          return nope("not a directory: #{@dir}")
        end
      end
      configure and make and make_install
    end
    def configure
      ( ok = check_configure or @just_checking ) and return ok
      configure_with and return _configure_with
      _command "cd #{escape_path @dir}; ./configure --prefix=#{escape_path prefix}"
    end
    def _configure_with
      _command "cd #{escape_path @dir}; source #{escape_path __configure_with}"
    end
    def __configure_with
      File.expand_path(configure_with, File.dirname(_closest_parent_list.path))
    end
    def _makefile
      @makefile ||= File.join(@dir, 'Makefile')
    end
    def check_configure
      if File.exist? _makefile
        _info("#{skp 'assuming'} configure'd b/c exists: " <<
          "#{pretty_path _makefile} (rename/rm it to re-configure).")
        true
      else
        if @just_checking
          _info "#{ohno 'nope:'} makefile not found: #{pretty_path _makefile}"
        end
        false
      end
    end
    def make
      ( ok = check_make or @just_checking ) and return ok
      _command "cd #{escape_path @dir}; make"
    end
    def check_make
      if (found = Dir[File.join(@dir, '*.o')]).any?
        _info "#{skp 'assuming'} make'd b/c exists: #{pretty_path found.first}"
        true
      else
        false
      end
    end
    def make_install
      ( ok = check_install or @just_checking ) and return ok
      _command "cd #{escape_path @dir}; make install"
    end
    def get_stem
      @stem and return @stem
      md = File.basename(@dir).match(/\A(?:lib)?(.*[^-\.\d])[-\.\d]+\z/)
      md or return _err("@stem not set and couldn't infer stem from #{@dir.inspect}")
      md[1]
    end
    URL_TO_BASENAME = /\A(.+)#{TARBALL_EXT}(?:\?.+)?\z/
    def get_dir_basename part
      @dir_basename and return @dir_basename
      md = URL_TO_BASENAME.match(part)
      md or return _err("@dir_basename not set and failed to infer basename from #{part.inspect}")
      md[1]
    end
    def check_install
      stem = get_stem or return
      dot_a = File.join(prefix, "lib/lib#{stem}.a") # e.g. /usr/local/lib/libpcre.a
      if File.exist?(dot_a)
        _info "#{skp 'assuming'} make install'd b/c exists: #{dot_a}"
        true
      else
        false
      end
    end
    def _command cmd
      if dry_run?
        if request[:view_bash]
          _show_bash cmd
        else
          _info "#{cmd} (#{yelo 'skipped'} per dry run, faking success)"
        end
        return true
      else
        _show_bash cmd
      end
      # multiplex two output streams into a total of four things
      out = ::Skylab::Face::Open2::Tee.new(:out => ui.out, :buffer => StringIO.new)
      err = ::Skylab::Face::Open2::Tee.new(:err => ui.err, :buffer => StringIO.new)
      open2(cmd, out, err)
      err[:buffer].rewind ; s = err[:buffer].read
      if "" != (s)
        _info "#{ohno 'nope:'} expecting empty string from stderr output, assuming build failed. had:"
        ui.err.puts "<snip>"
        ui.err.puts s
        ui.err.puts "</snip>"
        return false
      end
      true
    end
  end
end

