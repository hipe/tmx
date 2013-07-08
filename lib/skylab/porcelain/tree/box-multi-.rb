module Skylab::Porcelain
  class Tree::Children < ::Array

    def [] slug
      if ::Integer === slug
        super
      elsif @slugs.key? slug
        super @slugs[slug]
      end
    end

    def []= slug, val
      if ::Integer === slug
        super
      else
        set slug, val
      end
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

  protected

    def initialize
      @slugs = { }
    end
  end
end
