import React from 'react';
var createReactClass = require('create-react-class');
import SelectDropDown from './select_dropdown.js';
import { DatesRange } from '../services/dates.js';
import { FetchTopUrlsOnDateRange, FetchTopUrlsOnDateRangeApi } from '../services/top_urls.js';
import ApiInfoPanel from './api_info_panel.js'
import { Table } from 'react-bootstrap';
import _ from 'underscore';

var TopUrlsByDateRange = createReactClass({
  getInitialState: function(){
    return { values: [{value: 'loading', label: 'Loading..'}], visits: [] }
  },
  change: function(event){
    var that = this;
    let start_date, end_date;
    [start_date, end_date] = event.target.value.split('|');
    FetchTopUrlsOnDateRange(start_date, end_date).then(function(response){
      that.setState({ visits: response, api_url: FetchTopUrlsOnDateRangeApi(start_date, end_date) });
    })
  },
  componentDidMount: function(){
    var that = this;
    DatesRange().then(function(response){
      that.setState({ values: _.map(response, (item,i) => { return {value: item.start_date + "|" + item.end_date, label: `${item.display_num_of_days} (${item.start_date} to ${item.end_date})`}}) });
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
       <p className="lead">Select between date range</p>
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

export default TopUrlsByDateRange;
