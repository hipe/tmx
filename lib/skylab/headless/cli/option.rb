module Skylab::Headless

  module CLI::Option

    Option = self

    def self.on *a, &b
      const_get( :Model_, false ).on( *a, &b )
    end

    def self.new_flyweight
      const_get( :Model_, false ).new_flyweight
    end

    FUN = ::Struct.new( :normize ).new( -> x do  # part of [#hl-081] family
      x.gsub( '-', '_' ).downcase.intern
    end )
  end
end
