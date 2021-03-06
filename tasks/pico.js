/*
* grunt-peg
* https://github.com/dvberkel/grunt-peg
*
* Copyright (c) 2013 Daan van Berkel
* Licensed under the MIT license.
*/

'use strict';
var compiler = require("../compiler"),
	fs = require('fs');

module.exports = function(grunt) {
	// Please see the Grunt documentation for more information regarding task
	// creation: http://gruntjs.com/creating-tasks

	grunt.registerMultiTask('pico', 'Generates pico-8 games', function() {
		var done = this.async();
		var data = this.data;

		this.files.forEach(function(f) {
			var source = f.header.concat(
				f.src.filter(function (filepath, i) {
					return grunt.file.exists(filepath) && !grunt.file.isDir(filepath);	
				}).map(function (fp) {
					return grunt.file.read(fp);
				})).join("\n");

			compiler(f.dest, source, f.payload(), done)
		});
	});
};
