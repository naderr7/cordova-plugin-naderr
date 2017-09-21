var exec = require('cordova/exec');

var pluginName = "naderr";
var naderPlugin = {		
	printData: function(successCallback, errorCallback){
		cordova.exec(successCallback, errorCallback, pluginName, "printData")
	}
};

module.exports = naderPlugin;
