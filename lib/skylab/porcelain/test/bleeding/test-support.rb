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
      expected.each_with_index do |x, i|
        case x
        when Fixnum
          desc[:pos] = '%-6s' % [-1 == x ? 'last' : num2ord(x + 1)]
          -1 == x and x = actual.length - 1
          idx = x ; index_specified = true
          if actual.length <= idx and expected[i+1]
            fails.push("expecting event at index #{idx}, had #{actual.length} events")
            break
          end
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
      'emit{{pos}}{{type}}{{msg}}'.gsub(/{{((?:(?!}})[^{])+)}}/) do
        " #{desc[$1.intern]}" if desc[$1.intern]
      end.strip
    end
  end
  last_number = 0
  BUILD_NAMESPACE_RUNTIME = ->(_) do
    @base_module = ::Module.new
    ::Skylab::Porcelain::Bleeding.const_set("Xyzzy#{last_number += 1}", @base_module)
    @nermsperce = m = modul(:MyActions, &namespace_body)
    m = modul(:MyActions, &namespace_body)
    ns = Bleeding::NamespaceInferred.new(m)
    rt = ::Skylab::TestSupport::EmitSpy.new { |e| "#{e.type.inspect}<-->#{e.message.inspect}" } # add debug!
    # ns.build(rt).object_id == ns.object_id or fail("handle this")
    [ns, rt]
  end
  module ModuleMethods
    include ::Skylab::MetaHell::KlassCreator
    def events &specify_body
      specify(&specify_body)
      tok = @last_token
      once = ->(_) do
        ns, rt = instance_eval(&BUILD_NAMESPACE_RUNTIME)
        ns.find(tok) { |o| o.on_error { |e| rt.emit(SimplifiedEvent.new(e.type, unstylize(e.message))) } }
        _use = rt.stack
        (once = ->(_) { _use }).call(nil)
      end
      let(:subject) { instance_eval(&once) }
    end
    def namespace &b
      let(:namespace_body) { b }
    end
    def result &specify_body
      tok = @last_token
      once = ->(_) do
        ns, rt = instance_eval(&BUILD_NAMESPACE_RUNTIME)
        _res = ns.find(tok) { |o| o.on_error { |e| $stderr.puts("EXpecting no events here (xyzzy) #{e}") } }
        (once = ->(_) { _res }).call(nil)
      end
      let(:subject) { instance_eval(&once) }
      specify do
        instance_eval(&once) # this must be run before the body of the specify block is evaluated
        instance_exec(&specify_body)
      end
    end
    def token tok
      @last_token = tok
    end
  end
  module InstanceMethods
    include ::Skylab::MetaHell::ModulCreator::InstanceMethods
    include ::Skylab::Porcelain::TiteColor # unstylize
    attr_reader :base_module
    def namespace
      @nermsperce
    end
  end
end
