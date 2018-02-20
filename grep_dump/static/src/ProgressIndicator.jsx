import ProgressData from './ProgressData';
import { PageHeader } from 'react-bootstrap';
import React from 'react';

export default class ProgressIndicator extends React.Component {
  render() {
    return (
      <PageHeader>
        <div className='header-contents'>
          <ProgressData name='Rimini' />
        </div>
      </PageHeader>
    );
  }
}

// #born.
