import Foundation
import PackagePlugin

@main
struct NetworkLayerSwiftLintBuildToolPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) throws -> [Command] {
        guard target is SourceModuleTarget else { return [] }
        let packageDir = context.package.directory.string
        let cacheDir = context.pluginWorkDirectory.string
        let shell = Path("/bin/sh")
        let extra = ProcessInfo.processInfo.environment["SWIFTLINT_OPTIONS"] ?? ""

        let command = """
        cd "\(packageDir)" && \
        swiftlint lint --quiet --cache-path "\(cacheDir)" \(extra)
        """
        var env = ProcessInfo.processInfo.environment
        if env["HOME"] == nil,
           let home = FileManager.default.homeDirectoryForCurrentUser.path.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
           ) {
            env["HOME"] = home
        }

        return [
            .prebuildCommand(
                displayName: "SwiftLint (\(target.name))",
                executable: shell,
                arguments: ["-lc", command],
                environment: env,
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}
