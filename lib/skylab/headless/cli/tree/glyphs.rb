module Skylab::Headless

  module CLI::Tree::Glyphs

    g = CLI::Tree::Glyph

    BLANK     = g.new :blank
    CROOK     = g.new :crook
    PIPE      = g.new :pipe
    SEPARATOR = g.new :separator
    TEE       = g.new :tee

    define_singleton_method :each_const_value,
      Autoloader_.each_const_value_method

  end
end
