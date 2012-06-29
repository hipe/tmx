require_relative '../test-support'
require_relative '../../bleeding'

module Skylab::Porcelain::Bleeding::TestSupport
  Bleeding = ::Skylab::Porcelain::Bleeding
  Porcelain = ::Skylab::Porcelain
  SimplifiedEvent = Struct.new(:type, :message) # hack for prettier dumps ick!

  Matcher = Struct.new(:desc, :failmsg, :match)

  class ::RSpec::Matchers::DSL::Matcher
    include ::Skylab::Porcelain::En::Number
  end

  RSpec::Matchers.define(:be_event) do |*expected|
    # the below hooks must be called in the order: MATCH [FAIL_MSG] DESCRPTION
    fails = [] ; desc = {} ; _actual = nil
    match do |actual|
      _actual = actual ; idx = actual.length - 1 ; index_specified = false
      expected.each do |x|
        case x
        when Fixnum
          desc[:pos] = '%-6s' % [num2ord(x + 1)]
          idx = x ; index_specified = true
        when NilClass
          desc[:type] = "no more events."
          if actual.length != idx
            fails.push("expected exactly #{idx} events, had #{actual.length}")
          end
        when String
          if actual[idx].message == x
            desc[:msg] = x.inspect
          else
            fails.push("expected message #{x.inspect}, had #{actual[idx].message.inspect}")
            desc[:msg] = x
          end
        when Symbol
          if actual[idx].type == x
            desc[:type] = actual[idx].type.inspect
          else
            fails.push("expected type #{x.inspect}, had #{actual[idx].type.inspect}")
            desc[:type] = x.inspect
          end
        when Regexp
          if actual[idx].message =~ x
            desc[:msg] = actual[idx].message.inspect
          else
            fails.push("expected message to match #{x.inspect}, had #{actual[idx].message.inspect}")
            desc[:msg] = x
          end
        else
          fail("no: #{x.inspect}")
        end
      end
      index_specified or 1 == actual.length or fails.push("expected 1 event, had #{actual.length}")
      fails.empty?
    end
    failure_message_for_should do |actual|
      fails.join('. ')
    end
    description do
      'emit{{pos}}{{type}}{{msg}}'.gsub(/{{((?:(?!}})[^{])+)}}/) { " #{desc[$1.intern]}" if desc[$1.intern] }.strip
    end
  end
end
