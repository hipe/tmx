require 'skylab/common'

module Skylab::Tabular

  # here's an example of making a pipeline and then using it:
  #
  #     pipe = Home_::Pipeline.define do |o|
  #       o << :StringifiedTupleStream_via_MixedTupleStream_and_Demo
  #       o << :JustifiedPage_via_StringifiedTupleStream_and_Demo
  #       o << :LineStream_via_JustifiedPage_and_Demo
  #     end
  #
  #     _tu_st = Home_::Common_::Stream.via_nonsparse_array(
  #       [ %w( Food Drink ), %w( donuts coffee ) ] )
  #
  #     st = pipe.call _tu_st
  #
  #     st.gets  # => "|   Food  |   Drink |"
  #     st.gets  # => "| donuts  |  coffee |"
  #     st.gets  # => nil

  class Pipeline

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    def initialize
      @_magnetics = []
      yield self
      @_magnetics.freeze
      freeze
    end

    # --

    def << sym
      @_magnetics.push Home_::Magnetics.const_get( sym, false ) ; nil
    end

    # --

    def call x
      @_magnetics.each do |mag|
        _x_ = mag[ x ]
        x = _x_
      end
      x
    end

    alias_method :[], :call
  end

  # ==

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  # ==

  # (T.O.C: 1. operations  2. magentics  3. models  4. functions)

  # == operations

  module Operations_

    Ping = -> as do  # argument scanner
      if ! as.no_unparsed_exists
        self._COVER_ME
      end
      as.listener.call :info, :expression, :ping do |y|
        y << "hello from tabular!"
      end
      :_ping_from_tabular_
    end

    Autoloader_[ self, :boxxy ]
  end

  # == magnetics

  module Magnetics
    Autoloader_[ self ]

    stowaway(
      :StringifiedTupleStream_via_MixedTupleStream_and_Demo,
      'line-stream-via-justified-page-and-demo',
    )

    stowaway(
      :FieldSurveyor_via_Inference,
      'page-scanner-via-mixed-tuple-stream-and-inference',
    )
  end

  # == models & support

  class SimpleModel_ < Common_::SimpleModel

    define_method :redefine, self::DEFINITION_FOR_THE_METHOD_CALLED_REDEFINE
  end

  module Models
    Autoloader_[ self ]
  end

  module Models_
    # sic
  end

  class Models_::FieldSurveyor < SimpleModel_  # OK to publicize

    attr_writer(
      :field_survey_class,
      :hook_mesh,
    )

    def build_new_survey_for_input_offset _ignored
      @field_survey_class.begin @hook_mesh
    end
  end

  class Models_::TypifiedMixedTuple

    # enforcing a stream interface for reads has advantages elsewhere,
    # outside this lib (e.g headers at [#ze-050.1]).)

    def initialize typi_a
      @_typified_mixed_array = typi_a
    end

    def replace_array_by  # 1x [ze]
      @_typified_mixed_array = yield @_typified_mixed_array
      NIL
    end

    def mutate_array_by  # 1x [ze]
      yield @_typified_mixed_array
      NIL
    end

    def to_typified_mixed_stream
      Stream_[ @_typified_mixed_array ]
    end
  end

  Models::Typified = ::Module.new
  class Models::Typified::Mixed
    # (imagine that the user could inject her own such class..)

    class << self
      alias_method :[], :new
    end  # >>

    def initialize sym, x
      @typeish_symbol = sym
      @value = x
    end

    def is_numeric
      Models::FieldSurvey::IS_NUMERIC.fetch @typeish_symbol
    end

    attr_reader(
      :typeish_symbol,
      :value,
    )
  end

  # == singletons, methods, functions & lib

  Field_surveyor_prototype_ = Lazy_.call do  # 1x

    Models_::FieldSurveyor.define do |o|
      o.field_survey_class = Models::FieldSurvey
    end
  end

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Zerk_lib_ = Lazy_.call do
    _ = Home_.lib_.zerk
    Zerk_ = _
    _
  end

  class << self
    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib___, self )
    end
  end  # >>

  module Lib___

    sidesys = Autoloader_.build_require_sidesystem_proc

    String_scanner = Lazy_.call do
      require 'strscan'
      ::StringScanner
    end

    Basic = sidesys[ :Basic ]
    Zerk = sidesys[ :Zerk ]
  end

  # ==

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  Home_ = self
  NIL = nil  # open [#sli-016.C]
  NOTHING_ = nil
  UNABLE_ = false
  SPACE_ = ' '

  def self.describe_into_under y, _
    y << "a toolkit for table-oriented transformations on streams."
    y << "in practice it's usually used to render ASCII tables"
  end
end
