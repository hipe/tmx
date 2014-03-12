module Skylab::Callback::TestSupport::Autoloader::Fixtures::Three::Level_1::
      Level_2::Leaf_3

  const_defined? :SOME_CONST and fail 'no, where?'
  SOME_CONST = :some_val
end
