require 'rubygems'
require 'treetop'

module Hipe; end

class Treetop::Runtime::CompiledParser
  #
  # careful! we monkeypatch this one b/c we don't like not having quotes around strings.
  #
  def failure_reason
    return nil unless (tf = terminal_failures) && tf.size > 0
    "Expected " +
      (tf.size == 1 ?
       tf[0].expected_string.inspect :
             "one of #{tf.map{|f| f.expected_string.inspect}.uniq*', '}"
      ) +
            " at line #{failure_line}, column #{failure_column} (byte #{failure_index+1})" +
            " after #{input[index...failure_index].inspect}"
  end
end
