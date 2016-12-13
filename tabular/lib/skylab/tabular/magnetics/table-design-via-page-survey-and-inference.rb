module Skylab::Tabular

  class Magnetics::TableDesign_via_PageSurvey_and_Inference  # 1x

    # this is perhaps *the* essential magnetic of table inference.
    # it is exactly the implementation of the pseudocode algorithm
    # outlined at [#004.A].

    # the main thing here is is that whereas in the past we start with
    # a table design (written "by hand") and then feed mixed tuples
    # in to it to make a table, here we first survey the tuples, then
    # generate a design from them.

    # the last section of this file is a snippet of ANCIENT code that
    # is interesting and obliquely relevant.

    class << self
      def call is_first_page, is_last_page, ps, inf
        new( is_first_page, is_last_page, ps, inf ).execute
      end
      alias_method :[], :call
      private :new
    end  # >>

    # -
      def initialize is_first, is_last, ps, inf
        @inference = inf
        @is_first_page = is_first
        @is_last_page = is_last
        @page_surveyish = ps
      end

      def execute

        # our numeric visualizations are expressed through summary fields
        # (and this is the only way that summary fields are ever employed
        # by our generated table designs); so summary fields are employed
        # IFF one or more columns in the page was classified as numeric.
        # note that this is a function of the input data, so it's possible
        # that there are no numeric columns.

        mutable_design = MutableDesign___.new @page_surveyish, @inference

        scn = @page_surveyish.field_survey_writer.to_field_survey_scanner

        begin

          _field_survey = scn.gets_one

          DesignedFields_via_FieldSurvey___.call(
            mutable_design,
            _field_survey,
            @inference,
          )
        end until scn.no_unparsed_exists

        mutable_design.flush_to_table_design
      end
    # -

    # ==

    DesignedFields_via_FieldSurvey___ = -> (
      mutable_design, fs, inference  # field survey
    ) do

      # typically (always, probably) one field survey yields either one
      # or two "designed fields" - one to express the mixed value, and
      # maybe another to be the max share meter.
      #
      # for now, we write these designed fields as intermediate internal
      # structures that will ultimately turn into calls to the `add_field`
      # method in a table design. be prepared to flip on this, where the
      # subject writes to the design DSL directly.

      # -

        _number_of_numerics = fs.calculate_number_of_numerics
        _actual_ratio = _number_of_numerics.to_f / fs.number_of_cels

        if inference.threshold_for_whether_a_column_is_numeric <= _actual_ratio
          mutable_design.add_field_pair_corresponding_to_numeric_input_field
        else
          mutable_design.add_field_corresponding_to_non_numeric_input_field
        end
        NIL
      # -
    end

    # ==

    class MutableDesign___

      # we are contemplating making this write to the table design DSL
      # within its define time

      def initialize ps, inference

        @_add_field = :__add_first_field

        @inference = inference
        @page_surveyish = ps
      end

      def add_field_pair_corresponding_to_numeric_input_field

        _add_field :field_corresponding_to_input
        _add_field :max_share_visualization_of_previous_input_field
        NIL
      end

      def add_field_corresponding_to_non_numeric_input_field

        _add_field :field_corresponding_to_input
        NIL
      end

      def _add_field * defn_sym_a
        send @_add_field, defn_sym_a
      end

      def __add_first_field defn_sym_a
        @_input_offset_incrementor = Incrementor__.new 0
        @_mutable_will_add_fields = []
        @_add_field = :__add_field_during_edit
        send @_add_field, defn_sym_a
      end

      def __add_field_during_edit defn_sym_a
        _fld = WillAddField___.new defn_sym_a, @_input_offset_incrementor
        @_mutable_will_add_fields.push _fld
        NIL
      end

      def flush_to_table_design

        __close

        design = @inference.define_table_design__ do |defn|

          @_table_design_in_progress = defn

          @_will_add_fields.each_with_index do |fld, d|
            @_current_field_offset = d
            send fld.method_name
          end

          remove_instance_variable :@_current_field_offset
          remove_instance_variable :@_table_design_in_progress
          remove_instance_variable :@_will_add_fields

          defn.target_final_width @inference.target_final_width
        end

        sf_idx = design.summary_fields_index

        if sf_idx
          sf_idx.mutate_page_data @page_surveyish, SimplifiedInvocation___[ design ]
        end

        design
      end

      def __close
        remove_instance_variable :@_add_field
        remove_instance_variable :@_input_offset_incrementor
        @_will_add_fields =
          remove_instance_variable( :@_mutable_will_add_fields ).freeze
        NIL
      end

      def __add_field_for_max_share_visualiztion_of_previous_field

        _prev_field = @_will_add_fields.fetch @_current_field_offset - 1

        d = _prev_field.input_offset  # d = input offset of referrant field

        att = Zerk_::CLI::HorizontalMeter::AddToTable.begin(
          @_table_design_in_progress )

        att.meter_prototype @inference.max_share_meter_prototype__

        att.for_input_at_offset d

        _fs = @page_surveyish.field_survey_writer.dereference d

        _denom = _fs.minmax_max  # there's a lot that could be said here

        att.add_field_using_denominator_by do
          # ("column based resources" are available to you if you want them)
          _denom
        end

        NIL
      end

      def __add_field_corresponding_to_input
        @_table_design_in_progress.add_field  # same for numeric or non-numeric
        NIL
      end
    end

    # ==

    SimplifiedInvocation___ = ::Struct.new :design  # we don't need to read observers here

    # ==

    class WillAddField___

      def initialize defn_sym_a, counter
        @_input_offset_incrementor = counter
        @_did = false
        @_mutex = nil
        defn_sym_a.each do |sym|
          send OP___.fetch sym
        end
        remove_instance_variable( :@_did ) || fail
        remove_instance_variable :@_input_offset_incrementor
        freeze
      end

      OP___ = {
        field_corresponding_to_input: :__parse_field_corresponding_to_input,
        max_share_visualization_of_previous_input_field:
          :__parse_max_share_visualization_of_previous_input_field,
      }

      def __parse_max_share_visualization_of_previous_input_field
        _mutex
        @method_name = :__add_field_for_max_share_visualiztion_of_previous_field
        NIL
      end

      def __parse_field_corresponding_to_input
        _mutex
        @_input_offset_incrementor.increment
        _offset = @_input_offset_incrementor.read
        @__input_offset_knownness = Common_::Known_Known[ _offset ]
        @method_name = :__add_field_corresponding_to_input
        NIL
      end

      def _mutex
        remove_instance_variable :@_mutex
        @_did = true ; nil
      end

      # -- read

      def input_offset
        @__input_offset_knownness.value_x
      end

      attr_reader(
        :method_name,
      )
    end

    # ==

    class Incrementor__

      def initialize d
        @__initial_value = d
        @_read = :__CANNOT_READ_WHEN_HAS_NOT_BEEN_INCREMENTED_ONCE
        @_increment = :__first_increment
      end

      def increment
        send @_increment
      end

      def __first_increment
        @_integer = remove_instance_variable :@__initial_value
        @_read = :__read_normally
        @_increment = :__subsequent_increment
        NIL
      end

      def __subsequent_increment
        @_integer += 1 ; nil
      end

      def read
        send @_read
      end

      def __read_normally
        @_integer
      end
    end

    # ==

    # (keep while #open [#003]:)
