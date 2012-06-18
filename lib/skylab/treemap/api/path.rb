require 'skylab/face/path-tools'

module Skylab::Treemap
  class API::Path < Skylab::Face::MyPathname
    attr_writer :forceless
    def forceless?
      @forceless.call
    end
  end
end

