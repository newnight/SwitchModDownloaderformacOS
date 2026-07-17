import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal, 16)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            TextField(String(localized: "Enter game name..."), text: $viewModel.searchKeyword)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    Task { await viewModel.search() }
                }

            Button {
                Task { await viewModel.search() }
            } label: {
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            if !viewModel.searchKeyword.isEmpty {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
