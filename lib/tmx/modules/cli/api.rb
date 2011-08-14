require 'fileutils'

_ = "#{File.dirname(__FILE__)}/"
require "#{_}copy-files"
require "#{_}diffland"
require "#{_}pretty-path"

module Skylab::Tmx::Modules::Cli
  Files = %w(cli.rb cli/external-dependencies.rb)
  LocalFilesDir = File.expand_path('../../../face', __FILE__)

  module Api; end

  module PushPullInstanceMethods
    include Skylab::Face::Colors, CopyFiles, PrettyPath
    def initialize *a
      @ui, @path, @opts = a
    end
    def copy_files_block on
      on.identical do |src, dest|
        @ui.err.puts "#{yelo('no change: ')} #{src} #{dest}"
        true
      end
      on.missing_source do |src|
        @ui.err.puts "#{yelo('not found:')} Couldn't find source file: #{src}"
        true
      end
      on.missing_destination do |src, dst|
        if File.directory?(dir = File.dirname(dst))
          FileUtils.cp(src, dst, :noop => @opts[:dry_run], :verbose => true)
        else
          @ui.err.puts "#{ohno("skipping: ")} destination directory doesn't exist: #{dir}"
          true
        end
      end
      on.different do |src, dest, file|
        src = pretty_path(src)
        dest = pretty_path(dest)
        if @opts[:force]
          FileUtils.cp(src, dest, :verbose => true, :noop => @opts[:dry_run])
        else
          diff_cmd = "diff -u #{dest} #{src}"
          @ui.err.puts "#{yelo('changed:')} \"#{file}\". (Use -F option to clobber #{dest}.)"
          if @opts[:diff]
            Diffland.run(diff_cmd, :stdout => @ui.out, :stderr => @ui.err)
          else
            @ui.err.puts "(Use --diff to see.) (diff cmd: #{diff_cmd})"
          end
        end
        true
      end
    end
    def _dir label
      dir = /\A(.+)\/#{Regexp.escape(Files.first)}\z/ =~ @path ? $1 : @path
      File.directory?(dir) or return @err.puts("#{label} must be directory: #{dir}")
      dir
    end
    def _run src, dst, msg
      @ui.err.puts msg
      files = Files
      if @opts[:pattern]
        re = /#{@opts[:pattern].sub(/\A\/(.+)\/\z/){ "#{$1}" }}/
        (files = files.grep(re)).empty? and
          return @ui.err.puts("Found no files matching pattern /#{re.source}/.")
      end
      copy_files(files, src, dst, &method(:copy_files_block))
    end
  end

  module PushPullClassMethods
    def run *a
      new(*a).run
    end
  end

  class Api::Pull
    include PushPullInstanceMethods
    extend PushPullClassMethods
    def run
      dir = _dir('Source') or return
      _run dir, LocalFilesDir, "Pull from #{pretty_path(dir)} into #{pretty_path(LocalFilesDir)}."
    end
  end

  class Api::Push
    include PushPullInstanceMethods
    extend PushPullClassMethods
    def run
      dir = _dir('Destination') or return
      _run LocalFilesDir, dir, "push from #{pretty_path(LocalFilesDir)} to #{pretty_path(dir)}"
    end
  end
end
