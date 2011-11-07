module Skylab
  module Slake
    module Interpolation
      def interpolate!
        keys = uninterpolatable_keys
        interpolated_via_methods = self.interpolated_via_methods.dup
        unused_interpolated_via_methods = interpolated_via_methods.dup
        if keys.any?
          @else or return _interpolation_fail_undefined(keys)
          (node = parent_graph.node(@else)) or return _interpolation_fail(keys, "because else node not found (see above)")
          node.interpolate! or return _interpolation_fail(keys, "(because of above errors)")
          (keys = uninterpolatable_keys).any? and return _interpolation_fail(keys, "after interpolating upstream")
        end
        uninterpolated.each do |attrib, names|
          value = send(attrib)
          value.kind_of?(String) or return _interpolation_fail([attrib], "because it was not a string (had: #{value.inspect})")
          names.each do |name|
            name_as_key = Interpolation.to_key(name)
            if idx = interpolated_via_methods.index(name_as_key)
              interpolated_value = send("interpolate_#{name}")
              interpolated_value.nil? and fail("#{self.name} did a bad thing and returned nil for inpterpolate_#{name}")
              request[name_as_key] ||= interpolated_value # ick careful
              unused_interpolated_via_methods[idx] = nil
            else
              interpolated_value = request[name_as_key]
              interpolated_value.nil? and fail("wtf for interpoalted valued #{name_as_key.inspect} this was last straw")
            end
            interpolated_value.nil? and return _interpolation_fail([attrib], "because interpolated value was nil")
            value.gsub!("{#{name}}", interpolated_value)
          end
          send("#{attrib}=", value)
        end
        unused_interpolated_via_methods.compact.each do |sym|
          request[sym] ||= send("interpolate_#{sym}") # ick, easier just to do them all
        end
        @interpolated = true
      end

      def _interpolation_fail(things, because)
        ui.err.puts "Failed to interpolate (#{things.map(&:inspect).join(', ')}) of #{task_type_name.inspect} #{because}"
        false
      end

      def _interpolation_fail_undefined things
        _interpolation_fail(things, <<-HERE.gsub(/\A */, '').gsub(/\n */, ' ')
          because there are no defined method(s) (e.g. #{keys.map{|k| "interpolate_#{k}".inspect}.join(', ')})
          and it has no \"else\" node to satisfy unresolved variable names
        HERE
        )
      end

      def uninterpolatable_keys
        still_need = []
        have_keys = request.keys + interpolated_via_methods
        uninterpolated.each do |var, names|
          still_need.concat( names.map{ |s| Interpolation.to_key(s) } - have_keys )
        end
        still_need.uniq
      end

      def interpolated_via_methods
        methods.grep(/\Ainterpolate_./).map{ |x| /\Ainterpolate_(.+)\z/.match(x)[1].intern }
      end

      def uninterpolated
        self.class.attributes.keys.map do |k|
          if (str = self.send(k)).kind_of?(String)
            names = str.scan(/\{[_a-z0-9]+\}/).map{|s| /\A\{(.*)\}\z/.match(s)[1]}
            names.any? ? [k, names] : nil
          end
        end.compact
      end
      attr_reader :interpolated
      alias_method :interpolated?, :interpolated
      class << self
        def to_key name
          name.gsub(' ', '_').intern
        end
      end
    end
  end
end
