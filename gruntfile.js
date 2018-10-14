const fs = require("fs");
const zlib = require("zlib");
const os = require("os");

function dest() {
	switch (os.platform()) {
	case 'darwin':
		return "/Users/bryon/Library/Application Support/pico-8/carts/solaris.p8.png"
	case 'win32':
		return "C:\\Users\\unicd\\AppData\\Roaming\\pico-8\\carts\\solaris.p8.png"
	default:
		throw new Error(`Unknown platform ${os.platform()}`);
	}
}	

function payload() {
	var payload = [];

	return zlib.deflateRawSync(new Buffer(payload), { level: 9 });
}

module.exports = function(grunt) {
	grunt.initConfig({
		pico: {
			solaris: {
				header: [
					"-- Solaris",
					"-- by: asterick",
					"-- http://www.github.com/asterick/pico-solaris",
				],

				src: ["runtime/main.lua", "runtime/**/*"],
				dest: dest(),
				payload: payload
			}
		},
		watch: {
			pico: {
				files: ["runtime/**/*"],
				tasks: ["pico"]
			}
		}
	});

	grunt.loadTasks("tasks");
	grunt.loadNpmTasks('grunt-contrib-watch');
	
	grunt.registerTask("default", ["pico"]);
	grunt.registerTask("dev", ["default", "watch"]);
};
