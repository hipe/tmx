module Skylab::CssConvert
  module Parser::InstanceMethods
    include CssConvert::SubClient::InstanceMethods
    def entity
      self.class.const_get(:ENTITY_NOUN_STEM)
    end
    def parse_file pn
      String === pn and pn = MyPathname.new(pn)
      pn.exist? or return error("#{entity} not found: #{pn.pretty}")
      pn.directory? and return error("expecing #{entity}, had directory: #{pn.pretty}")
      parse_string pn.read
    end
    def parse_string whole_string
      result = parser.parse(whole_string)
      result or emit(:error, (parser.failure_reason || "Got nil from parse without reason!"))
      result ? result.tree : result
    end
    def parser
      @parser ||= parser_class.new
    end
  end
end
