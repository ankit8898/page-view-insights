import React from 'react';
var createReactClass = require('create-react-class');
import { Panel } from 'react-bootstrap';

var ApiInfoPanel = createReactClass({
  render(){
    return (
      <Panel>
          API Called: <a href={this.props.api_url} target='_blank'>{this.props.api_url}</a>
      </Panel>)
  }
});

export default ApiInfoPanel;
