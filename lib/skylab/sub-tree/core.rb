require_relative '../callback/core'

module Skylab::SubTree

  const_defined?( :Callback_, false ) and fail 'whre?'

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  module API
    module Actions
      Autoloader_[ self ]
    end
    Autoloader_[ self ]
  end

  module Core
    Autoloader_[ self ]
  end

  DOT_ = '.'.freeze
  Name_ = Callback_::Name
  SEP_ = '/'.freeze

  Stop_at_pathname_ = -> do  # #todo
    rx = %r{\A[./]\z}  # hackishly - for all pn, parent eventually is this
    -> pn do
      rx =~ pn.instance_variable_get( :@path )
    end
  end.call

  SubTree = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Lib_, 'library-'

end
