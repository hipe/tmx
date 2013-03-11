# encoding: UTF-8
module Skylab::Headless

  class CLI::Tree::Glyph < ::Struct.new :normalized_glyph_name
    # (used elsewhere for reflection.)
  end

  module CLI::Tree::Glyph::Sets
    extend MetaHell::Boxxy        # BOXXY IS QUEEN OF METAPROGRAMming


    WIDE = {                      # (these styles came to us later, and are
      blank:     '   ',           # based off of the glyphs used in
      crook:     '└──',           # Steve Baker et. al's `tree` unix utility.)
      pipe:      '│  ',
      separator: '/',
      tee:       '├──'
    }

    NARROW = {
      blank:     '  ',
      crook:     ' └',
      pipe:      ' │',
      separator: '/',
      tee:       ' ├'
    }

    each do |gs|                  # freeze each of the strings in case
      gs.values.each(& :freeze )  # someone accidentally mutates them
    end                           # (it's happened once or twice :P)
  end
end
