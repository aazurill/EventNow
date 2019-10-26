
// Read the file and print its contents.
function processFile(){
    var fs = require('fs'), filename = process.argv[2];
    var text = fs.readFileSync('Events.txt','utf8');
    var array = text.split("\r\n");
    var output =parseInt(array[0].split(",")[1],10);
    console.log(array);

    return array;
}
processFile();
//console.log(array)
