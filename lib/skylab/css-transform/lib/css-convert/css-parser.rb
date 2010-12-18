module Hipe::CssConvert
  module CssParsing
    here = File.dirname(__FILE__)+'/css-parsing'
    Grammars.load "#{here}/common"
    Grammars.load "#{here}/css-file"
  end
  class CssParser < CssParsing::CssFileParser

    # override that of Treetop::Runtime::CompiledParser so that it doesn't
    # dump so much content
    def failure_reason
      return nil unless (tf = terminal_failures) && tf.size > 0
      "Expected " +
        (tf.size == 1 ?
         tf[0].expected_string.inspect :
               "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
        ) +
              " at line #{failure_line}, column #{failure_column} (byte #{failure_index+1})" +
              " after#{my_input_excerpt}"
    end
    def my_num_lines_context
      4
    end
    def my_input_excerpt
      slicey = input[index...failure_index]
      all_lines = slicey.split("\n", -1)
      these_lines = all_lines.slice([0, -1 * my_num_lines_context].max, all_lines.size)
      numbers = failure_line.downto([1, failure_line - my_num_lines_context + 1].max).to_a.reverse
      w = numbers.last.to_s.size # greatest line number as string, how many chars wide?
      ":\n" + numbers.zip(these_lines).map{ |no, line| ("%#{w}i" % no) + ": #{line}" }.join("\n")
    end
  end
end
