require 'fileutils'

_ = "#{File.dirname(__FILE__)}/"
require "#{_}copy-files"
require "#{_}diffland"
require 'skylab/face/path-tools'

module Skylab::Tmx::Modules::Cli
  SkylabFolder = 'skylab'
  SkylabFiles = %w(
    code-molester/yaml-file.rb
    face/cli/external-dependencies.rb
    face/cli/interactive.rb
    face/cli.rb
    face/path-tools.rb
    face/request.rb
  )
  LocalFilesDir = File.expand_path("../../../../../#{SkylabFolder}", __FILE__)

  module Api; end

  module PushPullInstanceMethods
    include Skylab::Face::Colors, CopyFiles, Skylab::Face::PathTools
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
          true
        else
          @ui.err.puts "#{ohno("skipping: ")} destination directory doesn't exist: #{dir}"
          true
        end
      end
      on.different do |src, dest, file|
        # src = pretty_path(src)
        # dest = pretty_path(dest)
        if @opts[:force]
          FileUtils.cp(src, dest, :verbose => true, :noop => @opts[:dry_run])
          true
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
    # normalize and deducde a folder that exists that ends with "/skylab"
    def _dir label
      path = (@path =~ %r{\A(.*[^/])/?}) ? $1 : @path # strip trailing slash
      (%r{\A(.*)/#{SkylabFolder}\Z} =~ path) and path = $1
      path = File.join(path, SkylabFolder)
      File.directory?(path) or return @ui.err.puts("#{label} must be directory: #{path}")
      path
    end
    def _run src, dst, msg
      @ui.err.puts msg
      files = SkylabFiles
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
      remote_dir = _dir('Source') or return
      _run remote_dir, LocalFilesDir, "Pull from #{pretty_path(remote_dir)} into #{pretty_path(LocalFilesDir)}."
    end
  end

  class Api::Push
    include PushPullInstanceMethods
    extend PushPullClassMethods
    def run
      remote_dir = _dir('Destination') or return
      _run LocalFilesDir, remote_dir, "push from #{pretty_path(LocalFilesDir)} to #{pretty_path(remote_dir)}"
    end
  end
end
