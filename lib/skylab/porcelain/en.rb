require_relative '../../skylab'

module Skylab::Porcelain::En
  extend ::Skylab::Autoloader

  module Methods

    def oxford_comma a, ult = ' and ', sep = ', '
      (hsh = ::Hash.new(sep))[a.length - 1] = ult
      [a.first, * (1..(a.length-1)).map { |i| [ hsh[i], a[i] ] }.flatten].join
    end

    alias_method :and, :oxford_comma

    def or a
      oxford_comma a, ' or '
    end

    -> do # "#{s a, :no}known person#{s a} #{s a, :is} #{self.and a}".strip

      verbs = { is:   ['exist', 'is', 'are'],
                no:   ['no ', 'the only '],
              this: ['these', 'this', 'these'] }

      (norm = { 0 => 0, 1 => 1 }).default = 2

      define_method :s do |a, v=nil| # just one tine hard to read hack
        count = ::Numeric === a ? a : a.count
        if v
          verbs[v][norm[count]]
        else
          1 == count ? '' : 's'
        end
      end

    end.call

  end

  extend Methods # a.t.t.o.t.w some ppl still call En.oxford_comma as so
end
