module Skylab::TanMan

  module Core::MetaAttributes
    extend MetaHell::Boxxy
    singleton_class.send :alias_method, :[], :const_fetch_all
  end

  module Core::MetaAttributes::Boolean extend Porcelain::Attribute::Definer
    meta_attribute :boolean do |name, meta|
      alias_method "#{name}?", name
    end
  end

  module Core::MetaAttributes::Default extend Porcelain::Attribute::Definer
    meta_attribute :default
  end
  module Core::MetaAttributes::Default::InstanceMethods
    def set_defaults_if_nil!      # #pattern [#sl-117]
      attribute_definer.attributes.select { |k, v| v.key?(:default) and send(k).nil? }.each do |k, h|
        (val = h[:default]).respond_to?(:call) and ! h[:proc] and val = val.call
        send("#{k}=", val)
      end
    end
  end

  module Core::MetaAttributes::MutexBooleanSet extend Porcelain::Attribute::Definer
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

  module Core::MetaAttributes::Pathname extend Porcelain::Attribute::Definer
    meta_attribute :pathname do |name, _|
      alias_method(after = "#{name}_after_pathname=", "#{name}=")
      define_method("#{name}=") do |path|
        send(after, path ? ::Skylab::Face::MyPathname.new(path.to_s) : path)
        path
      end
    end
  end

  module Core::MetaAttributes::Proc extend Porcelain::Attribute::Definer
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

  module Core::MetaAttributes::Regex extend Porcelain::Attribute::Definer
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


  # A required attribute is considered as not provided IFF its result is nil.
  # The receiver of this must be a sub-client, and have the attribute_definer.
  #   we will come back to this..
  #
  module Core::MetaAttributes::Required extend Porcelain::Attribute::Definer
    meta_attribute :required
  end

  module Core::MetaAttributes::Required::InstanceMethods
    def required_ok?
      a = attribute_definer.attributes.to_a
      b = a.select { |k, o| o[:required] && send(k).nil? }
      if b.empty?
        true
      else
        error "missing required attribute#{ s b }: #{
          }#{ and_( b.map { |o| "#{ kbd o.first }" } ) }"
        false
      end
    end
  end
end
