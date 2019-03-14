var assert = require('chai').assert;
var app = require('../index');

describe('Scaled Data', function(){

	it('Should return true if one tag is passed in, it matches, and therefore is scaled', function(){
		var from_broker_one_tag = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80.0,3]],
				name: "My.App.DOUBLE1"
			}
			],
			messageId: "flex-pipe"
		};
		var scaled_one_tag = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80000,3]],
				name: "My.App.DOUBLE1.scaled_x_1000"
			}
			],
			messageId: "flex-pipe"
		};
		assert.deepEqual(JSON.parse(app.scaleData(from_broker_one_tag)), scaled_one_tag);
	});
	it('Should return true if two tags are passed in, both of them match, and therefore both are scaled', function(){
		var from_broker_two_tags = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80.0,3]],
				name: "My.App.DOUBLE2"
			},
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints:[[1537377630622,112.64,3]],
				name: "My.App.DOUBLE2"
			}
			],
			messageId: "flex-pipe"
		};
		var scaled_both_tags = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80000,3]],
				name: "My.App.DOUBLE2.scaled_x_1000"
			},
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints:[[1537377630622,112640,3]],
				name: "My.App.DOUBLE2.scaled_x_1000"
			}
			],
			messageId: "flex-pipe"
		};
		assert.deepEqual(JSON.parse(app.scaleData(from_broker_two_tags)), scaled_both_tags);
	});

});
