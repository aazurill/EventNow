const express = require('express');
const http = require('http');
const bodyParser = require('body-parser');
const app = express();
const server = http.createServer(app);
var fs = require('fs');
var ClubID = 0;
// Server will always find an open port.
const port = process.env.PORT || 8080;
server.listen(port, '0.0.0.0', () => {
    console.log(`Server listening on port ${port}`);
});


const events = [];
const clubs = [];
const tags =[];

jsonStr ='[]';
app.use(express.static(__dirname+"/public"));
var obj = JSON.parse(jsonStr);

// Needed to process body parameters for POST requests
app.use(bodyParser.urlencoded({ extended: true }));

// Default endpoint
app.get('/', (req, res) => {
    res.sendFile(__dirname + "/public/EventNowIndex.html");
});

// Inserting an event
app.post('/insertData', (req, res) => {
    const params = req.body;
    var local = params.location.split(" ");
    var exists = false;
    var tempID = -1;
    var tagged = params.tagger.split(" ");
    var x;
    for( x =0;x<tagged.length;x++){
      if(!tags.includes(tagged[x])){
        tags.push(tagged[x]);
      }
    }
    clubs.forEach(function(element){
      if(element["group"]==params.group){
        exists = true;
      }
      else{
        tempID = element["ClubID"];
      }
    });
    if(!exists){
      var clubD = {"group": params.group, "ClubID": ClubID++, "Description": "TBA"};
      clubs.push(clubD);
      tempID = ClubID;
    }

    var array = {"name": params.name, "group": params.group, "ClubID": ClubID, "lat": parseFloat(local[0]).toFixed(10),
      "long": parseFloat(local[1]).toFixed(10),
      "start": new Date(params.starttime).valueOf(), "end": new Date(params.endtime).valueOf(),
      "Description": params.description, "Tags" : tagged};

    events.push(array);
    obj.push(array);

  //  console.log(JSON.stringify(obj));
    fs.writeFile("EventList.json", JSON.stringify(obj), function(err) {
    if (err) {
        console.log(err);
    }
    });
    res.redirect('/');
});
app.get('/getClub',(req,res) =>{
  res.send(clubs);
});
// Gets all the events in the array
app.get('/getMap', (req, res) => {
    res.sendFile(__dirname + "/index.html" );
});

app.get('/getEvent',(req,res)=>{
    res.send(events)
});


app.get('/count', (req, res) => {
    const event = req.query.event;
    let count = events.length;

    res.send(count.toString());
});

// TODO: Write a GET request to /randomevent that sends a random
//       event from our array to the response.
app.get('/randomEvent', (req,res) => {
  const event = events[getRandomNumber()];
    res.send(event[0]);
});

app.get('/findEvent', (req,res) => {
    const keywords = req.query.keywords;
    for (let i = 0; i < events.length; i++) {
        if (events[i]["name"].includes(keywords)) {
            interested.push(events[i]);
        }
    }
    res.send(interested);
});

// Method that gets a random index from the events array
function getRandomNumber() {
    const num = Math.floor(Math.random() * events.length);
    return num;
}
