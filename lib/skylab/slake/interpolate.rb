require 'strscan'

module Skylab::Slake
  module Interpolate         # deprecated for Basic::String::Template [#ba-005]
    extend self
    def interpolate string, source
      Interpolation.new(source, string).run
    end
  end
  module Interpolator
    def interpolate string
      Interpolate::Interpolation.new(self, string).run
    end
  end
end

module Skylab::Slake::Interpolate
  class Interpolation
    def initialize source, string
      @source = source
      @string = string
    end
    @mutexes = {}
    def run
      scn = StringScanner.new @string
      cheap_ast = []
      loop do
        scn.eos? and break
        cheap_ast.push scn.scan %r@([^{]|{(?![- a-z]))*@
        scn.eos? and break
        s = scn.scan %r@{[_ a-z]+}@
        sym = s.match( %r@\A{(.+)}\z@ )[1].intern
        cheap_ast.push sym
      end
      cheap_ast.each_with_index.map do |str_or_sym, idx|
        if idx % 2 == 0
          str_or_sym
        else
          Interpolation.mutex(@source, str_or_sym) do
            @source.send(str_or_sym)
          end
        end
      end.join('')
    end
  end
  class << Interpolation
    def mutex obj, method
      id = :"#{obj.object_id}.#{method}"
      @mutexes.key?(id) and raise RuntimeError.new("circular depdendency: #{obj.class}##{method}")
      @mutexes[id] = true
      result = nil
      begin
        result = yield
      ensure
        @mutexes.delete id
      end
      result
    end
  end
end
