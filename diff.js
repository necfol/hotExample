const exec = require('child_process').exec
const fs = require('fs')
const path = require('path')
const DiffMatchPatch = require('diff-match-patch')
function ensureFolder(dir) {
  try {
    fs.accessSync(dir, fs.F_OK)
    return true
  } catch (e) {
    fs.mkdirSync(dir)
    return false
  }
}
function mkdirsSync(dirname) {  
    if (fs.existsSync(dirname)) {  
        return true  
    } else {  
        if (mkdirsSync(path.dirname(dirname))) {  
            fs.mkdirSync(dirname)  
        return true  
        }  
    }  
}
function copyFile(src, dist) {
    fs.writeFileSync(dist, fs.readFileSync(src))
}
function increaseVersion(str) {
    let newstr = Number(str.split('.').join(''))
    newstr++
    newstr = (newstr + '').split('')
    return newstr.join('.')
}

mkdirsSync('./build/last/')
mkdirsSync('./build/new/')
mkdirsSync('./build/diff/')
let lastVersionStr = fs.readFileSync('./.necfolconfig')
let lastVersion = JSON.parse(lastVersionStr)
let newVersion = increaseVersion(lastVersion.lastVersion)
const lastPath = path.resolve('./build/last/', `last_${lastVersion.lastVersion}.bundle`)
const newPath = path.resolve('./build/new/', `main_${newVersion}.bundle`)
const diffPath = path.resolve('./build/diff/', 'diff.bundle')
let build = exec(`react-native bundle --entry-file index.js --bundle-output ./build/new/main_${newVersion}.bundle --platform ios --dev false `)
build.stdout.on('data', data => console.log('======: ', data))
build.stdout.on('close', nextStep)
function nextStep(e) {
    copyFile(`./build/new/main_${newVersion}.bundle`, `./build/last/last_${newVersion}.bundle`)
    let lastCode
    try {
        lastCode = fs.readFileSync(lastPath, 'utf-8')
    } catch(e) {
        lastCode = fs.readFileSync(newPath, 'utf-8')
    }
    let newCode = fs.readFileSync(newPath, 'utf-8')
    let dmp = new DiffMatchPatch()
    let diffCode = dmp.patch_make(lastCode, newCode)
    fs.writeFileSync(diffPath, diffCode, 'utf-8')
    fs.writeFileSync('./.necfolconfig', JSON.stringify({
        lastVersion: newVersion
    }), 'utf-8')
    exec(`zip -q -r -j ./build/diff/diff_${newVersion}.bundle.zip ./build/diff/diff.bundle`)
}