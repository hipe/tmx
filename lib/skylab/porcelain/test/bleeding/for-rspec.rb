module Skylab::Porcelain::TestSupport::Bleeding

  mustache_rx = Porcelain._lib.string_lib.mustache_regexp

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
      'be an action{{aliases}}{{desc}}'.gsub( mustache_rx ) do
        " #{desc[$1.intern]}" if desc[$1.intern]
      end.strip
    end
  end

  ::RSpec::Matchers.define :be_event do |*event_a|
    # the below hooks must be called in the order: MATCH [FAIL_MSG] DESCRPTION

    nub = Callback_::TestSupport::Event::Predicate::Nub.new expected
    nub.textify = -> emission { emission.payload_x }
    nub.unstyle_all_styled!
    match(& nub.handle_match )
    failure_message_for_should(& nub.handle_failure_message_for_should )
    description(& nub.handle_description )
  end
end
