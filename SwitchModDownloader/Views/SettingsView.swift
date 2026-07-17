import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        Form {
            Section(String(localized: "Download")) {
                HStack {
                    Text(viewModel.downloadDirectory)
                        .font(.body)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button(String(localized: "Select")) {
                        viewModel.selectDownloadDirectory()
                    }
                }
            }

            Section(String(localized: "Appearance")) {
                Picker(String(localized: "Theme"), selection: $viewModel.selectedTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .onChange(of: viewModel.selectedTheme) { newValue in
                    viewModel.updateTheme(newValue)
                }

                Picker(String(localized: "Default View"), selection: $viewModel.selectedDefaultViewMode) {
                    ForEach(DefaultViewMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .onChange(of: viewModel.selectedDefaultViewMode) { newValue in
                    viewModel.updateDefaultViewMode(newValue)
                }

                Picker(String(localized: "Default Sort"), selection: $viewModel.selectedDefaultModSort) {
                    ForEach(ModFilters.SortOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .onChange(of: viewModel.selectedDefaultModSort) { newValue in
                    viewModel.updateDefaultModSort(newValue)
                }
            }

            Section(String(localized: "Language")) {
                Picker(String(localized: "Interface Language"), selection: $viewModel.selectedLanguage) {
                    ForEach(AppLanguage.allCases, id: \.self) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .onChange(of: viewModel.selectedLanguage) { newValue in
                    viewModel.updateLanguage(newValue)
                    languageManager.setLanguage(newValue)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 400, minHeight: 300)
    }
}
