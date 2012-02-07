require 'skylab/porcelain/tree/node'

module Skylab::CovTree
  class Node < ::Skylab::Porcelain::Tree::Node
    def slug
      self[:slug] or fail("node did no have a slug!")
    end
    def type
      self[:type] or fail("node did not have a type!")
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

