import React from 'react';
var createReactClass = require('create-react-class');
import SelectDropDown from './select_dropdown.js';
import { Dates } from '../services/dates.js';
import { FetchTopReferrersOnDate, FetchTopReferrersOnDateApi } from '../services/top_referrers.js';
import ApiInfoPanel from './api_info_panel.js'
import { Table } from 'react-bootstrap';
import _ from 'underscore';

var TopReferrersByDate = createReactClass({
  getInitialState: function(){
    return { values: [{value: 'loading', label: 'Loading..'}], visits: [] }
  },
  change: function(event){
    var that = this;
    let selectedDate = event.target.value;
    FetchTopReferrersOnDate(selectedDate).then(function(response){
      that.setState({ visits: response, api_url: FetchTopReferrersOnDateApi(selectedDate) });
    })
  },
  componentDidMount: function(){
    var that = this;
    Dates().then(function(response){
      that.setState({ values: _.map(response, (item,i) => { return {value: item.date, label: item.date}}) });
    });
  },
  render(){
    let dates  = Object.keys(this.state.visits);
    let visits = this.state.visits;
    let rows = _.map(this.state.visits, function(urls, date){
      return _.map(urls, function(url, index){
        let referrerRows = _.map(url.referrers, function(ref, index){ return <li key={index}>{ref.url} ({ref.visits})</li> });
        return <tr key={index}>
                 <td>{date}</td>
                 <td>{url.url}</td>
                 <td>{url.visits}</td>
                 <td>
                   <ul>
                     {referrerRows}
                   </ul>
                 </td>
               </tr>
      });
    });
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
              <th>Visits</th>
              <th>Referrers (visits)</th>
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

export default TopReferrersByDate;
