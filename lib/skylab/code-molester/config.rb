require 'pathname'
require 'skylab/face/path-tools'
require 'skylab/slake/muxer'

module Skylab::CodeMolester
  class Config < Pathname
    # This thing is a stub
    extend ::Skylab::Slake::Muxer
    emits :all, :info => :all, :error => :all
    attr_accessor :content
    def content? ; !! @content end
    def initialize(*a, &b)
      b and b.call(self)
      super(*a)
    end
    def pretty
      ::Skylab::Face::PathTools.pretty_path(to_s)
    end
    def write
      exist? and fail("won't ever overwrite for now")
      content? or fail("won't ever write null content for now")
      content = self.content # detect errors early
      bytes = nil
      open('w+') { |fh| bytes = fh.write(content) }
      bytes
    end
  end
end

