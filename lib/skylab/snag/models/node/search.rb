module Skylab::Snag
  class Models::Node::Search
    include Snag::Core::SubClient::InstanceMethods


    def self.build request_client, search_param_h
      o = new request_client, search_param_h
      if 0 == o.send( :error_count )
        o
      else
        false
      end
    end


    def adjp
      res = nil
      flip = @index.invert
      names = (0..(@or.length-1)).map { |i| flip[i] }
      a = names.map do |name|
        if respond_to? name
          "#{ name } #{ send name }"
        end
      end
      s = a.compact.join ' or '
      if 0 == s.length
        res = s
      else
        res = "with #{ s }"
      end
      res
    end


    just_digits_rx = %r{ \A  (.* [^\d] )?  (\d+)  ([^\d].*)?  \z }x

    define_method :identifier= do |v|
      res = v
      begin
        if ! v
          unset!( :identifier ) if @index[:identifier]
          @identifier = v
          break
        end
        md = just_digits_rx.match v.to_s
        if ! md
          error "invalid identifier, needs some digit: #{ v.inspect }"
          break
        end
        extra = "#{ md[1] }#{ md[3] }"
        if 0 != extra.length
          info "(ignoring #{ extra.inspect } in search criteria.)"
        end
        @identifier = md[2].to_i
        set! :identifier, -> issue do
          b = false
          if issue.valid?         # (necessary so we can list invalid issues)
            if issue.integer == @identifier
              b = true
            end
          end
          b
        end
      end while nil
      v
    end


    def match? issue
      if @or.empty?
        set! :and, -> i { true }
      end
      b = @or.detect { |node| node[ issue ] }
      if @counter and b
        if (@counter += 1) >= @last
          throw(:last_item, issue)
        end
      end
      b
    end


    positive_integer_rx = %r{\A\d+\z}

    define_method :last= do |num_s|
      res = num_s
      begin
        if ! num_s
          @last = @counter = nil
          break
        end
        if positive_integer_rx !~ num_s
          error "must look like integer: #{ num_s }"
          break
        end
        @counter = 0
        @last = num_s.to_i
      end
      res
    end

  protected

    param_struct = ::Struct.new :identifier, :last

    define_method :initialize do |emitter, param_h|
      _issue_sub_client_init! emitter
      @counter = nil
      @index = { }
      @or = [ ]
      o = param_struct.new
      param_h.each { |k, v| o[k] = v } # validates names
      o[:identifier] and self.identifier = o.identifier
      o[:last] and self.last = o[:last]
    end

    def set! name, test
      if ! @index[name]
        idx = @or.length
        @or[idx] = test
        @index[name] = idx
      end
      nil
    end
  end
end
