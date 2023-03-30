require("wharvez.remap")
require("wharvez.packer")
require("wharvez.set")

local dap = require("dap")
dap.configurations.java = {
	{
		-- You need to extend the classPath to list your dependencies.
		-- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
		-- classPaths = {},

		-- If using multi-module projects, remove otherwise.
		-- projectName = "yourProjectName",

		javaExec = "/path/to/your/bin/java",
		mainClass = "Shank",

		-- If using the JDK9+ module system, this needs to be extended
		-- `nvim-jdtls` would automatically populate this property
		-- modulePaths = {},
		name = "Launch Shank",
		request = "launch",
		type = "java",
		args = "parser_test.shank",
	},
}
