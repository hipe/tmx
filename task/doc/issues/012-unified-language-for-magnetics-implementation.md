# unified language for magnetics implementation

people familiar with building grammars and generating parsers from them
will be familiar with how arbitrary (yet important) it is to name the
different levels of structure.




## content

  • token - produced by the tokenizer. for now is equivalent to "word"
    but don't assume this will always hold.

  • word - internally in the tokenizer, this is used to distinguish
    from separator (the separator likely being "-").

  • keyword - a small set of reserved words as determined by this API.
    probably "and", "as", "via" or something near this.

  • term - one or more non-keyword (i.e business) words.

  • item - a "node" in the graph, an "entry" in the directory. terms
    possibly separated by keywords in a syntactically correct way,
    as well as the resource it points to (perhaps not yet loaded).

  • piece - the terms and keywords (in order) that make up an item.
    these pieces can be used to assemble (isomorphically) a name
    approprirate for different modalities (e.g a module name or a
    filesystem entry).
