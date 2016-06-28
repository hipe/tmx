module Skylab::DocTest

  class Models_::DescriptionString

    # a bit like a [#025] "common paraphernalia model"
    #
    # but this is modeled as an ornate session in which
    # particular methods must be called in a particular order :/

    class << self

      alias_method :via_discussion_run__, :new
      undef_method :new
    end  # >>

    def initialize dr, cx
      @_choices = cx
      @_description_run = dr
    end

    def use_last_nonblank_line!
      _use_any_such_line :any_last_nonblank_line_object__
    end

    def use_first_nonblank_line!
      _use_any_such_line :any_first_nonblank_line_object__
    end

    def _use_any_such_line m
      lo = remove_instance_variable( :@_description_run ).send m
      if lo
        @_mutable_string = lo.get_content_string
        @found = true
      else
        @found = false
      end
      NIL_
    end

    def remove_any_trailing_colons_or_commas!
      @_mutable_string.sub! TRAILING_RX___, EMPTY_S_ ; nil
    end

    TRAILING_RX___ = /[:,]?\z/

    def remove_any_leading_so_and_or_then!
      @_mutable_string.sub! SO_THEN_RX___, EMPTY_S_ ; nil
    end

    SO_THEN_RX___ = /\A(?:so|then),? /i

    def remove_any_leading_it!
      @_mutable_string.sub! IT_RX___, EMPTY_S_ ; nil
    end

    IT_RX___ = /\Ait /i

    def uncontract_any_leading_its!
      @_mutable_string.sub! ITS_RX___, "is " ; nil
    end

    ITS_RX___ = /\Ait's /i

    def escape_as_platform_string!

      @_mutable_string = @_mutable_string.inspect ; nil  # EEK
    end

    def convert_to_snake_case!

      # it is perhaps a bug that this doesn't work (#open [#co-048])?
      # Common_::Name.via_human( @_mutable_string ).as_lowercase_with_underscores_string

      @_mutable_string =
        Common_::Name::Conversion_Functions::Snake_case_string_via_human[
          @_mutable_string ]
      NIL_
    end

    def is_blank
      BLANK_RX_ =~ @_mutable_string
    end

    def get_current_string
      @_mutable_string.dup
    end

    def finish
      remove_instance_variable :@_mutable_string
    end

    attr_reader(
      :found,
    )
  end
end
