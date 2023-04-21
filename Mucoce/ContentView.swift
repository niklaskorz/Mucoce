//
//  ContentView.swift
//  Mucoce
//
//  Created by Niklas Korz on 21.04.23.
//

import SwiftUI
import ScriptingBridge
import Foundation

let bg = Color(NSColor(calibratedWhite: 0.15, alpha: 1.0))
let fg = Color.white
let shadowColor: Color = Color(NSColor(calibratedWhite: 0.0, alpha: 0.5))
let progressBg = Color(NSColor(calibratedWhite: 0.12, alpha: 1.0))
let progressFg = Color(NSColor(calibratedWhite: 0.9, alpha: 1.0))
let btnBg = Color(NSColor(calibratedWhite: 0.2, alpha: 0.8))
let btnBgPressed = Color(NSColor(calibratedWhite: 0.15, alpha: 0.8))
let btnFg = Color(NSColor(calibratedWhite: 1.0, alpha: 1.0))
let borderTop = Color(NSColor(calibratedWhite: 0.1, alpha: 1.0))
let borderBottom = Color(NSColor(calibratedWhite: 1.0, alpha: 0.05))

struct ContentView: View {
    @State var music: MusicApplication? = SBApplication(bundleIdentifier: "com.apple.Music")
    @State var hovered = false
    @State var image: NSImage?
    @State var title: String?
    @State var artist: String?
    @State var playing: Bool = false
    @State var progress: Double = 0.0
    @State var duration: Double = 1.0
    
    let pub = DistributedNotificationCenter.default().publisher(for: Notification.Name("com.apple.Music.playerInfo"))
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 250, height: 250)
                    .overlay(HStack {
                        Button("Previous") {
                            music?.backTrack?()
                        }
                        .buttonStyle(PrevButtonStyle())
                        if playing {
                            Button("Pause") {
                                music?.playpause?()
                            }
                            .buttonStyle(PauseButtonStyle())
                        } else {
                            Button("Play") {
                                music?.playpause?()
                            }
                            .buttonStyle(PlayButtonStyle())
                        }
                        Button("Next") {
                            music?.nextTrack?()
                        }
                        .buttonStyle(NextButtonStyle())
                    }
                    .opacity(hovered ? 1 : 0)
                    .animation(.easeOut(duration: 0.2), value: hovered))
            }
            // Progress bar
            /*Rectangle()
                .foregroundColor(progressBg)
                .frame(width: 250, height: 3)
                .overlay(
                    GeometryReader { metrics in
                        Rectangle()
                            .foregroundColor(progressFg)
                            .frame(
                                width: CGFloat(progress / duration) * metrics.size.width,
                                height: 3
                            )
                    }
                )*/
            Rectangle()
                .fill(borderTop)
                .frame(width: 250, height: 1)
            Rectangle()
                .fill(borderBottom)
                .frame(width: 250, height: 1)
            VStack(alignment: .leading) {
                Text(title ?? "Nothing playing")
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .truncationMode(.tail)
                    .frame(width: 230, alignment: .leading)
                    .shadow(color: shadowColor, radius: 1, y: 1)
                Text(artist ?? "")
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .allowsTightening(true)
                    .truncationMode(.tail)
                    .frame(width: 230, alignment: .leading)
                    .shadow(color: shadowColor, radius: 1, y: 1)
            }.padding(EdgeInsets(
                top: 5,
                leading: 10,
                bottom: 10,
                trailing: 10
            ))
        }
        .background(bg)
        .foregroundColor(fg)
        .onHover { hover in
            self.hovered = hover
        }
        .onAppear {
            self.update()
        }
        .onReceive(pub) { event in
            self.update()
        }
    }
    
    func update() {
        music = SBApplication(bundleIdentifier: "com.apple.Music")
        guard let music = music else {
            return
        }
        if let track = music.currentTrack {
            if let artwork = track.artworks?().firstObject as? MusicArtwork {
                image = artwork.data
            }
            title = track.name
            artist = track.artist
            duration = track.duration ?? 1.0
        }
        playing = music.playerState == .playing
        progress = music.playerPosition ?? 0.0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PauseButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        var bg = btnBg
        if configuration.isPressed {
            bg = btnBgPressed
        }
        return ZStack {
            Circle().fill(bg)
            Circle()
                .stroke(btnFg, lineWidth: 2)
            HStack(spacing: 6) {
                Rectangle()
                    .foregroundColor(btnFg)
                    .frame(width: 8, height: 30)
                Rectangle()
                    .foregroundColor(btnFg)
                    .frame(width: 8, height: 30)
            }
        }
        .frame(width: 60, height: 60)
        
        /*return configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)*/
    }
}

let playBtnPath = {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 30 - 12, y: 30 + 15))
    path.addLine(to: CGPoint(x: 30 + 19, y: 30))
    path.addLine(to: CGPoint(x: 30 - 12, y: 30 - 15))
    path.closeSubpath()
    return path
}()

struct PlayButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        var bg = btnBg
        if configuration.isPressed {
            bg = btnBgPressed
        }
        
        return ZStack {
            Circle().fill(bg)
            Circle()
                .stroke(btnFg, lineWidth: 2)
            Path(playBtnPath).fill(btnFg)
        }.frame(width: 60, height: 60)
    }
}

let prevBtnPath = {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 20 + 10, y: 20 + 7.5))
    path.addLine(to: CGPoint(x: 20 - 3, y: 20))
    path.addLine(to: CGPoint(x: 20 + 10, y: 20 - 7.5))
    path.closeSubpath()
    path.move(to: CGPoint(x: 20 - 2, y: 20 + 7.5))
    path.addLine(to: CGPoint(x: 20 - 15, y: 20))
    path.addLine(to: CGPoint(x: 20 - 2, y: 20 - 7.5))
    path.closeSubpath()
    return path
}()

struct PrevButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        var bg = btnBg
        if configuration.isPressed {
            bg = btnBgPressed
        }
        
        return ZStack {
            Circle().fill(bg)
            Circle()
                .stroke(btnFg, lineWidth: 2)
            Path(prevBtnPath).fill(btnFg)
        }.frame(width: 40, height: 40)
    }
}

let nextBtnPath = {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 20 - 10, y: 20 + 7.5))
    path.addLine(to: CGPoint(x: 20 + 3, y: 20))
    path.addLine(to: CGPoint(x: 20 - 10, y: 20 - 7.5))
    path.closeSubpath()
    path.move(to: CGPoint(x: 20 + 2, y: 20 + 7.5))
    path.addLine(to: CGPoint(x: 20 + 15, y: 20))
    path.addLine(to: CGPoint(x: 20 + 2, y: 20 - 7.5))
    path.closeSubpath()
    return path
}()

struct NextButtonStyle: ButtonStyle
{
    func makeBody(configuration: Configuration) -> some View
    {
        var bg = btnBg
        if configuration.isPressed {
            bg = btnBgPressed
        }
        
        return ZStack {
            Circle().fill(bg)
            Circle()
                .stroke(btnFg, lineWidth: 2)
            Path(nextBtnPath).fill(btnFg)
        }.frame(width: 40, height: 40)
    }
}
