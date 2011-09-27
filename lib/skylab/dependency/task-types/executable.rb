require File.expand_path('../../task', __FILE__)
require 'stringio'
require 'skylab/face/open2'

module Skylab
  module Dependency
    class TaskTypes::Executable < Task
      include ::Skylab::Face::Open2
      attribute :executable
      def check
        if '' == (path = open2("which #{@executable}").strip)
          _info "#{ohno('not in PATH:')} #{@executable}"
          false
        else
          _info path
        end
      end
    end
  end
end

