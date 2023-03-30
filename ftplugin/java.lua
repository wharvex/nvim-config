local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

-- calculate workspace dir
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/site/java/workspace-root/" .. project_name
if vim.fn.isdirectory(workspace_dir) == 0 then
	vim.fn.mkdir(workspace_dir, "p")
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local util = require("jdtls.util")
local dap = require("dap")
require("jdtls").setup_dap({ hotcodereplace = "auto" })

dap.configurations.java = {
	{
		-- You need to extend the classPath to list your dependencies.
		-- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
		classPaths = {"/home/tim/projects/java/icsi311/"},

		-- If using multi-module projects, remove otherwise.
		-- projectName = "yourProjectName",

		javaExec = "/usr/bin/java",
		mainClass = "Shank",

		-- If using the JDK9+ module system, this needs to be extended
		-- `nvim-jdtls` would automatically populate this property
		modulePaths = {"/home/tim/projects/java/icsi311/"},
		name = "Launch Shank",
		request = "launch",
		type = "java",
		args = "parser_test.shank",
	},
}
dap.adapters.java = function(callback)
	util.execute_command({ command = "vscode.java.startDebugSession" }, function(err0, port)
		assert(not err0, vim.inspect(err0))
		callback({
			type = "server",
			host = "127.0.0.1",
			port = port,
		})
	end)
end
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
	-- The command that starts the language server
	-- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
	cmd = {

		"java", -- or '/path/to/java17_or_newer/bin/java'
		-- depends on if `java` is in your $PATH env variable and if it points to the right version.

		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",

		"-jar",
		"/home/tim/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
		"-configuration",
		"/home/tim/config_linux",

		"-data",
		workspace_dir,
	},

	root_dir = root_dir,

	-- Here you can configure eclipse.jdt.ls specific settings
	-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
	-- for a list of options
	settings = {
		java = {},
	},

	-- Language server `initializationOptions`
	-- You need to extend the `bundles` with paths to jar files
	-- if you want to use additional eclipse.jdt.ls plugins.
	--
	-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
	--
	-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
	init_options = {
		bundles = {
			vim.fn.glob(
				"/home/tim/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.44.0.jar",
				1
			),
		},
	},
	capabilities = capabilities,
	on_attach = {
		function(client, bufnr)
			require("jdtls.dap").setup_dap_main_class_configs()
		end,
	},
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require("jdtls").start_or_attach(config)
