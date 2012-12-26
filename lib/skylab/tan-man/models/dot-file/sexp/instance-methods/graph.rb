module Skylab::TanMan
  module Models::DotFile::Sexp::InstanceMethods::Graph
    include Models::DotFile::Sexp::InstanceMethod::InstanceMethods


    associate_params = ::Struct.new :attrs, :prototype # might move to edge_stmt

    define_method :associate! do
      |source_ref, target_ref, opt_h=nil, error=nil, success=nil, info=nil|

      res = nil
      begin
        params = associate_params.new
        if opt_h
          opt_h.each { |k, v| params[k] = v } # (validates names)
          opt_h = nil
        end
        source_node = node! source_ref ; source_ref = nil
        target_node = node! target_ref ; target_ref = nil
        source_id = source_node.node_id
        source_id_s = source_id.to_s   # (for lexicals below, leftmost is used)
        target_id = target_node.node_id

        # (#watch [#067] - this lexical algorithm space, might get dried)
        exact_stmt = new_before_this = nil
        _edge_stmts.each do |e|
          if source_id == e.source_node_id && target_id == e.target_node_id
            exact_stmt = e
            break
          elsif ! new_before_this &&
            -1 == ( source_id_s <=> e.source_node_id.to_s )
            new_before_this = e
          end
        end
        if exact_stmt
          res = ! info ? exact_stmt :
            info[ Models::Association::Events::Exists.new self, exact_stmt ]
          break
        end
        edge_stmt = _create_edge_stmt source_node, target_node, params
        stmt_list._insert_before! edge_stmt, new_before_this
        res = ! success ? edge_stmt :
          success[ Models::Association::Events::Created.new self, edge_stmt]
      end while nil
      res
    end

    def _create_edge_stmt source_node, target_node, param
      res = nil
      begin
        proto = nil
        if param.prototype
          proto = _named_prototype param.prototype
          fail "no such prototype #{ param.prototype.inspect }" if ! proto
        else
          proto = _named_prototype :edge_stmt
          proto ||= begin
            @_default_edge_stmt_prototype ||= begin
              prot = self.class.parse :edge_stmt, 'foo -> bar' # [#054]
              prot or fail "sanity - uexpected parse failure parsing edge_stmt"
              prot
            end
          end
        end
        res = proto._create source_node, target_node, param
      end while nil
      res
    end

    def _create_node_with_label label
      proto = stmt_list._named_prototypes[:node_stmt] or fail('no node proto!')
      other = proto._create_node_with_label label
      h = ::Hash[ _node_stmts.map { |n| [n.node_id, true] } ]
      stem = _label2id_stem label
      use_id = stem.intern
      i = 1 # so that the first *numbered* node_id will be foo_2
      use_id = "#{stem}_#{i + 1}".intern while h.key? use_id
      other.node_id! use_id
      other
    end

    def _edge_stmts
      _stmt_enumerator { |stmt| :edge_stmt == stmt.class.rule }
    end

    def _first_label_stmt
      stmt_list.stmts.detect do |s|
        :equals_stmt == s.class.rule && 'label' == s.lhs.normalized_string
      end
    end


    comment_rx = Models::DotFile::Sexp::InstanceMethods::Comment::MATCH_RX

    define_method :comment_nodes do
      ::Enumerator.new do |y|
        space = -> str do
          if comment_rx =~ str
            y << str
          end
        end
        [e0, e4, e6].each(& space)
        if stmt_list
          stmt_list._nodes.each do |node|
            space[ node.e2 ]
            space[ node.tail.stmt_separator ] if node.tail
          end
        end
        [e8, e10].each(& space)
      end
    end

    def get_label
      equals_stmt = _first_label_stmt
      equals_stmt.rhs.normalized_string if equals_stmt
    end

    def _named_prototype name
      stmt_list._named_prototypes[name]
    end

    def node! label
      # Found an exact match node by label? you found your result.
      # Any first node_stmt lexically greater? insert before that. [#067]
      # Any node_stmts at all? insert immediately after last one.
      # Else insert at beginning of all stmts.
      #
      # (The above, if left to its own devices, will ensure that all node stmts
      # get added in alphabetical order with respect to themselves, and come
      # before e.g. all edge stmts #aesthetics)

      after = first = found = follow = followed = nil
      stmt_list._nodes.each do |stmt_list|
        stmt = stmt_list[:stmt]
        first ||= stmt
        if :node_stmt == stmt.class.rule
          case label <=> stmt.label
          when -1 ; after ||= stmt ; follow = false
          when  0 ; found = stmt ; break
          else    ; follow = true
          end
        elsif follow
          followed = stmt
          follow = false
        end
      end
      if found then found else
        after ||= followed || first unless follow # nil ok
        stmt_list._insert_before!(_create_node_with_label(label), after)[:stmt]
      end
    end

    def node_with_id id
      _node_stmts.detect { |n| id == n.node_id }
    end

    def _node_stmts
      _stmt_enumerator { |stmt| :node_stmt == stmt.class.rule }
    end

    def nodes
      _node_stmts.to_a
    end

    def set_label! str
      equals_stmt = _first_label_stmt
      equals_stmt ||= begin
        proto = _named_prototype(:label) or fail('no label proto')
        created = true
        proto.__dupe except: [:rhs]
      end
      equals_stmt.rhs = str
      if created
        stmt_list._insert_before! equals_stmt, _node_stmts.first
      else
        equals_stmt
      end
    end

    def _stmt_enumerator &block
      ::Enumerator.new do |y|
        stmt_list.stmts.each do |stmt|
          block.call(stmt) and y << stmt
        end
      end
    end
  end
end
