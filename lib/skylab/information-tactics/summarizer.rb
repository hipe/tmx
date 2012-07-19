module Skylab ; end # etc

module Skylab::InformationTactics
  module Summarizer
    def ellipsis
      '..'
    end
    STEP = ->(out, struct) do
      hot = (0..out.length-1).map { |i| i if ::String != out[i].class }.compact
      strs = hot.select { |i| ::String == struct[i].class }
      if strs.length > 0
        strs.each { |i| out[i] = struct[i] }
        true
      else
        more = false
        hot.each do |i|
          out[i] ||= Array.new(struct[i].length)
          _more = STEP[out[i], struct[i]]
          if ! out[i].index { |x| ::String != x.class } # if result is all strings
            out[i] = out[i].join('')                    # make it just one string
            _more = false                               # and don't stay on my acct
          end
          _more and more = true
        end
        more
      end
    end
    def summarize maxlen, struct # order might change!
      ::String === struct and return truncate(maxlen, struct)
      -1 == maxlen and maxlen = nil
      out = Array.new(struct.length) ; prev = curr = ''
      more = true
      while ! maxlen || curr.length < maxlen and more
        more = STEP[out, struct]
        prev = curr
        curr = out.join
      end
      (! maxlen || curr.length <= maxlen) ? curr : prev
    end
    def truncate maxlen, str
      -1 == maxlen || maxlen.nil? and return str
      case 0 <=> (over = str.length - maxlen)
      when 1, 0 ; str
      else      ; "#{str[0, [0, maxlen - ellipsis.length].max]}#{ellipsis[0, maxlen]}"
      end
    end
  end
end
