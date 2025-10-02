import SwiftUI

struct SongDetailView: View {
    @ObservedObject var songVM: SongViewModel
    let song: Song
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [.black, .gray.opacity(0.8)], center: .center, startRadius: 100, endRadius: 150))
                        .frame(width: 300, height: 300)
                        .shadow(radius: 20)
                    
                    ForEach(0..<5) { i in
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .frame(width: CGFloat(250 - i * 30), height: CGFloat(250 - i * 30))
                    }
                    
                    Image(song.coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                    
                    Circle()
                        .fill(.white)
                        .frame(width: 20, height: 20)
                }
                .rotationEffect(.degrees(rotation))
                .onChange(of: songVM.isPlaying && songVM.currentSongID == song.id) { playing in
                    withAnimation(playing ? .linear(duration: 8).repeatForever(autoreverses: false) : .linear(duration: 0.5)) {
                        rotation = playing ? rotation + 360 : 0
                    }
                }
                
                VStack(spacing: 8) {
                    Text(song.title).font(.title).bold()
                    Text(song.artist).font(.title3).foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    ProgressView(value: songVM.currentTime, total: songVM.duration).tint(.white)
                    HStack {
                        Text(timeString(songVM.currentTime)).font(.caption).foregroundColor(.secondary)
                        Spacer()
                        Text(timeString(songVM.duration)).font(.caption).foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 40)
                
                HStack(spacing: 60) {
                    Button { songVM.previousSong() } label: {
                        Image(systemName: "backward.fill").font(.title)
                    }
                    
                    Button {
                        songVM.currentSongID == song.id && songVM.isPlaying ? songVM.pauseSong() : songVM.playSong(song)
                    } label: {
                        ZStack {
                            Circle().fill(.white).frame(width: 70, height: 70).shadow(radius: 5)
                            Image(systemName: songVM.currentSongID == song.id && songVM.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title).foregroundColor(.black)
                        }
                    }
                    
                    Button { songVM.nextSong() } label: {
                        Image(systemName: "forward.fill").font(.title)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            if songVM.currentSongID != song.id {
                songVM.playSong(song)
            }
        }
    }
    
    func timeString(_ time: TimeInterval) -> String {
        String(format: "%d:%02d", Int(time) / 60, Int(time) % 60)
    }
}
