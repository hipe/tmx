require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Module::Creator::ModuleMethods

  ::Skylab::MetaHell::TestSupport::Module::Creator[ TS_ = self ]

  include CONSTANTS

  MetaHell_ = MetaHell_ # #annoying
  Module = Module # #annoying

  FUN = MetaHell_.lib.struct_from_hash(
    :done_p => -> struct do
      -> name do
        struct[name] = FUN.done_msg_p[ name ]
      end
    end,
    :done_msg_p => -> name do
      -> do
        Stderr_[].puts "NEVER AGAIN: #{name}"  # just a sanity check
      end
    end
  )
end
