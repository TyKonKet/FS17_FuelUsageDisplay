const os = require('os');
var gulp = require('gulp');
var fs = require("fs");
var path = require('path');
var del = require("del");
var size = require('gulp-size');
var zip = require("gulp-zip");
var run = require('gulp-run');
var replace = require('gulp-replace');
var execFile = require('child_process').execFile;

var mod = JSON.parse(fs.readFileSync("mod.json"));
const modName = mod.name;
const zipName = `${mod.name}.zip`;
const destination = parseAPath(mod.destination);
const zipSources = mod.zipSources;
const start = mod.start;
const fsDocPath = parseAPath(mod.fsDocPath);
const clearLog = mod.clearLog;

gulp.task("clean:log", () => {
  if (clearLog) {
    return del(`${fsDocPath}log.txt`, { force: true });
  }
  return;
});

gulp.task("startMode", () => {
  return gulp
    .src(`${fsDocPath}game.xml`)
    .pipe(replace(/<startMode>.<\/startMode>/g, "<startMode>1</startMode>"))
    .pipe(gulp.dest(`${fsDocPath}`));
});

gulp.task("clean:out", () => {
  return del(`./out/${zipName}`);
});

gulp.task("build:out", ["clean:out"], () => {
  return gulp.src(zipSources, { cwd: './src/' })
    .pipe(size())
    .pipe(zip(zipName))
    .pipe(size())
    .pipe(gulp.dest(`./out/`));
});

gulp.task("clean:dest", () => {
  return del(`${destination}${zipName}`, { force: true });
});

gulp.task("build:dest", ["build:out", "clean:dest"], () => {
  return gulp.src(`./out/${zipName}`)
    .pipe(gulp.dest(destination));
});

gulp.task("build", ["clean:log", "startMode", "build:dest"], () => {
  if (start.enabled) {
    return execFile(start.path, start.params);
  }
  return;
});

gulp.task("release", ["build:out"], () => {
  return;
});

gulp.task("default", ["build"]);

function parseAPath(path) {
  path = path.replace("${homeDir}", os.homedir());
  return path;
}
