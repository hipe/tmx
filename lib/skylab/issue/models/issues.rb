require 'date'
require 'pathname'
require 'skylab/face/path-tools'

module Skylab::Issue
  class Models::Issues
    include ::Skylab::Face::PathTools
    def add message, opts
      _update_attributes opts
      with_manifest do |m|
        m.path_resolved? or return false
        m.message_valid?(message) or return false
        m.add_issue(
          :date    => todays_date,
          :message => message
        )
      end
    end
    attr_accessor :dry_run
    alias_method :dry_run?, :dry_run
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
    def todays_date
      DateTime.now.strftime(DATE_FORMAT)
    end
    def _update_attributes opts
      opts.each { |k, v| send("#{k}=", v) }
    end
    def with_manifest
      res = nil
      @emitter or fail("emitter not set.")
      @manifest or fail("manifest not set.")
      @manifest.emitter = @emitter # ick threads
      @manifest.dry_run = dry_run?
      begin
        res = yield(manifest)
      ensure
        if @manifest
          @manifest.emitter = nil
          @manifest.dry_run = true # ick
        end
      end
      res
    end
  end
end

