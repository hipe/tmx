require File.expand_path('../../task', __FILE__)
require File.expand_path('../tarball-to', __FILE__)
require 'pathname'
require 'stringio'
require 'skylab/face/open2'
require 'skylab/face/path-tools'


module Skylab
  module Dependency
    class TaskTypes::ConfigureMakeMakeInstall < Task
      include ::Skylab::Face::Open2
      include ::Skylab::Face::PathTools
      include TaskTypes::TarballTo::Constants
      attribute :configure_make_make_install
      attribute :prefix
      attribute :configure_with, :required => false
      attribute :basename, :required => false
      alias_method :interpolate_basename, :basename
     end
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
          @dir = File.join(dirname, basename.sub(self.class::TARBALL_EXTENSION,''))
        end
        File.directory?(@dir) or return nope("not a directory: #{@dir}")
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
          ui.err.puts "#{_prefix}#{me}: exists, assuming configure'd: " <<
            "#{pretty_path _makefile} (rename/rm it to re-configure)."
          true
        else
          if @just_checking
            ui.err.puts "#{_prefix}#{me}: #{ohno 'nope:'} makefile not found: #{pretty_path _makefile}"
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
          ui.err.puts "#{me}: exists, assuming make'd: #{pretty_path found.first}"
          true
        else
          false
        end
      end
      def make_install
        ( ok = check_install or @just_checking ) and return ok
        _command "cd #{escape_path @dir}; make install"
      end
      def check_install
        stem = File.basename(@dir).match(/\A(.*[^-\.\d])[-\.\d]+\z/)[1]
        dot_a = File.join(prefix, "lib/lib#{stem}.a") # e.g. /usr/local/lib/libpcre.a
        if File.exist?(dot_a)
          ui.err.puts "#{me}: exists, assuming make install'd: #{dot_a}"
          true
        else
          false
        end
      end
      def _command cmd
        ui.err.write "#{_prefix}#{me}: #{cmd}"
        if request[:dry_run]
          ui.err.puts " (#{yelo 'skipped'} per dry run, faking success)"
          return true
        else
          ui.err.puts
        end
        # multiplex two output streams into a total of four things
        out = ::Skylab::Face::Open2::Tee.new(:out => ui.out, :buffer => StringIO.new)
        err = ::Skylab::Face::Open2::Tee.new(:err => ui.err, :buffer => StringIO.new)
        open2(cmd, out, err)
        err[:buffer].rewind ; s = err[:buffer].read
        if "" != (s)
          ui.err.puts "#{_prefix}#{me}: #{ohno 'nope:'} expecting empty string from stderr output, assuming build failed. had:"
          ui.err.puts "<snip>"
          ui.err.puts s
          ui.err.puts "</snip>"
          return false
        end
        true
      end
    end
  end
end

