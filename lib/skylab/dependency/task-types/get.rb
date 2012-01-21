require File.expand_path('../../task', __FILE__)
require 'skylab/face/open2'
require 'skylab/face/path-tools'
require 'pathname'

module Skylab
  module Dependency
    class TaskTypes::Get < Task
      include ::Skylab::Face::Open2
      include ::Skylab::Face::PathTools
      attribute :from, :required => false
      attribute :get

      def basename
        File.dirname get # for children, leave this as accessor
      end

      def check
        results = pairs.map do |from_url, to_file|
          bytes = _bytes(to_file)
          case bytes
          when nil
            _info "would get: #{from_url}"
            false
          when 0
            _info "had zero byte file (strange): (#{pretty_path to_file}). Would overwrite."
            false
          else
            _info "exists (remove/move to download again): #{pretty_path to_file} (#{bytes} bytes)"
            true
          end
        end
        ! results.index { |b| ! b }
      end

      def slake
        do_these = []
        pairs.each do |from_url, to_file|
          bytes = _bytes(to_file)
          case bytes
          when nil
            do_these.push [from_url, to_file]
          when 0
            _info "had zero byte file (strange), overwriting: #{pretty_path to_file}"
            do_these.push [from_url, to_file]
          else
            _info "#{skp 'assuming'} already downloaded b/c exists (erase/move to re-download): #{pretty_path to_file}"
          end
        end
        results = []
        do_these.each do |from_url, to_file|
          res = curl_or_wget(from_url, to_file)
          results.push res
        end
        ! results.index { |b| ! b }
      end

    protected

      def pairs
        if @from.nil?
          Pathname.new(@get).tap { |pn| @from = pn.dirname.to_s; @get = pn.basename.to_s }
        end
        get_these = @get.kind_of?(Array)?  @get : [@get]
        get_these.map do |tail|
          [File.join(@from, tail), File.join(build_dir, tail)]
        end
      end

      def _bytes path
        File.stat(path).size if File.exist?(path)
      end

        def curl_or_wget from_url, to_file
          # cmd = "wget -O #{::Skylab::Face::PathTools.escape_path to_file} #{from_url}"
          cmd = "curl -OL h #{from_url} > #{::Skylab::Face::PathTools.escape_path to_file}"
          _show_bash cmd
          bytes, seconds =
          if dry_run?
            [0, 0.0]
          else
            ::Skylab::Face::Open2.open2(cmd) do |on|
              on.out { |s| _info "#{_}(out): #{s}" }
              on.err { |s| ui.err.write(s) }
            end
          end
          _info "read #{bytes} bytes in #{seconds} seconds."
          true # what does success mean to you
        end
      end

  end
end

