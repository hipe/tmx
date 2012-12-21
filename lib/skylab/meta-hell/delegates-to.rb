module Skylab::MetaHell
  module DelegatesTo
    def delegates_to fulfiller, *methods
      methods.each do |m|
        define_method( m ) { |*a, &b| send( fulfiller ).send m, *a, &b }
      end
    end
  end
end
