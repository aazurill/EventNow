const express = require('express');
const http = require('http');
const bodyParser = require('body-parser');
const app = express();
const server = http.createServer(app);

// Server will always find an open port.
const port = process.env.PORT || 3001;
server.listen(port, '0.0.0.0', () => {
    console.log(`Server listening on port ${port}`);
});

// List of ice cream events

const events =[];
// Needed to process body parameters for POST requests
app.use(bodyParser.urlencoded({ extended: true }));

// Default endpoint
app.get('/', (req, res) => {
    res.sendFile(__dirname + "/public/EventNowIndex.html");
});

// Inserting an ice cream
app.post('/insertData', (req, res) => {
    const params = req.body;

    events.push([params.name, params.location]);
    res.redirect('/');
});

// Gets all the ice creams in the array
app.get('/getData', (req, res) => {
    res.send(events.toString());

});

// TODO: Write a GET request to /count that checks iterates through
//       the array and sends how many of a certain ice cream event
//       exists to the response.
//       Use req.query.event to grab the event parameter.
app.get('/count', (req, res) => {
    const event = req.query.event;
    let count = 0;
    for (let i = 0; i < events.length; i++) {
        if (events[i] == event) {
            count++;
        }
    }
    res.send(count.toString());
});

// TODO: Write a GET request to /randomevent that sends a random
//       event from our array to the response.
app.get('randomevent', (req,res) => {
    res.send(events[getRandomNumber()]);
});

// Method that gets a random index from the events array
function getRandomNumber() {
    const num = Math.floor(Math.random() * events.length);
    return num;
}
