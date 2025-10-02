import Foundation
import AVFoundation
import SwiftUI

class SongViewModel: ObservableObject {
    @Published var songs = [Song]()
    @Published var currentSongID: UUID?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    init() {
        songs = load("songs.json")
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    func load<T: Decodable>(_ filename: String) -> T {
        let file = Bundle.main.url(forResource: filename, withExtension: nil)!
        let data = try! Data(contentsOf: file)
        return try! JSONDecoder().decode(T.self, from: data)
    }
    
    func playSong(_ song: Song) {
        if currentSongID == song.id && player != nil {
            player?.play()
            isPlaying = true
            startTimer()
            return
        }
        
        // Check if URL is remote (http/https)
        if song.audioURL.hasPrefix("http") {
            guard let url = URL(string: song.audioURL) else { return }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    self?.player = try? AVAudioPlayer(data: data)
                    self?.player?.play()
                    self?.currentSongID = song.id
                    self?.isPlaying = true
                    self?.duration = self?.player?.duration ?? 0
                    self?.startTimer()
                }
            }.resume()
        } else {
            // Local file
            let name = song.audioURL.replacingOccurrences(of: ".mp3", with: "")
            guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { return }
            
            player = try? AVAudioPlayer(contentsOf: url)
            player?.play()
            currentSongID = song.id
            isPlaying = true
            duration = player?.duration ?? 0
            startTimer()
        }
    }
    
    func pauseSong() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func nextSong() {
        guard let currentID = currentSongID,
              let index = songs.firstIndex(where: { $0.id == currentID }) else { return }
        playSong(songs[(index + 1) % songs.count])
    }
    
    func previousSong() {
        guard let currentID = currentSongID,
              let index = songs.firstIndex(where: { $0.id == currentID }) else { return }
        playSong(songs[index == 0 ? songs.count - 1 : index - 1])
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.currentTime = self?.player?.currentTime ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
