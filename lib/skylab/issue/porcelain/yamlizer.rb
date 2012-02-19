require 'skylab/pub-sub/emitter'

module Skylab::Issue

  class Porcelain::Yamlizer
    KNOB = Skylab::PubSub::Emitter.new(:line)

    def initialize fields, &wiring
      @out = KNOB.new(wiring)
      @fields = fields
      @maxlen = @fields.map { |x| x.to_s.length }.reduce { |m, o| m > o ? m : o }
    end
    def line line
      @out.emit(:line, line)
    end
    def yamlize record
      line '---'
      @fields.each do |f|
        line "#{"%-#{@maxlen}s" % f} : #{record.send(f)}"
      end
      nil
    end
    alias_method :[], :yamlize
  end
end

