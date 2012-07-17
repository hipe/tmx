module Skylab ; end # etc

module Skylab::InformationTactics
  module Summarizer
    def ellipsis_string
      '..'
    end
    def summarize maxlen, struct # order might switch
      ::String === struct and return truncate(maxlen, struct)
      struct
    end
    def truncate maxlen, str
      -1 == maxlen || maxlen.nil? and return str
      case 0 <=> (over = str.length - maxlen)
      when 1, 0 ; return str
      end
      if (ellipsis_string = self.ellipsis_string).length >= over
        return ellipsis_string[0, maxlen]
      end
      str
    end
  end
end
