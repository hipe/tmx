require_relative '../test-support'
require_relative '../../core'

module Skylab::Porcelain::Bleeding::TestSupport
  Bleeding = ::Skylab::Porcelain::Bleeding
  Porcelain = ::Skylab::Porcelain
  SimplifiedEvent = Struct.new(:type, :message) # hack for prettier dumps ick!

  class ::RSpec::Matchers::DSL::Matcher
    include ::Skylab::Porcelain::En::Number
  end

  class MyEmitSpy < ::Skylab::TestSupport::EmitSpy
    def initialize(&formatter)
      formatter ||= ->(e) { "#{e.type.inspect}<-->#{e.message.inspect}" }
      super(&formatter)
    end
  end

  RSpec::Matchers.define(:be_action) do |expected|
    actual = nil ; fails = [] ; desc = {}
    match do |_actual|
      actual = _actual
      expected.each do |exp_key, exp|
        case exp_key
        when :aliases
          desc[:aliases] = "whose aliases are #{exp.inspect}"
          actual.aliases == exp or fails.push("expected aliases of #{exp.inspect}, had #{actual.aliases.inspect}")
        when :desc
          desc[:desc] = "whose description lines are #{exp.inspect}"
          actual.desc == exp or fails.push("expected description lines of #{exp.inspect}, had #{actual.desc.inspect}")
        else fail("unimplemented: #{exp_val}")
        end
      end
      fails.empty?
    end
    failure_message_for_should { |_actual| fails.join('. ') }
    description do
      'be an action{{aliases}}{{desc}}'.gsub(/{{((?:(?!}})[^{])+)}}/) do
        " #{desc[$1.intern]}" if desc[$1.intern]
      end.strip
    end
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
    failure_message_for_should { |__actual| fails.join('. ') }
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
    rt = MyEmitSpy.new
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
    def with_action action_token
      once = ->(_) do
        send("#{constantize ns_token}__#{constantize action_token}") # call the creator
        action = Bleeding::NamespaceInferred.new(base_module.const_get(constantize ns_token)).
          build(MyEmitSpy.new.debug!).fetch(action_token)
        instance_eval(& (once = ->(_) { action }))
      end
      let(:fetch) { instance_eval(&once) }
      let(:subject) { fetch }
    end
    def with_namespace token
      let(:ns_token) { token }
    end
  end
  module InstanceMethods
    include ::Skylab::Autoloader::Inflection # constantize
    include ::Skylab::MetaHell::ModulCreator::InstanceMethods
    include ::Skylab::MetaHell::KlassCreator::ExtensorInstanceMethods
    include ::Skylab::Porcelain::TiteColor # unstylize
    attr_reader :base_module
    def namespace
      @nermsperce
    end
  end
end
