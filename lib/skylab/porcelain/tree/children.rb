module Skylab::Porcelain
  class Tree::Children < Array
    def initialize
      @slugs = {}
    end
    def [] slug
      Integer === slug and return super(slug)
      @slugs.key?(slug) or return nil
      super @slugs[slug]
    end
    def []= slug, val
      Integer === slug ? super : set(slug, val)
    end
    def set slug, *slugs, new
      idx = killme = nil
      slugs.unshift slug
      (slugs & @slugs.keys).each do |s|
        (killme ||= {})[@slugs.delete(s)] = true
      end
      killme and killme.keys.each { |i| (idx ||= i) ; self[i] = nil }
      idx ||= length
      slugs.each { |s| @slugs[s] = idx }
      self[idx] = new
    end
  end
end
