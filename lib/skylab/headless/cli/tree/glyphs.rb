module Skylab::Headless
  module CLI::Tree::Glyphs
    extend MetaHell::Boxxy        # BOXXY IS QUEEN
                                  # this stuff is just for reflection.

    g = CLI::Tree::Glyph

    BLANK     = g.new :blank
    CROOK     = g.new :crook
    PIPE      = g.new :pipe
    SEPARATOR = g.new :separator
    TEE       = g.new :tee
  end
end
