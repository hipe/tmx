require 'skylab/face/open2'
require File.expand_path('../version', __FILE__)

module Skylab
  module Dependency
    class CheckUpdate
      def initialize path
        @versions_not_found = []
        @path = path
      end
      attr_reader :ui
      attr_reader :versions_not_found

      def run ui
        @versions_not_found.clear
        @ui = ui
        url = Version.parse_string_with_version(@path, :ui => ui) or return false
        version = url.detect(:version)
        increment_this = case true
          when version.has_patch_version? ; :patch
          when version.has_minor_version? ; :minor
          else fail("versions are expected always to have patch or minor versions")
        end
        found = nil
        loop do
          version.bump! increment_this
          cmd = "curl --head #{url}"
          _info cmd
          resp = `#{cmd}`.strip.split(/\r?\n/)
          response_code_header = resp.first
          if /200 OK$/ =~ response_code_header
            found = version.to_s
          else
            _info(response_code_header)
            @versions_not_found.push version.to_s
            break
          end
        end
        found or return false
        version.replace found
        url
      end
      def _info msg
        @ui.err.puts "---> #{msg}"
      end
    end
  end
end

