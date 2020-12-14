//
//  ApodWidget.swift
//  ApodWidget
//
//  Created by SchwiftyUI on 12/7/20.
//

import WidgetKit
import SwiftUI
import Intents

struct ApodTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ApodTimelineEntry {
        ApodTimelineEntry(date: Date(), image: UIImage(named: "Placeholder")!)
    }

    func getSnapshot(in context: Context, completion: @escaping (ApodTimelineEntry) -> ()) {
        let entry = ApodTimelineEntry(date: Date(), image: UIImage(named: "Placeholder")!)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        ApodImageProvider.getImageFromApi() { apodImageResponse in
            var entries: [ApodTimelineEntry] = []
            var policy: TimelineReloadPolicy
            var entry: ApodTimelineEntry
            
            switch apodImageResponse {
            case .Failure:
                entry = ApodTimelineEntry(date: Date(), image: UIImage(named: "Error")!, text: "Connection Error")
                policy = .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!)
                break
            case .Success(let image):
                entry = ApodTimelineEntry(date: Date(), image: image)
                policy = .after(Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
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
                
                Text(entry.text)
            }
        }
    }
}

@main
struct ApodWidget: Widget {
    let kind: String = "ApodWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ApodTimelineProvider()) { entry in
            ApodWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Astronomy picture of the day")
        .description("This is a widget that shows the astronomy picture of the day.")
    }
}

struct ApodWidget_Previews: PreviewProvider {
    static var previews: some View {
        ApodWidgetEntryView(entry: ApodTimelineEntry(date: Date(), image: UIImage(named: "Test")!))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
