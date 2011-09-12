require 'pathname'
require File.expand_path('../../task', __FILE__)
require File.expand_path('../../../open2', __FILE__)
require File.expand_path('../../../path-tools', __FILE__)
require 'stringio'

module Skylab::Face
  class DependencyGraph
    class TaskTypes::ConfigureMakeMakeInstall < Task
      include Open2
      include PathTools
      attribute :configure_make_make_install
      attribute :prefix
      def slake
        interpolated? or interpolate! or return false
        slake_else or return false
        execute false
      end
      def check
        interpolated? or interpolate! or return false
        execute true
      end
      def execute just_checking
        @just_checking = just_checking
        Pathname.new(@configure_make_make_install).tap do |p|
          dirname, basename = [p.dirname.to_s, p.basename.to_s]
          @dir = File.join(dirname, basename.sub(/\.tar\.gz\z/,''))
        end
        File.directory?(@dir) or return nope("not a directory: #{@dir}")
        configure and make and make_install
      end
      def configure
        ( ok = check_configure or @just_checking ) and return ok
        _command "cd #{escape_path @dir}; ./configure --prefix=#{escape_path prefix}"
      end
      def check_configure
        makefile = File.join(@dir, 'Makefile')
        if File.exist? makefile
          @ui.err.puts "#{me}: exists, assuming configure'd: " <<
            "#{pretty_path makefile} (rename/rm it to re-configure)."
          true
        else
          false
        end
      end
      def make
        ( ok = check_make or @just_checking ) and return ok
        _command "cd #{escape_path @dir}; make"
      end
      def check_make
        if (found = Dir[File.join(@dir, '*.o')]).any?
          @ui.err.puts "#{me}: exists, assuming make'd: #{pretty_path found.first}"
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
          @ui.err.puts "#{me}: exists, assuming make install'd: #{dot_a}"
          true
        else
          false
        end
      end
      def _command cmd
        @ui.err.puts "#{me}: #{cmd}"
        # multiplex two output streams into a total of four things
        out = Open2::Tee.new(:out => @ui.out, :buffer => StringIO.new)
        err = Open2::Tee.new(:err => @ui.err, :buffer => StringIO.new)
        open2(cmd, out, err)
        err[:buffer].rewind ; s = err[:buffer].read
        "" != (s) and return nope("expecing empty string from stderr output, had: #{s.inspect}")
        true
      end
    end
  end
end
