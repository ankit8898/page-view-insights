import axios from 'axios';

var FetchTopReferrersOnDate = function(date) {
  return axios.get(FetchTopReferrersOnDateApi(date))
  .then(function (response) {
    return response.data
  })
  .catch(function (error) {
    console.log(error);
  });
};

var FetchTopReferrersBetweenDateRange = function(start, end) {
  return axios.get(FetchTopReferrersBetweenDateRangeApi(start, end))
  .then(function (response) {
    return response.data
  })
  .catch(function (error) {
    console.log(error);
  });
};

var FetchTopReferrersOnDateApi = function(date){
  return `${axios.defaults.baseURL}/page_views/top_referrers?date=${date}`
};

var FetchTopReferrersBetweenDateRangeApi = function(start, end) {
  return `${axios.defaults.baseURL}/page_views/top_referrers?start=${start}&end=${end}`
};

export { FetchTopReferrersOnDate, FetchTopReferrersBetweenDateRange, FetchTopReferrersBetweenDateRangeApi, FetchTopReferrersOnDateApi };
