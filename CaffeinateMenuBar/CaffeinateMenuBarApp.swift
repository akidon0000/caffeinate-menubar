import SwiftUI

@main
struct CaffeinateMenuBarApp: App {
    @StateObject private var controller = CaffeinateController()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(controller)
        } label: {
            Image(systemName: controller.isRunning ? "cup.and.saucer.fill" : "cup.and.saucer")
                .symbolRenderingMode(.palette)
                .foregroundStyle(controller.isRunning ? Color(red: 1.0, green: 0.5, blue: 0.5) : .primary)
        }
        .menuBarExtraStyle(.window)
    }
}
