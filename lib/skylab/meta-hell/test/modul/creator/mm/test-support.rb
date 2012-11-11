require_relative '../test-support'

module ::Skylab::MetaHell::TestSupport::Modul::Creator::ModuleMethods
  ::Skylab::MetaHell::TestSupport::Modul::Creator[ self ]

  MM_TestSupport = self

  MetaHell = MetaHell # #nec
  Modul = MetaHell::Modul # #nec

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
