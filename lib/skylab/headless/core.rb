require_relative '..'

require 'skylab/meta-hell/core'

class ::Object  # :2:[#sl-131] - experiment. this is the last extlib.
private
  def notificate i
  end
end

module Skylab::Headless  # ([#013] is reserved for a core node narrative - no storypoints yet)

  %i| Autoloader Headless MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  module Constants

    MAXLEN = 4096  # (2 ** 12), the number of bytes in about 50 lines
                   # used as a heuristic or sanity in a couple places
  end

  EMPTY_STRING_ = ''.freeze
  EMPTY_A_ = [ ].freeze
  IDENTITY_ = -> x { x }
  WRITEMODE_ = 'w'.freeze

  Private_attr_reader_ = MetaHell::FUN.private_attr_reader

  ::Skylab::Subsystem[ self ]

  MetaHell::MAARS[ self ]

end
module ::Skylab::Headless  # #todo:during-merge
  LINE_SEPARATOR_STRING_ = "\n".freeze
  TERM_SEPARATOR_STRING_ = ' '.freeze
  class Scn_ < ::Proc
    alias_method :gets, :call
  end
end
