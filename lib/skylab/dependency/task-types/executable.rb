require File.expand_path('../../task', __FILE__)
require 'stringio'
require 'skylab/face/open2'

module Skylab::Dependency
  class TaskTypes::Executable < Task
    include ::Skylab::Face::Open2
    attribute :executable, :required => true

    emits :all, :info => :all

    def execute context
      @context ||= (context[:args] || {})
      valid? or fail invalid_reason
      if '' == (path = open2("which #{executable}").strip)
        emit(:info, "#{no 'not in PATH:'} #{executable}")
        false
      else
        emit(:info, path)
        true
      end
    end
  end
end

