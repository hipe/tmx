module Skylab ; end

module Skylab::Slake
  module Parenthood
    def init_parenthood
      @has_parent = false
    end
    attr_reader :has_parent
    def parent ; nil end
    def parent= parent # @todo make canonincal
      @has_parent and raise RuntimeError.new("can't overwrite existing parent")
      @has_parent = true
      singleton_class.send(:define_method, :parent) { parent }
      parent
    end
   alias_method :parent?, :has_parent
  end
end

