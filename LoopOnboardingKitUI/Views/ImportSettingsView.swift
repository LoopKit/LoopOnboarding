//
//  ImportSettingsView.swift
//  LoopOnboardingKitUI
//
//  Created by Pete Schwamb on 2/21/22.
//

import SwiftUI
import LoopKit
import LoopKitUI
import NightscoutServiceKit

struct ImportSettingsView: View {
    @Environment(\.guidanceColors) private var guidanceColors

    private var didFinish: ((Bool) -> Void)?
    private var importedTherapySettings: ImportedTherapySettings

    private var settingsAgeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        return formatter
    }()

    init(importedTherapySettings: ImportedTherapySettings, didFinish: ((Bool) -> Void)?) {
        self.importedTherapySettings = importedTherapySettings
        self.didFinish = didFinish
    }

    private var settingsDate: Date {
        importedTherapySettings.date
    }

    /// The imported profiles, the active one marked, when there is more than Default.
    private var profilesText: String? {
        let therapySettings = importedTherapySettings.therapySettings
        guard let profiles = therapySettings.therapyProfiles, profiles.count > 1 else {
            return nil
        }
        let activeName = TherapyProfiles.activeName(therapySettings.activeProfileName)
        let names = profiles.map { profile in
            profile.name == activeName ? String(format: LocalizedString("%1$@ (active)", comment: "Imported profile name of the active profile (1: profile name)"), profile.name) : profile.name
        }
        return String(format: LocalizedString("Profiles: %1$@", comment: "List of imported therapy profiles (1: profile names)"), names.joined(separator: ", "))
    }

    /// The imported scheduled switches as a week from Monday, the paused ones marked.
    private var scheduledSwitchesText: String? {
        guard let entries = importedTherapySettings.therapySettings.scheduledSwitches, !entries.isEmpty else {
            return nil
        }
        let descriptions = ScheduledProfileSwitches.sortedAsWeek(entries).map { entry in
            entry.paused ? String(format: LocalizedString("%1$@ (paused)", comment: "Imported scheduled profile switch that is paused (1: scheduled switch description)"), entry.localizedDescription) : entry.localizedDescription
        }
        return String(format: LocalizedString("Scheduled switches: %1$@\n\nEach switch first runs at its next time after the import. You can change or pause them under Settings → Profiles.", comment: "List of imported scheduled profile switches (1: scheduled switch descriptions)"), descriptions.joined(separator: ", "))
    }

    private var skippedProfilesText: String? {
        skippedText(heading: LocalizedString("These profiles will not be imported:", comment: "Heading of the therapy profiles that will not be imported"), items: importedTherapySettings.skippedProfiles)
    }

    private var skippedScheduledSwitchesText: String? {
        skippedText(heading: LocalizedString("These scheduled switches will not be imported:", comment: "Heading of the scheduled profile switches that will not be imported"), items: importedTherapySettings.skippedScheduledSwitches)
    }

    private func skippedText(heading: String, items: [ImportedTherapySettings.SkippedProfile]) -> String? {
        guard !items.isEmpty else {
            return nil
        }
        let reasons = items.map { String(format: LocalizedString("%1$@: %2$@", comment: "A therapy profile or scheduled switch that will not be imported (1: profile name or scheduled switch description, 2: reason)"), $0.name, $0.reason) }
        return heading + "\n" + reasons.joined(separator: "\n")
    }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Text(LocalizedString("Settings Found", comment: "Title on ImportSettingsView"))
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    Text(String(format: LocalizedString("We've detected Loop settings stored in your Nightscout! They were last updated %1$@. Would you like to import them?\n\nAfter importing, you will still need to review the imported settings in the following screens and verify that they are correct.", comment: "Format string for main guidance text on ImportSettingsView (1: age of settings)"), settingsAgeFormatter.localizedString(fromTimeInterval: settingsDate.timeIntervalSinceNow)))
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.secondary)
                    if let profilesText {
                        Text(profilesText)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.secondary)
                    }
                    if let scheduledSwitchesText {
                        Text(scheduledSwitchesText)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.secondary)
                            .accessibilityIdentifier("text_ScheduledSwitches")
                    }
                    if let skippedProfilesText {
                        Text(skippedProfilesText)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(guidanceColors.warning)
                            .accessibilityIdentifier("text_SkippedProfiles")
                    }
                    if let skippedScheduledSwitchesText {
                        Text(skippedScheduledSwitchesText)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(guidanceColors.warning)
                            .accessibilityIdentifier("text_SkippedScheduledSwitches")
                    }
                }
            }
            Button(action: {
                self.didFinish?(true)
            }) {
                Text(LocalizedString("Import Saved Settings", comment:"Button title for choosing to import settings from nightscout"))
                    .actionButtonStyle(.primary)
            }
            Button(action: {
                self.didFinish?(false)
            }) {
                Text(LocalizedString("Do Not Import Settings", comment:"Button title for skipping setting import from nightscout"))
                    .actionButtonStyle(.secondary)
            }
        }
        .padding()
        .environment(\.horizontalSizeClass, .compact)
        .navigationBarTitle("")
    }
}

struct ImportSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImportSettingsView(importedTherapySettings: ImportedTherapySettings(therapySettings: TherapySettings(), date: Date().addingTimeInterval(-24 * 60 * 60), skippedProfiles: [])) { (shouldImport) in
                print("Should import: \(shouldImport)")
            }
        }
        .previewDevice("iPod touch (7th generation)")
    }
}
