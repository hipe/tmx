require File.expand_path('../../task', __FILE__)
require 'skylab/face/path-tools'
require 'fileutils'

module Skylab::Dependency
  class TaskTypes::MoveTo < Task
    include Skylab::Face::PathTools::InstanceMethods
    include FileUtils

    attribute :move_to, :required => true
    attribute :from, :required => true

    emits :all, :error => :all, :shell => :all

    def fu_output_message msg
      if md = /\Amv ([^ ]+) ([^ ]+)\z/.match(msg) # ''cosmetic shell''
        msg = "mv #{pretty_path md[1]} #{pretty_path md[2]}"
      end
      emit(:shell, msg)
    end

    def from= p
      _set_path :from, p
    end

    def execute args
      @context ||= (args[:context] || {})
      valid? or fail(invalid_reason)
      if ! from.exist?
        emit(:error, "file not found: #{pretty_path from}")
        return false
      end
      if move_to.exist?
        emit(:error, "file exists: #{pretty_path move_to}")
        return false
      end
      status = mv from, move_to, :verbose => true
      0 == status
    end

    def move_to= p
      _set_path :move_to, p
    end

    def _set_path name, path
      val = case path
            when NilClass ; nil
            when String   ; Pathname.new(path)
            when Pathname ; path
            else          ; raise ArgumentError.new("no: #{path}")
            end
      instance_variable_set("@#{name}", val)
      path
    end
  end
end

