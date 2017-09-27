import React from 'react';
var createReactClass = require('create-react-class');

var SelectDropDown = createReactClass({
  render(){
    const options = this.props.items.map((item,i) => {
      return <option value={item.value} key={i} >{item.label}</option>
    });
    return (
      <div>
        <select className="form-control" onChange={this.props.onChangeHandler}>
          {options}
        </select>
      </div>
    )
  }
});

export default SelectDropDown;
