import axios from 'axios';

var Dates = function() {
  return axios.get('/page_views/dates')
  .then(function (response) {
    return response.data;
  })
  .catch(function (error) {
    console.log(error);
  });
};

var DatesRange = function() {
  return axios.get('/page_views/dates_range')
  .then(function (response) {
    return response.data;
  })
  .catch(function (error) {
    console.log(error);
  });
};

export { Dates, DatesRange };
