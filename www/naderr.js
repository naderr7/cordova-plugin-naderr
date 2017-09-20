
var exec = require('cordova/exec');

var pluginName = "PrinterSDK";
var btPlugin = {
	connectPrinter: function(ipaddress, cd){
		cordova.exec(cd, null, pluginName, "connectPrinter", [ipaddress])
	},
		
	disconnectPrinter: function(successCallback, errorCallback){
		cordova.exec(successCallback, errorCallback, pluginName, "disconnectPrinter")
	},
		
	printData: function(successCallback, errorCallback){
		cordova.exec(successCallback, errorCallback, pluginName, "printData")
	},
		
	printTestPaper: function(successCallback, errorCallback){
		cordova.exec(successCallback, errorCallback, pluginName, "runPrintReceiptSequence")
	},
};

module.exports = btPlugin;
