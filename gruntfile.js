var fs = require("fs");
var zlib = require("zlib");

function payload() {
	var payload = [];

	var a = 0;
	for (var i = 0; i < 32; i++ ) { payload[a++]=0x80; payload[a++]=0xA2 }
	for (var i = 0; i < 32; i++ ) { payload[a++]=0x4C; payload[a++]=0x6E }
	for (var i = 0; i < 32; i++ ) { payload[a++]=0xB3; payload[a++]=0x91 }
	for (var i = 0; i < 32; i++ ) { payload[a++]=0x7F; payload[a++]=0x5D }

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
