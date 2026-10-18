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

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                Text(viewModel.price)
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundColor(.orange)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Button {
                viewModel.load()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(viewModel.isLoading)
        }
        .padding(32)
        .onAppear { viewModel.load() }
    }
}
