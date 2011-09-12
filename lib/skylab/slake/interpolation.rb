module Skylab
  module Slake
    module Interpolation
      class << self
        def to_key name
          name.gsub(' ', '_').intern
        end
      end
      def interpolate!
        keys = uninterpolatable_keys
        interpolated_via_methods = self.interpolated_via_methods.dup
        if keys.any?
          @else or return interpolation_fail(keys, <<-HERE.gsub(/\A */, '').gsub(/\n */, ' ')
            because there are no defined method(s) (e.g. #{keys.map{|k| "interpolate_#{k}".inspect}.join(', ')})
            and it has no \"else\" node to satisfy unresolved variable names
          HERE
          )
          (node = parent_graph.node(@else)) or return interpolation_fail(keys, "because else node not found (see above)")
          node.interpolate! or return interpolation_fail(keys, "(because of above errors)")
          (keys = uninterpolatable_keys).any? and return interpolation_fail(keys, "after interpolating upstream")
        end
        uninterpolated.each do |attrib, names|
          value = send(attrib)
          value.kind_of?(String) or return interpolation_fail([attrib], "because it was not a string (had: #{value.inspect})")
          names.each do |name|
            name_as_key = Interpolation.to_key(name)
            if idx = interpolated_via_methods.index(name_as_key)
              interpolated_value = send("interpolate_#{name}")
              request[name_as_key] = interpolated_value # ick careful
              interpolated_via_methods[idx] = nil
            else
              interpolated_value =  request[name_as_key]
            end
            value.gsub!("{#{name}}", interpolated_value)
          end
          send("#{attrib}=", value)
        end
        interpolated_via_methods.compact.each do |sym|
          request[sym] = send("interpolate_#{sym}") # ick, easier just to do them all
        end
        @interpolated = true
      end

      def interpolation_fail(things, because)
        @ui.err.puts "Failed to interpolate (#{things.map(&:inspect).join(', ')}) of #{task_type_name.inspect} #{because}"
        false
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
    end
  end
end
