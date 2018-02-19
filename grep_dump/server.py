# NOTE - #todo - nowhere is it reflected that we used `pip install` to get:
#
#     Flask            0.12.2
#     Flask-WTF        0.14.2
#     requests         2.18.4
#     WTForms          2.1


from flask import (
        Flask,
        flash,
        redirect,
        render_template,
        url_for,
)


import forms

# -- BEGIN this is a thing to move to a separate file one day maybe

class Config:
    SECRET_KEY = 'one_day_make_this_more_secure'  # #todo
    """the secret key is supposed to be secret, as the strength of the
    tokens and signatures generated with it depends on no person outside
    of the trusted maintainers of the application knowing it
    """

    pass

# -- END

app = Flask('grep_dump',
        root_path = 'grep_dump',
        )

app.config.from_object(Config)




@app.route('/search', methods=['GET', 'POST'])
def search():
    form = forms.SearchForm()
    if form.validate_on_submit():
        _big_s = repr(form.data)
        flash('Search requested: {}'.format(_big_s))
        return redirect(url_for('index'))
    else:
        return render_template('search.html', title='Search Time', form=form)




@app.route('/index')
@app.route('/')
def index():
    return render_template('index.html')




if __name__ == '__main__':
    app.run(debug=True)

# #born.
