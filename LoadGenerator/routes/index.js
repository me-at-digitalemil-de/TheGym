var express = require('express');
var router = express.Router();
var app = express();
var url= require('url');
var request = require('request');
var http = require("http");

let ui= process.env.UI;


/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: "Loader", nmsg: 0});
});

hashCode = function(s){
  return s.split("").reduce(function(a,b){a=((a<<5)-a)+b.charCodeAt(0);return a&a},0);              
}
console.log("Key: "+hashCode("Telekom-DataTransition-valid-util-22042017"));

setTimeout(load, 1000);

let SanFrancisco= 0, PaloAlto=1, Sheridan= 2, SanDiego= 3, Jackson= 4, Chicago= 5, Boston= 6, LosAngeles= 7, Rome= 8, London= 9, Moscow= 10, Paris= 11;  
let locations= ["37.775,-122.4183333", "37.4419444,-122.1419444", "44.7694,-106.969", "32.7152778,-117.1563889", "43.479929,-110.762428", "41.850033,-87.6500523", "42.3584308,-71.0597732", "34.0522342,-118.2436849", "41.9015141,12.4607737", "51.536086,-0.131836", "55.751849,37.573242", "48.864715,2.329102"];
let names= ["Flo", "Tobi", "Ben", "Travis", "James", "Tim", "Jamie", "Tony", "Joerg", "Jan", "Ferdi", "John"];
let devices= ["16380", "14321", "15121", "17445", "12444", "16453", "19201", "20452", "21345", "13896", "22783", "23999"];
let hrs= [120, 140, 90, 110, 150, 130, 100, 160, 130, 140, 150, 120 ];


function load() {
let d= new Date(); 
let day= d.getUTCDate();
let daystring= ""+day;
			
  			if(day< 10)
    				daystring="0"+daystring;
  			let month= d.getUTCMonth()+1;
  			let monthstring= ""+month;
  			if(month< 10)
    				monthstring="0"+monthstring;
            		
		        let hour= d.getUTCHours();
			let hourstring= ""+hour;
  			if(hour< 10)
    				hourstring="0"+hourstring;
            		
			let minute= d.getUTCMinutes();
			let minutestring= ""+minute;
  			if(minute< 10)
    				minutestring="0"+minutestring;
            		    
			let second= d.getUTCMilliseconds()/1000.0;
			let secondstring= ""+second;
  			if(second< 10)
    				secondstring="0"+secondstring
			    

let time= d.getFullYear()+"-"+monthstring+"-"+daystring+"T"+hourstring+":"+minutestring+":"+secondstring+"Z";
let id= d.getTime();
console.log("id: "+id);
for(var i= 0; i< 8; i++) {
  bpm= Math.floor(hrs[i]- 10+ Math.random()*20);
 //  json="Hello WOrld";
 let l= ('{"id":"' + (id+i) + '", "location":"' + locations[i] + '", "event_timestamp":"' + time + '", "deviceid":"' + devices[i] + '", "user":"' + names[i] + '", "heartrate":"' + bpm + '"}');
 console.log(l);
    request.post(ui+"/data", {form:l}, function(err, response, body) {
    if(err!=null) {
      console.log(err);
   }
});
}
  setTimeout(load, 1000);
  
};

module.exports = router;


