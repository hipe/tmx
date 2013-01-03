module Skylab::Snag
  module Models::Tag

    rx = /\A[-a-z]+\z/
    define_singleton_method :rx do rx end

  end
end
