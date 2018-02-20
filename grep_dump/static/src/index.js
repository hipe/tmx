import _ from 'lodash';

function component() {
  var element = document.createElement('div');

  element.innerHTML = _.join(['foo3', 'bar'], ' ');

  return element;
}

document.body.appendChild(component());
