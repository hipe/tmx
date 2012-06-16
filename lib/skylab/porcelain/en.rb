module Skylab::Porcelain
  module En
    extend Skylab::Autoloader
    extend self
    def oxford_comma a, ult = ' and ', sep = ', '
      (hsh = Hash.new(sep))[a.length - 1] = ult
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end
    def s a
      count = Numeric === a ? a : a.count
      count == 1 ? '' : 's'
    end
  end
end

