require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Modul::Creator::ModuleMethods
  (Parent_ = ::Skylab::MetaHell::TestSupport::Modul::Creator)[ self ] # #ts-002

  MM_TestSupport = self # courtesy

  module CONSTANTS
    include Parent_::CONSTANTS
  end

  include CONSTANTS

  MetaHell = MetaHell # #annoying
  Modul = Modul # #annoying

  FUN = MetaHell::Struct[ {
    :done_f => -> struct do
      -> name do
        struct[name] = FUN.done_msg_f[ name ]
      end
    end,
    :done_msg_f => -> name do
      -> do
        $stderr.puts "NEVER AGAIN: #{name}"  # just a sanity check
      end
    end
  } ]
end
