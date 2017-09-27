import axios from 'axios';

var SetUpApi = function(){
  console.log("Setting up baseURL as", process.env.API_URL);
  axios.defaults.baseURL = process.env.API_URL;
}
export default SetUpApi;
