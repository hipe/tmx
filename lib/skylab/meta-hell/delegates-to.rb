module Skylab::MetaHell
  module DelegatesTo  # :[#052]
    def delegates_to fulfiller, *methods
      methods.each do |m|
        define_method( m ) { |*a, &b| send( fulfiller ).send m, *a, &b }
      end
    end
  end
end
