require File.expand_path('../../task', __FILE__)
require 'skylab/face/path-tools'
require 'fileutils'

module Skylab::Dependency
  class TaskTypes::MoveTo < Task
    include Skylab::Face::PathTools
    include FileUtils
    attribute :move_to
    attribute :from
    def initialize(*a)
      super(*a)
      @fileutils_output = request[:view_bash] ? ui.out : ui.err
      @fileutils_label =  request[:view_bash] ? '' : _prefix
    end
    def slake
      if File.exist?(@move_to)
        _info "desintation exists (move/rename to re-run): #{@move_to}"
        true
      else
        if ! File.exist?(@from) and fallback?
          fallback.slake or return false
        end
        execute
      end
    end
    def check
      _src = File.exist? @from
      _dst = File.exist? @move_to
      if dry_run?
        if ! _src
          _pretending "exists", @file
        end
        if _dst
          _info "exists: #{@move_to}"
          true
        else
          _info "does not exist: #{@move_to}"
          false
        end
      else
        if ! _src
          _info "source file not found: #{@from}"
          false
        elsif _dst
          _info "exists: #{@move_to}"
          true
        else
          _info "does not exist: #{@move_to}"
          false
        end
      end
    end
    def execute
      if File.exist?(@from) or dry_run?
        mv(@from, @move_to, :verbose => true, :noop => dry_run?) # _show_bash
        true
      else
        _info "FAILED: source file not found: #{@from}"
        false
      end
    end
    def _undo
      if File.exist?(@move_to)
        if ! File.exist?(@from)
          mv(@move_to, @from, :verbose => true)
        else
          _info "can't undo: exists: #{pretty_path @from}"
          false
        end
      else
        _info "nothing to undo: does not exist: #{@move_to}"
        false
      end
    end
  end
end

