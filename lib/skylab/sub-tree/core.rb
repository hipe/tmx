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

  module Test_Fixtures
    Autoloader_[ self ]
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  DOT_ = '.'.freeze

  Entity_ = -> * x_a do
    SubTree_::Lib_::Entity_via_iambic[ x_a ]
  end

  EMPTY_P_ = -> { }

  IDENTITY_ = -> x { x }

  stowaway :Lib_, 'library-'

  Name_ = Callback_::Name

  PROCEDE_ = true

  SEP_ = '/'.freeze

  SPACE_ = ' '.freeze

  Stop_at_pathname_ = -> do  #  # #open [#014] - - don't use this any more, ..
    rx = %r{\A[./]\z}  # hackishly - for all pn, parent eventually is this
    -> pn do
      rx =~ pn.instance_variable_get( :@path )
    end
  end.call

  SubTree = self
  SubTree_ = self

  UNABLE_ = false

end
