require_relative '../core'

RSpec::Matchers.define(:prettify_to) do |expected|
  actual = nil
  match do |_actual|
    actual = _actual.pretty.to_s
    actual == expected
  end
  failure_message_for_should do |_actual|
    "expected #{expected.inspect}, had #{actual.inspect}"
  end
  description do
    actual == expected ? "not change" :
      "prettify to #{expected.inspect}"
  end
end
