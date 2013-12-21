module Skylab::Face

  class Metastory  # [#035]

    def self.enhance k, m, t
      me = self
      k.class_exec do
        const_defined? :Metastory__, false and fail "already class - #{ k }"
        const_defined? :Metastory_, false and fail "already metastory - #{ k }"
        const_set :Metastory_, ( const_set :Metastory__, me.new( m, t ) ).
          new( nil )  # for metastories in libville, they have no subject!
        class << self
          undef_method :metastory
          define_method :metastory do
            if const_defined? :Metastory_, false
              const_get :Metastory_, false
            else
              const_set :Metastory_, self::Metastory__.new( self )  # money
            end
          end
        end
      end
      nil
    end

    class << self
      alias_method :orig_new, :new
    end

    def self.new m, t
      ::Class.new( self ).class_exec do
        const_set :MODALITY_EXPONENT, m
        const_set :TRIFORCE_EXPONENT, t
        set_derived_constants
        class << self
          alias_method :new, :orig_new
          undef_method :enhance
          undef_method :orig_new
        end
        self
      end
    end

    -> do
      h = {
        Modality_Client_: [ true,  false ].freeze,
        Namespace_:       [ false, false ].freeze,
        Action_:          [ false, true  ].freeze
      }.freeze
      define_singleton_method :set_derived_constants do
        is_anchor, is_leaf = h.fetch self::TRIFORCE_EXPONENT
        const_set :IS_ANCHOR, is_anchor
        const_set :IS_BRANCH, ! is_leaf
        const_set :IS_LEAF, is_leaf
        const_set :AGGREGATE_EXPONENT,
          :"#{ self::MODALITY_EXPONENT }#{ self::TRIFORCE_EXPONENT }"
        nil
      end
    end.call

    def self.create_const_accessors_for *i_a
      i_a.each do |i|
        define_method i.downcase do  # woah
          self.class.const_get i  # note it is not strict
        end
      end
      nil
    end

    create_const_accessors_for(
      :MODALITY_EXPONENT, :TRIFORCE_EXPONENT, :AGGREGATE_EXPONENT,
      :IS_ANCHOR, :IS_BRANCH, :IS_LEAF )

    def initialize subject
      @metastory_subject = subject
    end
  end
end
