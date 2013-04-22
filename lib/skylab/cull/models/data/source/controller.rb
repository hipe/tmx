module Skylab::Cull

  class Models::Data::Source::Controller

    Models::Field::Box.of self, Models::Data::Source.field_box

    def if_init_valid name, url, tag_a, yes_object, no_event
      @name = name.dup.freeze
      @url = url.dup.freeze
      @tag_a = ( tag_a.dup.freeze if tag_a )
      _if_init_valid yes_object, no_event
    end

    attr_reader :name, :url

    def tags
      if @tag_a
        @tag_a * ', '  # kiss
      end
    end

    # --*--
    #
    #         ~ possibly abstractable, in story order ~

    Missing = Models::Event.new do |miss_o_a|
      "missing required field(s) - #{ miss_o_a.map(& :name) * ', ' }"
    end

    def _if_init_valid yes_object, no_event
      miss_a = required_fields.reduce [] do |m, fld|
        v = instance_variable_get fld.as_ivar
        if v.nil?
          m << fld
        end
        m
      end
      if miss_a.length.nonzero?
        no_event[ Missing[ miss_o_a: miss_a ] ]
      else
        _if_valid_fields yes_object, no_event
      end
    end
    protected :_if_init_valid

    def _if_valid_fields yes_object, no_event
      res = nil
      begin
        if @tag_a && @tag_a.length.nonzero?
          ok, res = _validate_tags yes_object, no_event
          ok or break
        end
        res = yes_object[ self ]
      end while nil
      res
    end

    InvalidTag = Models::Event.new do |a|
      "tag(s) contain invalid characters, must be lowercase #{
        }alphanumeric for now (had #{ a.map { |x| "\"#{ x }\"" } * ', ' })"
    end

    -> do  # `_validate_tags`

      white_rx = /\A[-_a-z0-9]+\z/

      define_method :_validate_tags do |y, n|  # pair
        bad_a = @tag_a.reduce [] do |m, x|
          m << x if white_rx !~ x
          m
        end
        if bad_a.length.zero?
          y[ self ]
        else
          n[ InvalidTag[ a: bad_a ] ]
        end
      end
    end.call

    def body_h
      a = body_fields_bound.reduce [] do |m, b|
        v = b.value
        if ! v.nil?
          m << [ b.field.name, v ]
        end
        m
      end
      ::Hash[ a ]
    end

    def initialize _
    end
  end
end
