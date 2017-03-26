# encoding: UTF-8

module Skylab::Basic

  module Tree::Magnetics::TextGlyph_via_NodeCategory  # [#049].

    GlyphSets = ::Module.new

    GlyphSets::NARROW = {
          blank:     '  ',
          crook:     ' └',
          pipe:      ' │',
          separator: '/',
          tee:       ' ├'
        }

    GlyphSets::WIDE = {      # (these styles came to us later, and are
          blank:     '   ',  #  based off of the glyphs used in
          crook:     '└──',  #  Steve Baker et. al's `tree` unix utility.)
          pipe:      '│  ',
          separator: '/',
          tee:       '├──'
        }

    module GlyphSets
      constants.each do | sym |
        const_get( sym, false ).freeze.values.each( & :freeze )
      end
    end

    Glyph___ = ::Struct.new :normalized_glyph_name

    module Glyphs

      define_singleton_method :each_value, Autoloader_::Boxxy_::Reflection::Each_const_value_method

      -> g do

        BLANK     = g.new :blank
        CROOK     = g.new :crook
        PIPE      = g.new :pipe
        SEPARATOR = g.new :separator
        TEE       = g.new :tee

      end.call Glyph___
    end

    # ==
    # ==
  end
end
