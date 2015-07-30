# encoding: UTF-8
module Skylab::Headless

  module CLI::Tree__  # :[#172].

    class << self

      def glyph_sets_module
        Glyph_::Sets
      end

      def glyphs
        Glyphs__
      end
    end

    Glyph_ = ::Struct.new :normalized_glyph_name

    class Glyph_

      module Sets

        NARROW = {
          blank:     '  ',
          crook:     ' └',
          pipe:      ' │',
          separator: '/',
          tee:       ' ├'
        }

        WIDE = {             # (these styles came to us later, and are
          blank:     '   ',  #  based off of the glyphs used in
          crook:     '└──',  #  Steve Baker et. al's `tree` unix utility.)
          pipe:      '│  ',
          separator: '/',
          tee:       '├──'
        }

        constants.each do |i|
          const_get( i, false ).freeze.values.each( & :freeze )
        end
      end
    end

    module Glyphs__

      define_singleton_method :each_const_value, Autoloader_.each_const_value_method

      -> g do
        BLANK     = g.new :blank
        CROOK     = g.new :crook
        PIPE      = g.new :pipe
        SEPARATOR = g.new :separator
        TEE       = g.new :tee
      end.call Glyph_
    end
  end
end
