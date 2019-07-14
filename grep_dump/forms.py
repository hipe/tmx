from flask_wtf import FlaskForm
from wtforms import (
        BooleanField,
        FileField,
        # PasswordField,
        # SelectField,
        SelectMultipleField,
        StringField,
        SubmitField,
        )
import wtforms.validators as validators  # ..
from wtforms.validators import DataRequired


class SearchForm(FlaskForm):
    search_string = StringField('Search String', validators=[DataRequired()])
    is_egrep = BooleanField('Search string is egrep regex')
    add_in = SelectMultipleField('In', choices=[
        ['xx', '#kikker'],
        ['yy', '#blubba'],
        ['zz', '#zimoji'],
    ])
    add_from = SelectMultipleField('From', choices=[
        ['mm', '@mejor_mejores'],
        ['ll', '@fingle_fangel'],
        ['qq', '@gneeseesee'],
        ['mm', '@major_majors'],
        ['ll', '@fingle_fangel'],
        ['qq2', '@gneeseesee'],
        ['mm2', '@mejor_mejores'],
        ['ll2', '@fingle_fangel'],
        ['qq3', '@gneeseesee'],
    ])
    since = StringField('Since')
    thru = StringField('Thru')
    has_star = BooleanField('Has Star')
    has_pin = BooleanField('Has Link')
    has_link = BooleanField('Has Pin')
    has_reaction = BooleanField('Has Reaction')
    submit = SubmitField('Search')


class FileUploadForm(FlaskForm):

    validators.regexp  # say hello to this early ..

    def _vali(form, field):
        x = field.data
        if x == '' or x is None:
            field.errors.append(field.gettext('file is required'))

    json_file_path = FileField('JSON File', [_vali])

    submit = SubmitField('Submit')

# #born.
