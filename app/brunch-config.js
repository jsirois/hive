exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"
    },
    stylesheets: {
      joinTo: "css/app.css"
    }
  },
  conventions: {
    assets: /^static\//
  },
  paths: {
    watched: ["static", "css", "js", "elm"],
  },
  plugins: {
    elmBrunch: {
      elmFolder: "elm",
      mainModules: ["Main.elm"],
      outputFolder: "../js"
    },
  },
  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  }
};
