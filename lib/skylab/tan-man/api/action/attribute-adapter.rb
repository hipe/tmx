module Skylab::TanMan

  module API::Action::Attribute_Adapter

    def self.to_proc ; BUNDLE_P__ end

    BUNDLE_P__ = -> a do

      extend MetaHell::Formal::Attribute::Definer::Methods
        # class can now say `attribute` and `meta_attribute`
      include IM__

      meta_attribute( * META_ATTRIBUTE_A__ )
      attribute_metadata_class do
        def label_string
          local_normal_name.to_s
        end
      end
      p = Attr_parser__[ self, a ]
      nil while a.length.nonzero? && p[]
    end

    META_ATTRIBUTE_A__ = Core::MetaAttributes[ :boolean, :default,
      :mutex_boolean_set, :pathname, :required, :regex ]
    -> do
      h = -> *a { ::Hash[ a.map { |i| [ i , true ] } ].freeze }
      MONADIC_H__ = h[ :boolean, :pathname, :required ]
      DIADIC_H__ = h[ :default, :mutex_boolean_set ]
    end.call
    Attr_parser__ = -> cls, a do
      cls.class_eval do
        -> do  # assume nonzero length
          h = { }
          h[ a.shift ] = true while MONADIC_H__[ a[ 0 ] ]
          if :attribute == a[ 0 ]
            a.shift ; attr_name_i = a.shift
            h[ a.shift ] = a.shift while DIADIC_H__[ a[ 0 ] ]
            attribute attr_name_i, h
            true
          elsif h.length.nonzero?
            raise ::ArgumentError, "expected `attribute` at '#{ a[ 0 ] }' #{
              }after #{ h.keys * ', ' }"
          end
        end
      end
    end
  end

  module API::Action::Attribute_Adapter::IM__

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
