import React from 'react';
import ReactDOM from 'react-dom';
import TopUrlsByDate from './components/top_urls_by_date.js';
import TopUrlsByDateRange from './components/top_urls_by_date_range.js';
import TopReferrersByDate from './components/top_referrer_by_date.js';
import TopReferrersByDateRange from './components/top_referrer_by_date_range.js';
import SetUpApi from './config.js'

//SetUpApi config for base url etc
SetUpApi();

ReactDOM.render(<TopUrlsByDate />, document.getElementById('top_urls_by_date'));

ReactDOM.render(<TopUrlsByDateRange />, document.getElementById('top_urls_by_date_range'));

ReactDOM.render(<TopReferrersByDate />, document.getElementById('top_referrers_by_date'));

ReactDOM.render(<TopReferrersByDateRange />, document.getElementById('top_referrers_by_date_range'));