#==BEGIN interesting
      if false
      def entity_metrics sin
        json_str = sin.read
        structo = JSON.parse json_str
        metrics = EntityMetrics.new
        structo.each do |row|
          row.each do |(field,value)|
            metrics[field].eat value
          end
        end
        metrics
      end

      def protomodel_from_metrics metrics, entity_name
        model = Proto::Model.new
        new_prototable_from_entity_metrics(
          model, metrics, entity_name)
        model
      end

    private

      def s; Sexpesque; end

      class FieldMetrics
        attr_reader :name, :type_guess, :many
        alias_method :many?, :many
        def initialize name
          @name = name
          @counts = nil
          @many = false
          @type_guess = nil
        end

        def counts
          @counts ||= Hash.new{|h,k| h[k] = 0}
        end

        def eat value
          if value.kind_of?(Hash)
            @many = true
            value.each do |(k,v)|
              many_guy[k].eat v
            end
          elsif value.kind_of?(Array)
            @many = true
            value.each do |v|
              eat v
            end
          else
            counts[value] += 1
            deal_with_type value
          end
        end

        def field_summary
          resp = s[:field_summary]
          if counts.any?
            resp.push s[:nonblank_sample_size, nonblank_sample_size]
            resp.push s[:percent_nonblank, "%%%02.2f" % [percent_nonblank]]
            resp.push s[:width,
              "%d distinct nonblank values" % [num_distinct_nonblank_values] ]
            resp.push s[:height_factor,
              ( "%%%02.2f of nonblank values are of values that repeat" %
              [height_factor] )
            ]
            resp.push s[:num_distinct_repeated_nonblank_values,
              num_distinct_repeated_nonblank_values
            ]
            resp.push s[:type_guess, type_guess.to_sym]
            resp.push s[:most_popular_values, most_popular_summary_lines]
          elsif ! many?
            resp.push s[:nonblank_sample_size, 0]
          end
          if many?
            resp.push s[:child, many_guy.entity_summary]
          end
          resp
        end
        # what percent of nonblank values are values that repeat?
        def height_factor
          tots = 0
          these = 0
          counts.each do |(value, count)|
            next if Blank =~ value
            tots += count
            these += count if count > 1
          end
          resp = (tots == 0) ? :Nan : (these.to_f / tots.to_f * 100)
          resp
        end
        def many_guy
          @many_guy ||= begin
            EntityMetrics.new
          end
        end
      private
        def s; Sexpesque; end
        Blank = /\A[[:space:]]*\Z/
        def blanks_exist?
          counts.keys.any?{|value| Blank =~ value}
        end
        def percent_nonblank
          tots = 0
          nonblanks = 0
          counts.each do |(value, count)|
            tots += count
            nonblanks += count if Blank !~ value
          end
          resp = (tots == 0) ? :Nan : (nonblanks.to_f/tots.to_f * 100)
          resp
        end
        def nonblank_sample_size
          count = 0
          counts.each do |(value, count2)|
            next if Blank =~ value
            count += count2
          end
          count
        end
        AGobletOfData = 300
        DefaultTruncateAmt = 70
        MaxTopRows = 3
        def truncate(str,len=DefaultTruncateAmt)
          if str.length <= len
            str
          else
            '..' + str[-1 * len .. -1]
            # str[0..len-3] + '..'
          end
        end
        def num_distinct_nonblank_values
          counts.keys.count{|value| Blank !~ value}
        end
        def num_distinct_repeated_nonblank_values
          counts.map.count{|(v,c)| Blank !~ v && c > 1 }
        end
        def repeat_pairs
          counts.select do |(_value, count)|
            count > 1
          end
        end
        def nonblank_repeat_pairs
          repeat_pairs.reject do |(value, _count)|
            Blank =~ value
          end
        end
        def most_popular_summary_lines
          sorted = counts.sort{|a,b| b[1] <=> a[1]}
          top_lines = []
          num_rows = 0
          tot_str_len = 0
          sorted.each do |(value, count)|
            str = truncate(value)
            tot_str_len += str.length
            break if tot_str_len > AGobletOfData
            top_lines.push sprintf("%s times => '%s'",count,str)
            num_rows += 1
            break if num_rows >= MaxTopRows
          end
          top_lines
        end
        def max_repeat
          counts.values.max
        end
        def deal_with_type value
          type = Proto::Type.of_string(value)
          if type == Proto::Type::Empty
            # for now we just ignore all these
          elsif @type_guess.nil?
            if Proto::Type::Empty != type
              @type_guess = type
            end
          else
            if type.can_be_represented_with?(@type_guess)
              # type guess covers the type
            elsif @type_guess.can_be_represented_with?(type)
              @type_guess = type
            else
              raise AppFail.new('pefectly reasonable logic fail')
            end
          end
        end
      end

      class EntityMetrics
        attr_reader :order
        def initialize
          @hash = Hash.new{|h,k| h[k] = FieldMetrics.new(k) }
          @order = []
        end

        def [](field)
          @order.push(field) unless @hash.has_key?(field)
          @hash[field]
        end

        def entity_summary
          s[:fields_summary, * @order.map{ |field|
            s[field.intern, @hash[field].field_summary]
          }]
        end

        def each_field
          @hash.each do |(field, metrics)|
            yield([field,metrics])
          end
        end
      private
        def s; Sexpesque end
      end
      end  # if false
#==END interesing
  end
end
# #tombstone: begin to overwrite ancient [as] node (first half)
