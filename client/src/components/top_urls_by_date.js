import React from 'react';
var createReactClass = require('create-react-class');
import SelectDropDown from './select_dropdown.js';
import { Dates } from '../services/dates.js';
import { FetchTopUrlsOnDate, FetchTopUrlsOnDateApi } from '../services/top_urls.js';
import { Table } from 'react-bootstrap';
import ApiInfoPanel from './api_info_panel.js'
import _ from 'underscore';

var TopUrlsByDate = createReactClass({
  getInitialState: function(){
    return { values: [{value: 'loading', label: 'Loading..'}], visits: []}
  },
  change: function(event){
    var that = this;
    let selectedDate = event.target.value;
    FetchTopUrlsOnDate(selectedDate).then(function(response){
      that.setState({ visits: response, api_url: FetchTopUrlsOnDateApi(selectedDate)});
    })
  },
  componentDidMount: function(){
    var that = this;
    Dates().then(function(response){
      that.setState({ values: _.map(response, (item,i) => { return {value: item.date, label: item.date}}) });
    });
  },
  render(){
    const rows = this.state.visits.map(function(key,i){
       var date         = Object.keys(key);
       var urlAndVisits = _.first(_.flatten(Object.values(key)));
       return <tr key={i} >
                <td>{date}</td>
                <td>{urlAndVisits.url}</td>
                <td>{urlAndVisits.visits}</td>
              </tr>
    })
    return(
      <div>
        <p className="lead">Select a date</p>
        <SelectDropDown items={this.state.values} onChangeHandler={this.change} />
        <ApiInfoPanel api_url={this.state.api_url}></ApiInfoPanel>
        <Table striped>
          <thead>
            <tr>
              <th>Date</th>
              <th>Url</th>
              <th>Visited</th>
            </tr>
          </thead>
          <tbody>
            {rows}
          </tbody>
        </Table>
      </div>
    )
  }
})

export default TopUrlsByDate;
