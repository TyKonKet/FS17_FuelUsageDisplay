const os = require('os');
const gulp = require('gulp');
const gutil = require("gulp-util");
const fs = require("fs");
const path = require('path');
const del = require("del");
const size = require('gulp-size');
const zip = require("gulp-zip");
const run = require('gulp-run');
const replace = require('gulp-replace');
const execFile = require('child_process').execFile;
const ftp = require("vinyl-ftp");
const xmlbuilder = require("xmlbuilder");
const _ = require("lodash");
const xml2js = require("xml2js");
const Promise = require("bluebird");
const xmlescape = require('xml-escape');

var mod = JSON.parse(fs.readFileSync("mod.json"));
var package = JSON.parse(fs.readFileSync("package.json"));

const modName = mod.name;
const zipName = `${mod.name}.zip`;
const destination = parseAPath(mod.destination);
const zipSources = mod.zipSources;
const start = mod.start;
const fsDocPath = parseAPath(mod.fsDocPath);
const clearLog = mod.clearLog;

const serverUrl = `${mod.server.protocol}://${mod.server.host}:${mod.server.port}/`;

gulp.task("clean:log", () => {
  if (clearLog) {
    return del(`${fsDocPath}log.txt`, { force: true });
  }
  return;
});

gulp.task("clean:out", () => {
  return del(`./out/${zipName}`);
});

gulp.task("clean:install", () => {
  return del(`${destination}${zipName}`, { force: true });
});

gulp.task("startMode", () => {
  return gulp
    .src(`${fsDocPath}game.xml`)
    .pipe(replace(/<startMode>.<\/startMode>/g, "<startMode>1</startMode>"))
    .pipe(gulp.dest(`${fsDocPath}`));
});

gulp.task("build:out", ["clean:out"], () => {
  return gulp.src(zipSources, { cwd: './src/' })
    .pipe(replace(/{package_author}/g, package.author, { skipBinary: true }))
    .pipe(replace(/{package_version}/g, package.version + ".0", { skipBinary: true }))
    .pipe(size())
    .pipe(zip(zipName))
    .pipe(size())
    .pipe(gulp.dest(`./out/`));
});

gulp.task("install", ["build:out", "clean:install"], () => {
  return gulp.src(`./out/${zipName}`)
    .pipe(gulp.dest(destination));
});

