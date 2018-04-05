const http = require('http');

const server = http.createServer((req, res) => {
    res.end('Hello Nomad !');
});

server.listen(8080);
