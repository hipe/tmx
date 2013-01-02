module Skylab::Snag

  class CLI::Yamlizer

    emitter = PubSub::Emitter.new :line

    define_method :initialize do |fields, &wiring|
      @out = emitter.new wiring
      @fields = fields
      @maxlen = @fields.map { |x| x.to_s.length }.reduce { |m, o| m > o ? m : o}
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
