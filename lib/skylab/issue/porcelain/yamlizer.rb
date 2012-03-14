require 'stringio'

module Skylab::Issue
  module Porcelain::Yamlizer
    class MyStringIO < ::StringIO
      alias_method :emit, :puts
      def to_s ; rewind ; read end
    end
    def my_yamlize object, fields
      e = MyStringIO.new
      meta = (@yamlizer_cache ||= {})[fields.object_id] ||= begin
        { maxlen: fields.reduce(0) { |m, f| m > f.to_s.length ? m : f.to_s.length } }
      end
      e.emit '---'
      fields.each do |f|
        e.emit "#{"%-#{meta[:maxlen]}s" % f} : #{object.send(f)}"
      end
      e.to_s
    end
  end
end

