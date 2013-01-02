module Skylab::Snag

  class CLI::Yamlizer

    def yamlize record
      line '---'

      fmt = "%-#{ @maxlen }s"

      record.yaml_data_pairs.each do |field_name, string_value|
        line "#{ fmt % field_name } : #{ string_value }"
      end

      nil
    end

    alias_method :[], :yamlize

  protected

    emitter = PubSub::Emitter.new :line

    define_method :initialize do |field_names, &wiring|
      @out = emitter.new wiring
      @maxlen = field_names.reduce( 0 ) do |m, sym|
        x = sym.to_s.length
        m > x ? m : x
      end
    end

    def line line
      @out.emit :line, line
    end
  end
end
