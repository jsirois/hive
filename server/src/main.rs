#![feature(plugin)]
#![plugin(rocket_codegen)]

#[macro_use]
extern crate clap;

extern crate rocket;

use clap::Arg;

use rocket::config::{Config, Environment};
use rocket::response::NamedFile;
use rocket::State;

use std::io;
use std::path::PathBuf;

struct ServerConfig {
  app_dir: PathBuf,
}

#[get("/")]
fn index(state: State<ServerConfig>) -> io::Result<NamedFile> {
  NamedFile::open(state.app_dir.join("index.html"))
}

#[get("/<file..>")]
fn files(state: State<ServerConfig>, file: PathBuf) -> Option<NamedFile> {
  NamedFile::open(state.app_dir.join(file)).ok()
}

fn rocket(config: Config) -> rocket::Rocket {
  rocket::custom(config, true).mount("/", routes![index, files])
}

fn main() {
  let args = app_from_crate!("\n")
    .arg(
      Arg::with_name("app_dir")
        .help("The path to the directory containing the Hive static web assets.")
        .value_name("APP_DIR")
        .index(1)
        .required(true),
    )
    .arg(
      Arg::with_name("address")
        .help("The IP to bind.")
        .value_name("IP")
        .short("i")
        .long("ip-address")
        .default_value("localhost"),
    )
    .arg(
      Arg::with_name("port")
        .help("The port to bind the Hive web server to.")
        .value_name("PORT")
        .short("p")
        .long("port")
        .default_value("8000"),
    )
    .get_matches();

  let address = args.value_of("address").unwrap();
  let port = value_t!(args.value_of("port"), u16).unwrap_or_else(|e| e.exit());
  let config = Config::build(Environment::Development)
    .address(address)
    .port(port)
    .unwrap();

  let app_dir: PathBuf = args
    .value_of("app_dir")
    .expect("The app_dir argument is required.")
    .into();
  rocket(config).manage(ServerConfig { app_dir }).launch();
}
