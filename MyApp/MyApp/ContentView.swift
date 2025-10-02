import SwiftUI

struct ContentView: View {
    @StateObject private var songVM = SongViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(songVM.songs) { song in
                    NavigationLink(destination: SongDetailView(songVM: songVM, song: song)) {
                        HStack(spacing: 12) {
                            Image(song.coverImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(song.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text(song.artist)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if songVM.currentSongID == song.id && songVM.isPlaying {
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Mi Música")
        }
    }
}

#Preview {
    ContentView()
}
