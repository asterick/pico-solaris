var fs = require("fs");
var zlib = require("zlib");

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
				dest: "/Users/bryon/Library/Application Support/pico-8/carts/solaris.p8.png",
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
