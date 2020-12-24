//
//  ApodWidget.swift
//  ApodWidget
//
//  Created by SchwiftyUI on 12/7/20.
//

import WidgetKit
import SwiftUI
import Intents

struct ApodTimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ApodTimelineEntry {
        ApodTimelineEntry(date: Date(), image: UIImage(named: "Placeholder")!, text: "Sample Text", shouldShowText: true)
    }

    func getSnapshot(for configuration: ApodWidgetConfigurationIntent, in context: Context, completion: @escaping (ApodTimelineEntry) -> ()) {
        let entry = ApodTimelineEntry(date: Date(), image: UIImage(named: "Placeholder")!, text: "Sample Text", shouldShowText: configuration.ShouldShowText as? Bool ?? false)
        completion(entry)
    }

    func getTimeline(for configuration: ApodWidgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        ApodImageProvider.getImageFromApi() { apodImageResponse in
            var entries: [ApodTimelineEntry] = []
            var policy: TimelineReloadPolicy
            var entry: ApodTimelineEntry
            
            switch apodImageResponse {
            case .Failure:
                entry = ApodTimelineEntry(date: Date(), image: UIImage(named: "Error")!, text: "Connection Error", shouldShowText: true)
                policy = .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!)
                break
            case .Success(let image, let title):
                entry = ApodTimelineEntry(date: Date(), image: image, text: title, shouldShowText: configuration.ShouldShowText as? Bool ?? false)
                
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                let timeToReload = Calendar.current.date(bySettingHour: configuration.LoadAt?.hour ?? 0, minute: configuration.LoadAt?.minute ?? 0, second: configuration.LoadAt?.second ?? 0, of: tomorrow)!
                policy = .after(timeToReload)
                break
            }
            
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: policy)
            completion(timeline)
        }
    }
}

struct ApodTimelineEntry: TimelineEntry {
    let date: Date
    let image: UIImage
    var text: String = ""
    var shouldShowText: Bool = false
}

struct ApodWidgetEntryView : View {
    var entry: ApodTimelineProvider.Entry

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom){
                Image(uiImage: entry.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                if entry.shouldShowText {
                    Text(entry.text)
                        .font(.caption)
                        .foregroundColor(Color.black)
                        .padding(2)
                        .background(Color.white.opacity(0.4))
                        .cornerRadius(5)
                        .padding(.bottom, 3)
                        .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

@main
struct ApodWidget: Widget {
    let kind: String = "ApodWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ApodWidgetConfigurationIntent.self, provider: ApodTimelineProvider()) { entry in
            ApodWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Astronomy picture of the day")
        .description("This is a widget that shows the astronomy picture of the day.")
    }
}

struct ApodWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Date(), image: UIImage(named: "Test")!, text: "Sample Text"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Date(), image: UIImage(named: "Test")!, text: "Sample Text", shouldShowText: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Date(), image: UIImage(named: "Test")!, text: "Really Long Sample Text", shouldShowText: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Date(), image: UIImage(named: "Error")!, text: "Connection Error", shouldShowText: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
