import axios from 'axios';

var FetchTopUrlsOnDate = function(date) {
  return axios.get(FetchTopUrlsOnDateApi(date))
  .then(function (response) {
    return response.data
  })
  .catch(function (error) {
    console.log(error);
  });
};

var FetchTopUrlsOnDateRange = function(start, end) {
  return axios.get(FetchTopUrlsOnDateRangeApi(start, end))
  .then(function (response) {
    return response.data
  })
  .catch(function (error) {
    console.log(error);
  });
};

var FetchTopUrlsOnDateApi = function(date){
  return `${axios.defaults.baseURL}/page_views/top_urls?date=${date}`
};

var FetchTopUrlsOnDateRangeApi = function(start, end) {
  return `${axios.defaults.baseURL}/page_views/top_urls?start=${start}&end=${end}`
};

export { FetchTopUrlsOnDate, FetchTopUrlsOnDateRange, FetchTopUrlsOnDateApi, FetchTopUrlsOnDateRangeApi };
