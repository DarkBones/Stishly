import React from "react"
import PropTypes from "prop-types"
class LeftMenu extends React.Component {
  render () {
    return (
      <React.Fragment>
        <div id="sidebar" className="position-fixed collapse width show bg-light in" aria-expanded="true">
        	<div id="menu-container" className="px-4">
        		<h1>
        			Accounts
        		</h1>
        		{JSON.stringify(this.props.accounts)}
        	</div>
        </div>
      </React.Fragment>
    );
  }
}

LeftMenu.propTypes = {
  accounts: PropTypes.object
};
export default LeftMenu
