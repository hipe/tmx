module Skylab::Porcelain::TestSupport::Bleeding

  ::RSpec::Matchers.define :be_action do |expected|
    actual = nil ; fails = [] ; desc = {}
    match do |_actual|
      actual = _actual
      expected.each do |exp_key, exp|
        case exp_key
        when :aliases
          desc[:aliases] = "whose aliases are #{exp.inspect}"
          actual.aliases == exp or fails.push("expected aliases of #{
            exp.inspect}, had #{actual.aliases.inspect}")
        when :desc
          desc[:desc] = "whose description lines are #{exp.inspect}"
          actual.desc == exp or fails.push("expected description lines of #{
            exp.inspect}, had #{actual.desc.inspect}")
        else fail("unimplemented: #{exp_val}")
        end
      end
      fails.empty?
    end
    failure_message_for_should { |_actual| fails.join('. ') }
    description do
      'be an action{{aliases}}{{desc}}'.gsub(MUSTACHE_RX) do
        " #{desc[$1.intern]}" if desc[$1.intern]
      end.strip
    end
  end

  num2ord = Headless::NLP::EN::Number::FUN.num2ord

  ::RSpec::Matchers.define :be_event do |*expected|
    # the below hooks must be called in the order: MATCH [FAIL_MSG] DESCRPTION
    fails = [] ; desc = {} ; _actual = nil
    match do |actual|
      _actual = actual ; idx = actual.length - 1 ; index_specified = false
      expected.each_with_index do |x, i|
        case x
        when ::Fixnum
          desc[:pos] = '%-6s' % [-1 == x ? 'last' : num2ord[ x + 1 ]]
          -1 == x and x = actual.length - 1
          idx = x ; index_specified = true
          if actual.length <= idx and expected[i+1]
            fails.push("expecting event at index #{idx
              }, had #{actual.length} events")
            break
          end
        when ::NilClass
          desc[:type] = "no more events."
          if actual.length != idx
            fails.push("expected exactly #{idx} events, had #{actual.length}")
          end
        when ::String
          if actual[idx].string == x
            desc[:msg] = x.inspect
          else
            fails.push("expected message #{x.inspect
              }, had #{actual[idx].string.inspect}")
            desc[:msg] = x
          end
        when ::Symbol
          if actual[idx].stream_name == x
            desc[:type] = x.inspect
          else
            fails.push("expected type #{x.inspect
              }, had #{actual[idx].stream_name.inspect}")
            desc[:type] = x.inspect
          end
        when ::Regexp
          if actual[idx].string =~ x
            desc[:msg] = actual[idx].string.inspect
          else
            fails.push("expected message to match #{x.inspect
              }, had #{actual[idx].string.inspect}")
            desc[:msg] = x
          end
        else
          fail("no: #{x.inspect}")
        end
      end
      index_specified or 1 == actual.length or
        fails.push("expected 1 event, had #{actual.length}")
      fails.empty?
    end
    failure_message_for_should { |__actual| fails.join('. ') }
    description do
      'emit{{pos}}{{type}}{{msg}}'.gsub(MUSTACHE_RX) do
        " #{desc[$1.intern]}" if desc[$1.intern]
      end.strip
    end
  end
end
