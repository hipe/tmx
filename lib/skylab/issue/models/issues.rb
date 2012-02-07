require 'pathname'
require 'skylab/face/path-tools'

module Skylab::Issue
  class Models::Issues
    include ::Skylab::Face::PathTools
    def add message, opts
      _update_attributes opts
      res = nil
      with_manifest do |m|
        m.path_resolved? or return false
        m.message_valid?(message) or return false
        emit :info, "pretending to add issue: #{message.inspect} to manifest: #{pretty_path @manifest.path}"
        res = true
      end
      res
    end
    attr_accessor :dry_run
    def emit t, m
      @emitter.emit t, m
    end
    attr_accessor :emitter
    def initialize opts
      _update_attributes opts
    end
    attr_accessor :manifest
    def numbers &block
      with_manifest do |m|
        m.numbers(&block)
      end
    end
    def _update_attributes opts
      opts.each { |k, v| send("#{k}=", v) }
    end
    def with_manifest
      res = nil
      @emitter or fail("emitter not set.")
      @manifest or fail("manifest not set.")
      @manifest.emitter = @emitter # ick threads
      begin
        res = yield(manifest)
      ensure
        @manifest and @manifest.emitter = nil
      end
      res
    end
  end
end

