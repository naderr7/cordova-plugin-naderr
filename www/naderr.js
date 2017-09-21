
var exec = require('cordova/exec');

var pluginName = "naderr";
var naderPlugin = {
	connectPrinter: function(ipaddress, cd){
		cordova.exec(cd, null, pluginName, "connectPrinter", [ipaddress])
	},
		
	disconnectPrinter: function(successCallback, errorCallback){
		cordova.exec(successCallback, errorCallback, pluginName, "disconnectPrinter")
	},
		
	printData: function(successCallback, errorCallback){
		cordova.exec(successCallback, errorCallback, pluginName, "printData")
	}
};

module.exports = naderPlugin;
