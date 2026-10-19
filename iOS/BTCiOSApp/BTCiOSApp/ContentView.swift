import SwiftUI
import BTCKit

struct ContentView: View {
    @StateObject private var viewModel: BTCPriceViewModel

    init(loader: any BTCPriceLoader) {
        _viewModel = StateObject(wrappedValue: BTCPriceViewModel(loader: loader))
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Bitcoin Price")
                .font(.largeTitle.bold())

            Text(viewModel.price)
                .font(.system(size: 48, weight: .semibold, design: .rounded))
                .foregroundColor(.orange)

            if viewModel.isLoading {
                ProgressView()
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding(32)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}
