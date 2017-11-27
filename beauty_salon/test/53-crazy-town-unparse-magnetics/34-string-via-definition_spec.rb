# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town unparse magnetics - string via definition', ct: true do

    # NOTE - `def` can exist without formal args, but the convserse is not
    # true. and separately, we can hopefully cover modules and classes
    # relatively independently from most shapes.

    # that is why this file occurs relatively early in the order, so that
    # we can establish these guys before covering the Variable shape next.

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_unparsing

    it 'def' do
      orig = "  def frob\n    nil\n  end\n  # hello\n"
      _actual = string_via_string_losslessly_ orig
      _actual == "def frob\n    nil\n  end" || fail
    end

    it 'class' do
      orig = "class Foo::Bar\n      cha_cha\n  end"
      _actual = string_via_string_losslessly_ orig
      _actual == orig || fail
    end
  end
end
# #born.
