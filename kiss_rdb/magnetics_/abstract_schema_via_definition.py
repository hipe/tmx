from dataclasses import dataclass as _dataclass


# == Whole Schema

def abstract_schema_via_abstract_tables(tables):
    dct = {}
    for t in tables:
        k = t.table_name
        if k in dct:
            xx(f"collision: multiple tables with the name {k!r}")
        dct[k] = t
    return _AbstractSchema(dct)


class _AbstractSchema:
    def __init__(self, dct):
        self._TABLES = dct

    def to_tables(self):
        return self._TABLES.values()


# == Table

def abstract_table_via_name_and_abstract_columns(name, cols, listener):
    pkfn, fks, dct = None, [], {}
    for col in cols:
        k = col.column_name
        if k in dct:
            xx(f"collision: multiple columns with the name {k!r}")
        if col.is_primary_key:
            if pkfn is not None:
                xx(f"Can't have >1 PK ({pkfn!r} then {k!r})")
            pkfn = k
        if col.is_foreign_key_reference:
            fks.append(k)
        dct[k] = col

    return _AbstractTable(name, pkfn, dct, fks)


class _AbstractTable:

    def __init__(self, name, pkfn, dct, fks):
        self.table_name = name
        self._primary_key_field_name = pkfn
        self._DICT = dct
        self._FOREIGN_KEYS = tuple(fks) if fks else None

    def to_columns(self):
        return self._DICT.values()


# == Column

def abstract_column_via(
        column_name, column_type_storage_class, listener=None, **kw):

    if column_type_storage_class not in _abstract_types:
        xx(f"keeping this painfully minimal for now. bad type: {column_type_storage_class!r}")   # noqa: E501
    return _AbstractColumn(column_name, column_type_storage_class, **kw)


@_dataclass
class _AbstractColumn:
    column_name: str
    column_type_storage_class: str
    null_is_OK: bool = True
    is_foreign_key_reference: bool = False
    is_primary_key: bool = False
    referenced_table_name: str = None


_abstract_types = {k: None for k in 'INTEGER TEXT'.split()}


def xx(msg=None):
    raise RuntimeError(''.join(('cover me', *((': ', msg) if msg else ()))))

# #born
