require_relative '..'

module Skylab::Snag

  %i| Autoloader MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  MetaHell::MAARS[ self ]

  module Core
    MetaHell::MAARS::Upwards[ self ]
  end

  IDENTITY_ = -> x { x }

  stowaway :Lib_, 'library-'

  Snag_ = self

end
