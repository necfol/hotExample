const http = require('http')
const url = require('url')
const fs = require('fs')
const os = require('os')
const path = require('path')
const querystring = require('querystring')
let versionStr = fs.readFileSync('./.necfolconfig')
let version = JSON.parse(versionStr)

var delay = (timeout) => {
    return new Promise(resolve => {
        setTimeout(function () {
            resolve(true)
        }, timeout)
    })
}
var getIp=function(){
    var os=require('os'),
        ipStr,
        infaces=os.networkInterfaces(),
        bool=false
    for(var i in infaces){
        infaces[i].some(function(x){
            if((x.family=='IPv4')&&(x.internal == false)){
                ipStr=x.address
                bool=true
                return true
            } 
        })
        if(bool){break}
    }
    return ipStr
}
var app = (req, res) => {
    var path = url.parse(req.url).pathname
    if (path == '/version') {
        res.setHeader('Content-Type', 'application/json')
        res.write(JSON.stringify(
            {
                version: version.lastVersion,
                zip: `http://${getIp()}:9000/diff_${version.lastVersion}.bundle.zip`
            }
        ))
    }
    res.end()
}
const svr = http.createServer(app)
svr.listen(3000)