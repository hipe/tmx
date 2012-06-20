require_relative '../../skylab'

module Skylab::Porcelain
  module En
    extend Skylab::Autoloader
    extend self

    def oxford_comma a, ult = ' and ', sep = ', '
      (hsh = Hash.new(sep))[a.length - 1] = ult
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end

    alias_method :and, :oxford_comma

    def or a
      oxford_comma a, ' or '
    end

    VERBS = { is:   ['exist', 'is', 'are'],
              no:   ['no ', 'the only '],
            this: ['these', 'this', 'these'] }

    def s a, v=nil # just one tiny hard to read hack
      count = Numeric === a ? a : a.count
      v.nil? and return( 1 == count ? '' : 's' )
      VERBS[v][case count ; when 0 ; 0 ; when 1 ; 1 ; else 2 ; end]
    end
    # "#{s a, :no}known person#{s a} #{s a, :is} #{self.and a}".strip

  end
end

