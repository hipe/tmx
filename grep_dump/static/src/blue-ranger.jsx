var ProgressBar = require('react-progress-bar.js')
var Circle = ProgressBar.Circle;

// import ReactDOM from 'react-dom';
var ReactDOM = require('react-dom');
// var createReactClass = require('create-react-class');
var React = require('react')
// import React from 'react';

console.log('hello');

export default class ThisOneThing extends React.Component {
// var ThisOneThing = createReactClass({

  render() {

    // var o = {};
    // o.progress = 0.75;
    // this.state = o;

    var options = {
      strokeWidth: 2
    };

    // For demo purposes so the container has some dimensions.
    // Otherwise progress bar won't be shown
    var containerStyle = {
      width: '200px',
      height: '200px'
    };

    return (
      <Circle
        // progress={this.state.progress}
        progress={0.75}
        text={'test'}
        options={options}
        initialAnimate={true}
        containerStyle={containerStyle}
        containerClassName={'.progressbar'}
       />
    );
  }
}

ReactDOM.render(<ThisOneThing />, document.getElementById('hidey-ho-neighbor'));

// #born.
