var assert = require('chai').assert;
var app = require('../index');

describe('Scaled Data', function(){
	it('Should return true if one tag is passed in, it does not match, and therefore is not scaled', function(){
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
		var one_tag_no_change = {
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
		assert.deepEqual(JSON.parse(app.scaleData(from_broker_one_tag, "My.App.DOUBLE2")), one_tag_no_change);
	});
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
		assert.deepEqual(JSON.parse(app.scaleData(from_broker_one_tag, "My.App.DOUBLE1")), scaled_one_tag);
	});
	it('Should return true if more than one tag is passed in, none match, and therefore none are scaled', function() {
		var from_broker_two_tags = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80.0,3]],
				name: "My.App.DOUBLE1"
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
		var two_tags_no_change = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80.0,3]],
				name: "My.App.DOUBLE1"
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
		assert.deepEqual(JSON.parse(app.scaleData(from_broker_two_tags, "My.App.DOUBLE3")), two_tags_no_change);
	});
	it('Should return true if two tags are passed in, and only the one with the matching tagName is scaled.', function(){
		var from_broker_two_tags = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80.0,3]],
				name: "My.App.DOUBLE1"
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
		var scaled_second_tag = {
			body: [
			{
				attributes:{
					machine_type:"opcua"
				},
				datapoints: [[1537377630622,80.0,3]],
				name: "My.App.DOUBLE1"
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
		assert.deepEqual(JSON.parse(app.scaleData(from_broker_two_tags, "My.App.DOUBLE2")), scaled_second_tag);
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
		assert.deepEqual(JSON.parse(app.scaleData(from_broker_two_tags, "My.App.DOUBLE2")), scaled_both_tags);
	});


});
