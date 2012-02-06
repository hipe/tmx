require 'pathname'
require 'skylab/face/path-tools'

module Skylab::Issue
  class Models::Issues
    include ::Skylab::Face::PathTools
    def add message, opts
      _update_attributes opts
      @emitter or fail("emitter not set.")
      @manifest or fail("manifest not set.")
      @manifest.emitter = @emitter # ick threads
      res = nil
      begin
        @manifest.path_resolved? or return false
        @manifest.message_valid?(message) or return false
        emit :info, "pretending to add issue: #{message.inspect} to manifest: #{pretty_path @manifest.path}"
        res = true
      ensure
        @manifest and @manifest.emitter = nil
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
    def _update_attributes opts
      opts.each { |k, v| send("#{k}=", v) }
    end
  end
end

