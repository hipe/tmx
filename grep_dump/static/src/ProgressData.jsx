import { Button, Grid, Row, Col } from 'react-bootstrap';

import React from 'react';

var axios = require('axios');  // ?


export default class ProgressData extends React.Component {

  constructor(props) {
    super(props);
    this.state = {greeting: 'Hello ' + this.props.name};

    // ("this binding is necessary to make `this` work in the callback")
    this.getPythonXxx = this.getPythonXxx.bind(this);
  }

  personalizeGreeting(greeting) {
    this.setState({greeting: greeting + ' ' + this.props.name + '!'});
  }

  getPythonXxx() {
    axios.get('reindex-dump-job-progress', {
      params: {
        'thing_one': 'value one',
      }
    }).then( (resp) => {
      if ( 200 == resp.status ) {
        console.log("got response: "+resp.data.one_zing);
        this.personalizeGreeting(resp.data.one_zing);
      } else {
        console.log('nope: ' + resp.statusText);
      }
    }).catch( (err) => {
      console.log(err);
    });
  }

  render() {
    return (
      <Grid>
        <Row>
          <Col md={7} mdOffset={5}>
            <h1>{this.state.greeting}</h1>
            <hr/>
          </Col>
        </Row>
        <Row>
          <Col md={7} mdOffset={5}>
            <Button bsSize='large' bsStyle='danger' onClick={this.getPythonXxx}>
              Say Hello!
            </Button>
          </Col>
        </Row>
      </Grid>
    );
  }
}

// #born.
