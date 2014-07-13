# encoding: UTF-8
module Skylab::Headless

  CLI::Tree::Glyph = ::Struct.new :normalized_glyph_name

  module CLI::Tree::Glyph::Sets

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

    # freeze each of the strings in case someone
    # accidentally mutates them (happened once or twice)

    constants.each do |i|
      const_get( i, false ).values.each( & :freeze )
    end
  end
end
