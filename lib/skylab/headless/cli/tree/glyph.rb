# encoding: UTF-8
module Skylab::Headless
  class CLI::Tree::Glyph < ::Struct.new :name
    # (used elsewhere for reflection.)
  end

  module CLI::Tree::Glyph::Sets

    _freeze = -> h do
      h.values.each(& :freeze )
      nil
    end


    WIDE = {                      # (these styles came to us later, and are
      blank:     '   ',           # based off of the glyphs used in
      crook:     '└──',           # Steve Baker et. al's `tree` unix utility.)
      pipe:      '│  ',
      separator: '/',
      tee:       '├──'
    }

    _freeze[ WIDE ]

    NARROW = :foo
  end
end
