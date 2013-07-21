module Skylab::TanMan

  class Models::Meaning < ::Struct.new :name, :value # KEEP LIFE EASY
                                               # let's always use only strings

    include Core::SubClient::InstanceMethods


    def collapse request_client                # we are not a flyweight, hack
      @request_client and fail 'sanity'
      _tan_man_sub_client_init request_client
      self
    end

    match_line_rx = /\A[ \t]*[-a-z]+[ \t]*:/

    valid_name_rx = /\A[a-z][-a-z0-9]*\z/

    def duplicate_spacing! o                   # meh
      o_x = o.line_start
      its_width_to_colon = o.colon_pos - o_x
      its_e2_width = o.colon_pos - (o.name_index.end + 1)
      its_e0 = o.whole_string[ o_x .. o.name_index.begin - 1 ]
      its_e0.gsub!( /[ \t]+\z/, '' )
      @e0 = "#{ its_e0 }#{
        ' ' * [ 0,
      (its_width_to_colon - its_e2_width - name.length - its_e0.length)
               ].max
      }"
      @e2 = ' ' * its_e2_width
      @e4 = ' ' * ( o.value_index.begin - 1 - o.colon_pos )
      nil
    end

    def line
      "#{ @e0 }#{ name }#{ @e2 }:#{ @e4 }#{ value }\n"
    end

                                  # result is true or false per if the meaning
                                  # is valid or invalid respectively. `error` is
                                  # called one or more times iff invalid. `info`
                                  # is called one or more times iff the value(s)
                                  # are changed per normalization. `error` and`
                                  # `info` receive strings for now, maybe events
                                  # in the future.
    nl_rx = /[\r\n]/

    define_method :normalize! do |error, info|
      res = false
      begin
        if valid_name_rx !~ name
          error[ "invalid meaning name #{ ick name } - meaning names #{
            }must start with a-z followed by [-a-z0-9]" ]
          break
        end
        if nl_rx =~ value
          error[ "value cannot contain newlines." ]
          break
        end
        use = value.strip
        x = value.length - use.length
        if x > 0
          info[ "trimming #{ x } char#{ s x } #{
            }of whitespace from value" ]
          self[:value] = use
        end
        res = true
      end while nil
      res
    end

    attr_reader :symbol           # exp - doesn't always feel right using only
                                  # strings, despite what i may have said above

    o = { }
    o[:match_line_rx] = match_line_rx
    o[:valid_name_rx] = valid_name_rx
    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  private

    def initialize request_client, name, value
      _tan_man_sub_client_init request_client
      self[:name] = name
      @symbol = name.intern
      self[:value] = value
      @e0 = @e2 = @e4 = nil
    end
  end
end
