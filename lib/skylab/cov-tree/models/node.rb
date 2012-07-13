require 'skylab/porcelain/tree/node'

module Skylab::CovTree
  class Models::Node < ::Skylab::Porcelain::Tree::Node
    def initialize h, &b
      @aliases = nil
      super(h, &b)
    end
    def slug
      self[:slug] or fail("node did no have a slug!")
    end
    def type
      self[:type] or fail("node did not have a type!")
    end
    def types
      Array === type ? type : [type]
    end
    def aliases?
      !! aliases
    end
    def aliases
      @aliases.nil? ? ( @aliases = begin
      if ! (:test == type and md = TEST_BASENAME_RE.match(slug))
        false
      else
        ["#{md.captures.detect { |x| x }}.rb"]
      end
      end ) : @aliases
    end
    attr_writer :aliases
  end
end