gulp.task("build", ["clean:log", "startMode", "install"], () => {
  if (start.enabled) {
    var params = start.params;
    if (start.savegame.enabled) {
      params.push("-autoStartSavegameId", start.savegame.number);
    }
    return execFile(start.path, params);
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

gulp.task("server:login", serverLogin);

gulp.task("server:stop", ["server:login"], serverStop);

gulp.task("server:start", ["server:login"], serverStart);

gulp.task("server:install:1", ["install", "server:login"], serverStop);

gulp.task("server:install:2", ["server:install:1"], () => {
  const conn = new ftp({
    host: mod.server.ftp.host,
    port: mod.server.ftp.port,
    user: mod.server.ftp.user,
    pass: mod.server.ftp.password
  });
  return gulp
    .src(`./out/${zipName}`, { buffer: false })
    .pipe(conn.dest(mod.server.ftp.path))
    .pipe(gutil.noop());
});

gulp.task("server:install", ["server:install:2"], serverStart);

gulp.task("server:build", ["server:install", "clean:log", "startMode"], () => {
  if (start.enabled) {
    var params = start.params;
    if (start.savegame.enabled) {
      params.push("-autoStartSavegameId", start.savegame.number);
    }
    return execFile(start.path, params);
  }
  return;
});

gulp.task("server:default", ["server:build"]);

function serverLogin() {
  const command = `curl_server_login ${mod.server.username} ${mod.server.password} ${serverUrl}`;//*/`curl -X POST -c .cookies --data "username=${mod.server.username}&password=${mod.server.password}&login=Login" -H "Origin: ${serverUrl}" ${serverUrl}index.html > NUL`;
  return run(command, { silent: true }).exec()
    .pipe(gutil.noop());
}

function serverStop() {
  const command = `curl_server_stop ${serverUrl}`;//*/`curl -X POST -b .cookies --data "stop_server=Stop" -H "Origin: ${serverUrl}" ${serverUrl}index.html > NUL`;
  return run(command, { silent: true }).exec()
    .pipe(gutil.noop());
}

function serverStart() {
  const command = `curl_server_start ${mod.server.game.name} ${mod.server.game.adminPassword} ${mod.server.game.gamePassword} ${mod.server.game.savegame} ${serverUrl}`;//*/`curl -X POST -b .cookies --data "game_name=${mod.server.game.name}&admin_password=${mod.server.game.adminPassword}&game_password=${mod.server.game.gamePassword}&savegame=${mod.server.game.savegame}&map_start=default_Map01&difficulty=1&dirt_interval=2&matchmaking_server=2&mp_language=en&auto_save_interval=180&stats_interval=360&pause_game_if_empty=on&start_server=Start" -H "Origin: ${serverUrl}" ${serverUrl}index.html > NUL`;
  return run(command, { silent: true }).exec()
    .pipe(gutil.noop());
}

// translations generator from Realismus Modding https://github.com/RealismusModding
gulp.task("translations", () => {
  const languages = ["br", "cs", "ct", "cz", "de", "en", "es", "fr", "hu", "it", "jp", "kr", "nl", "pl", "pt", "ro", "ru", "tr"];
  Promise.reduce(languages, (result, language) => {
    return loadXML(language).then((data) => {
      result[language] = data;
      return result;
    });
  }, {})
    .then((data) => Promise.map(languages, (language) => {
      if (language === "en") {
        return Promise.resolve();
      }
      const path = pathForTranslation(language);
      return createXML(data, language).then((xml) => {
        console.log(`Writing XML file for '${language}'`);
        return writeXML(xml, path);
      });
    }))
    .then(() => {
      console.log("Finished!");
    })
    .catch((err) => {
      console.log("Error", err);
    })
});

function createXML(data, language) {
  if (!data[language]) {
    data[language] = {
      translations: {},
      contributors: []
    }
  }
  const xmlTexts = _.reduce(data["en"].translations, (result, value, key) => {
    const trValue = data[language].translations[key];
    const enTrValue = data["en"].translations[key];
    if (language !== "en" && (!trValue || trValue === enTrValue)) {
      console.log("Missing translation of '" + key + "' for", language);
      result.push({
        "#comment": `Missing translation of "${enTrValue}"`
      });
    }
    result.push({
      "text": {
        "@name": key,
        "@text": !!trValue ? trValue : enTrValue
      }
    });
    return result
  }, []);
  const xmlHeader = {
    version: "1.0",
    encoding: "utf-8",
    standalone: false
  };
  const xmlOptions = {
    stringify: {
      convertCommentKey: "#comment"
    }
  };
  const root = xmlbuilder.create("l10n", xmlHeader, {}, xmlOptions);
  root.ele("translationContributors", {}, data[language].contributors.join(", "));
  root.ele("texts").ele(xmlTexts);
  let text = root.end({
    pretty: true,
    indent: "    "
  }) + "\n";
  let newlines = data["en"].newlines;
  const searchReg = new RegExp(/^\s*<text\s+name=\"(.*)\"\s+text=\"(.*)\"\s*\/>$\n/, "igm");
  const padding = " ".repeat(8);
  text = text.replace(searchReg, (match, name, value, offset, string) => {
    if (newlines.includes(name)) {
      return padding + "<text name=\"" + name + "\" text=\"" + value + "\" />\n\n";
    } else {
      return padding + "<text name=\"" + name + "\" text=\"" + value + "\" />\n";
    }
  });
  return Promise.resolve(text);
}

function pathForTranslation(language) {
  return path.join(".", "src", "l10n", `modDesc_l10n_${language}.xml`)
}

function readXML(path) {
  return new Promise((resolve, reject) => {
    fs.readFile(path, { encoding: "utf8" }, (err, data) => {
      if (err) {
        return reject(err);
      }
      xml2js.parseString(data, (err, data) => {
        if (err) {
          console.log(path);
          return reject(err);
        }
        resolve(data)
      });
    });
  });
}

function loadXML(language) {
  if (!fs.existsSync(pathForTranslation(language))) {
    console.error("Failed loading " + pathForTranslation(language));
    return Promise.resolve();
  }
  return readXML(pathForTranslation(language)).then((xml) => {
    console.log(`Read XML file for '${language}'`);
    let data = {
      translations: {},
      contributors: [],
      newlines: [],
    };
    if (!xml.l10n) {
      return data;
    }
    let contribs = _.get(xml, "l10n.translationContributors", [""])[0];
    data.contributors = _.map(contribs.split(","), _.trim);
    let items = _.get(xml, "l10n.texts.0.text");
    data.translations = _.reduce(items, (result, value) => {
      if (_.has(value, "$.name")) {
        result[_.get(value, "$.name")] = _.get(value, "$.text", "");
      }
      return result;
    }, {});
    const fileText = fs.readFileSync(pathForTranslation(language), "utf8");
    const reg = new RegExp(/^\s*<text\s+name=\"(.*)\"\s+text=\".*\"\s*\/>$\n\n/, "igm");
    let match = reg.exec(fileText);
    while (match !== null) {
      data.newlines.push(match[1]);
      match = reg.exec(fileText);
    }
    return data;
  })
}

function writeXML(xml, path) {
  return new Promise((resolve, reject) => {
    fs.writeFile(path, xml, { encoding: "utf8" }, (err) => {
      if (err) {
        return reject(err);
      }
      resolve();
    });
  });
}