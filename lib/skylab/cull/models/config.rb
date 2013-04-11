module Skylab::Cull

  module Models::Config

    -> do
      fn = '.cullconfig'
      define_singleton_method :filename do fn end
    end.call

    module File
      Invalid = Models::Event.new do |cm_invalid_reason_o|
        cm_invalid_reason_o.render
      end
    end
  end
end
