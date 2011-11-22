require 'strscan'

module Skylab
  module Slake
    module Interpolation
      def interpolate!
        ok = Interpolation.new(self).interpolate!
        ok and @interpolated = true
        ok
      end
      attr_reader :interpolated
      alias_method :interpolated?, :interpolated
    end
    class Interpolation::Interpolation
      def initialize host
        @host = lambda{ host } # always have clean dumps (temp debuggin)
      end
      def host ; @host[] end
      def interpolate!
        @interpolate_me = _parsed_interpolatable_attribute_values
        @found_strategy = { }
        @missing_strategy = Hash.new { |h, k| h[k] = [] }
        _determine_strategies! or return false
        _resolve_graph!
      end
      def _determine_strategies!
        @interpolate_me.each do |o|
          o[:placeholders].each do |oo|
            if @found_strategy.key?(oo[:name])
              oo[:strategy] = @found_strategy[oo[:name]]
            else
              if host.respond_to?(m1 = "interpolate_#{oo[:name]}")
                oo[:strategy] = :interpolating_method
              elsif host.respond_to?(oo[:name]) and ! host.send(oo[:name]).nil?
                oo[:strategy] = :getter_method
              elsif host.fallback? and fb = host.fallback
                if fb.respond_to?(m1)
                  oo[:strategy] = :fallback_interpolating_method
                  oo[:_fb] = fb
                elsif fb.respond_to?(oo[:name])
                  oo[:strategy] = :fallback_getter_method
                  oo[:_fb] = fb
                end
              end
              if oo[:strategy]
                @found_strategy[oo[:name]] = oo[:strategy]
              else
                fail_meta = oo.dup
                fail_meta[:_interp] = m1
                fail_meta[:_fb] = fb
                fail_meta[:_orig_string] = o[:orig_string]
                @missing_strategy[oo[:name]].push fail_meta
              end
            end
          end
        end
        @missing_strategy.any? and return _err(_explain_missing_strategy)
        true
      end
      def _explain_missing_strategy
        _err(
          "#{@missing_strategy.keys.map(&:inspect).join(', ')} could not be interpolated" <<
          " in #{@missing_strategy.values.map { |a| a.map { |o| o[:_orig_string].inspect } }.flatten(1).uniq.join(', ')}. " <<
          @missing_strategy.map { |k, v|
            f = v.first
            "The #{host.name.inspect} task node has no #{k.inspect} getter nor defines a #{v.first[:_interp].inspect} method" <<
              ( f[:_fb] ? " and ditto for its ('else') node #{f[:_fb].name.inspect}." : " and had no 'else' node." )
          }.join(' ')
        )
      end
      def _resolve_graph!
        host = self.host
        @interpolate_me.each do |o|
          scn = StringScanner.new o[:orig_string]
          cheap_ast = []
          loop do
            scn.eos? and break
            cheap_ast.push scn.scan %r@([^{]|{(?![- a-z]))*@
            scn.eos? and break
            cheap_ast.push (scn.scan %r@{[_ a-z]+}@).match(%r@\A{(.+)}\z@)[1].intern
          end
          interpolated = cheap_ast.each_with_index.map do |m, idx|
            if idx % 2 == 0
              m
            else
              oo = o[:placeholders].shift or fail("logix whoopsie")
              oo[:name].intern == m       or fail("logix whoopsie")
              case oo[:strategy]
                when :interpolating_method          ; src = host;     meth = "interpolate_#{oo[:name]}"
                when :getter_method                 ; src = host;     meth = oo[:name]
                when :fallback_interpolating_method ; src = oo[:_fb]; meth = "interpolate_#{oo[:name]}"
                when :fallback_getter_method        ; src = oo[:_fb]; meth = oo[:name]
                else                                ; fail("logix whoopsie")
              end
              _ = src.send(meth)
              _.nil? and fail("#{src.name}##{meth} returned nil (unacceptable as a placeholder value).")
              _
            end
          end.join('')
          host.send("#{o[:getter]}=", interpolated)
        end
        @interpolate_me.length # return any trueish
      end

      def _err msg
        host._fail "Interpolation Fail: #{msg}"
        false # above should raise exception so this should never get here
      end

      def _parsed_interpolatable_attribute_values
        host = self.host
        host.class.attributes.keys.map do |k|
          if (str = host.send(k)).kind_of?(String)
            names = str.scan(/\{[ _a-z0-9]+\}/).map{|s| /\A\{(.*)\}\z/.match(s)[1]}
            { :getter => k, :orig_string => str, :placeholders => names.map { |n| { :name => n } } } if names.any?
          end
        end.compact
      end
      attr_reader :interpolated
      alias_method :interpolated?, :interpolated
      class << self
        def intern name
          name.gsub(' ', '_').intern
        end
      end
    end
  end
end
