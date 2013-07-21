module Skylab::TanMan

  module API::Action::Attribute_Adapter

    def self.extended klass

      # this apparently has to happen on the parent class or the class
      # and can't simply be mixed in via plain old m.m and i.m modules

      klass.extend MetaHell::Formal::Attribute::Definer::Methods # so it can say
                                       # `attribute` and `meta_attribute`

      klass.send :include, API::Action::Attribute_Adapter::InstanceMethods


      # where as we used to do it "in one place" on the action base
      # class we now do the below as a hook for each child that extends
      # the legacy adapter.  ich muss sein!

      klass.meta_attribute(* Core::MetaAttributes[ :boolean, :default,
                         :mutex_boolean_set, :pathname, :required, :regex ] )

      klass.attribute_metadata_class do        # (just playing w/ the feature)
        def label_string
          local_normal_name.to_s
        end
      end
    end
  end

  module API::Action::Attribute_Adapter::InstanceMethods

    include Core::Attribute::Reflection::InstanceMethods

    # the below used to be a combination of update_attributes!, `valid?`,
    # is now is more atomic.
    # this is a legacy adapter method implementation of the newer
    # one in Parameter::Controller::I_M

  public

    def set! param_h
      result = nil
      begin
        if param_h
          r = update_attributes! param_h
          if ! r
            result = r
            break
          end
        end
        set_defaults_if_nil!
        if invalid_reasons_count.zero?   # this block used to be `valid?` impl
          if required_ok? # ack hook into meta attributes -- awful
            result = true
          end
        end
      end while nil
      result
    end

  private

    class_exec :invalid_reasons, & MetaHell::FUN.private_attr_reader
    alias_method :invalid_reasons_ivar, :invalid_reasons

    def invalid_reasons
      @invalid_reasons ||= [ ]
    end

    def invalid_reasons_count
      invalid_reasons_ivar ? invalid_reasons.length : 0
    end

    def update_attributes! param_h            # "atomic"
      all_keys = attribute_definer.attributes.names
      good, bad = param_h.reduce( [[],[]] ) do |m, (k,v)|
        if all_keys.include? k
          m.first.push [ "#{ k }=", v ]
        else
          m.last.push k
        end
        m
      end
      result = nil
      begin
        if bad.length.nonzero?
          error "#{ s bad, :this} #{ s :is } #{ s :a }invalid action #{
            }parameter#{ s }: (#{ bad.join ', ' })"
          result = false
          break
        end
        i = invalid_reasons_count
        good.each do |m, v|
          send m, v
        end
        if i < invalid_reasons_count
          result = false
          break
        end
        result = true
      end while nil
      result
    end
  end
end
