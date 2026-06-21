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
        }
        .menuBarExtraStyle(.window)
    }
}
