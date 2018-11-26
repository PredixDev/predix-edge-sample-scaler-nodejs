// load the mqtt package so we can communicate with the app containers
var mqtt = require('mqtt')

//the opc-ua tag we will look for to scale

console.log("app starting");

function scaleData(item,tag){
  var length = item.body.length;

  if (length>0){
    for (var i=0; i<length; i++){

      //if the item is equal to the tagName we are loojing for then scale up the value by 1000 and put it back on the broker to be sent to timeseries
      if (item.body[i].name == tag)
      {
          var value = item.body[i].datapoints[0][1];

          //scale the tag value * 1000
          value = value * 1000;
          item.body[i].datapoints[0][1] = value;

          //give the scaled tag a new name
          item.body[i].name = tag + '.scaled_x_1000';
         
      }
    } 
  }

  return JSON.stringify(item);

};


//connect to the predix-edge-broker - use an environment variable if devloping locally

if (process.argv[2] == 'local') {
  var predix_edge_broker = '127.0.0.1:1883'
} else {
  var predix_edge_broker = 'predix-edge-broker';
}
console.log(predix_edge_broker);
var client  = mqtt.connect('mqtt://' + predix_edge_broker);
var tagName = 'My.App.DOUBLE2';

client.on('connect', function () {
  console.log("connected to predix-edge-broker");

  //subscribe to the topic being published by the opc-ua container
  client.subscribe('app_data');
});

//handle each message as it is recieved
client.on('message', function (topic, message) {


  console.log("message recieved from predix-edge-broker: " + message.toString());

  //add your app logic all goes below here

  //read the message into a json object

  var jsonMessage = JSON.parse(message);

  scaled_item = scaleData(jsonMessage,tagName);
   //publish the tag back to the broker on the topic the cloud-gateway container is subscribing to
  client.publish("timeseries_data", scaled_item);

  console.log("published scaled item to predix-edge-broker: " + scaled_item);

});
module.exports = {scaleData};