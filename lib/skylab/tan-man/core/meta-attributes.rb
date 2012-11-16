module Skylab::TanMan::Core

  module MetaAttributes
    extend TanMan::Boxxy::Methods
    singleton_class.send :alias_method, :[], :const_fetch_all
  end

  module MetaAttributes::Boolean extend Porcelain::AttributeDefiner
    meta_attribute :boolean do |name, meta|
      alias_method "#{name}?", name
    end
  end

  module MetaAttributes::Default extend Porcelain::AttributeDefiner
    meta_attribute :default
  end
  module MetaAttributes::Default::InstanceMethods
    def set_defaults_if_nil!
      attribute_definer.attributes.select { |k, v| v.key?(:default) and send(k).nil? }.each do |k, h|
        (val = h[:default]).respond_to?(:call) and ! h[:proc] and val = val.call
        send("#{k}=", val)
      end
    end
  end

  module MetaAttributes::MutexBooleanSet extend Porcelain::AttributeDefiner
    meta_attribute :mutex_boolean_set do |name, h|
      set = h[:mutex_boolean_set]
      alias_method(after = "#{name}_after_mutex_boolean_set=", "#{name}=")
      define_method("#{name}=") do |value|
        intern = String === value ? value.intern : value # always normalize strings for now, you cannot use them
        if set.include?(intern)
          send(after, intern)
        else
          error_emitter.error("#{name} cannot be #{value.inspect}.  It must be "<<
            "#{Porcelain::En.oxford_comma(set.map { |o| o.to_s.inspect })}")
          value
        end
      end
      set.each do |intern|
        define_method("#{intern}?") { intern == send(name) }
      end
    end
  end

  module MetaAttributes::Pathname extend Porcelain::AttributeDefiner
    meta_attribute :pathname do |name, _|
      alias_method(after = "#{name}_after_pathname=", "#{name}=")
      define_method("#{name}=") do |path|
        send(after, path ? ::Skylab::Face::MyPathname.new(path.to_s) : path)
        path
      end
    end
  end

  module MetaAttributes::Proc extend Porcelain::AttributeDefiner
    meta_attribute :proc do |name, _|
      alias_method(get_proc = "#{name}_proc", name)
      define_method(name) do |&block|
        if block
          self.send("#{name}=", block)
        else
          send(get_proc)
        end
      end
    end
  end

  module MetaAttributes::Regex extend Porcelain::AttributeDefiner
    meta_attribute :on_regex_fail
    meta_attribute :regex do |name, meta|
      alias_method(after = "#{name}_after_regex=", "#{name}=")
      define_method("#{name}=") do |str|
        if (re = meta[:regex]) =~ str
          send(after, str)
        else
          error_emitter.error(meta[:on_regex_fail] || "#{str.inspect} did not match pattern for #{name}: /#{re.source}/")
          str
        end
      end
    end
  end

  # @note: this requires that the object define an attribute_definer that responds to attributes()
  # and it requires an error_emitter and it requires the styler methods: oxford_comma, pre.
  # A required attribute is considered as not provided IFF it returns nil.
  #
  module MetaAttributes::Required extend Porcelain::AttributeDefiner
    meta_attribute :required
  end
  module MetaAttributes::Required::InstanceMethods
    def required_ok?
      if (a = attribute_definer.attributes.map.select { |k, h| h[:required] && send(k).nil? }).size.nonzero?
        error_emitter.error( "missing required attribute#{'s' if a.size != 1}: " <<
          "#{oxford_comma(a.map { |o| "#{pre o.first}" }, ' and ')}")
      else
        true
      end
    end
  end
end
