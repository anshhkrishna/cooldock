import SwiftUI
import AppKit

// MARK: - Glass background

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow
    var blending: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = blending
        v.state = .active
        return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) {
        v.material = material
        v.blendingMode = blending
    }
}

// MARK: - Card chrome

struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            )
    }
}

// MARK: - Root dock

struct ContentView: View {
    @StateObject private var now = NowPlayingModel()

    var body: some View {
        VStack(spacing: 12) {
            header
            NowPlayingCard(model: now)
        }
        .padding(14)
        .frame(width: 300)
        .background(
            ZStack {
                VisualEffectView(material: .hudWindow)
                LinearGradient(colors: [Color.white.opacity(0.05), .clear],
                               startPoint: .top, endPoint: .bottom)
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .preferredColorScheme(.dark)
        .onAppear { now.start() }
    }

    private var header: some View {
        HStack {
            Image(systemName: "square.stack.3d.up.fill")
                .foregroundStyle(.white.opacity(0.85))
            Text("Cooldock")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            Circle().fill(.green.opacity(0.8)).frame(width: 7, height: 7)
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Now Playing

struct NowPlayingCard: View {
    @ObservedObject var model: NowPlayingModel

    var body: some View {
        Card {
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    artwork
                    VStack(alignment: .leading, spacing: 3) {
                        Text(model.title)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .foregroundStyle(.white)
                        Text(model.artist.isEmpty ? "—" : model.artist)
                            .font(.system(size: 11))
                            .lineLimit(1)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer(minLength: 0)
                }

                ProgressView(value: model.progress)
                    .progressViewStyle(.linear)
                    .tint(.white.opacity(0.8))
                    .scaleEffect(x: 1, y: 0.7, anchor: .center)

                HStack(spacing: 26) {
                    controlButton("backward.fill") { model.previous() }
                    controlButton(model.isPlaying ? "pause.fill" : "play.fill", size: 20) { model.togglePlay() }
                    controlButton("forward.fill") { model.next() }
                }
                .foregroundStyle(.white.opacity(model.isActive ? 0.9 : 0.35))
                .disabled(!model.isActive)
            }
        }
    }

    private var artwork: some View {
        Group {
            if let art = model.artwork {
                Image(nsImage: art).resizable().scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "music.note").foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func controlButton(_ symbol: String, size: CGFloat = 15, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: size, weight: .medium))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pomodoro

struct PomodoroCard: View {
    @ObservedObject var model: PomodoroModel

    var body: some View {
        Card {
            VStack(spacing: 12) {
                HStack {
                    Text(model.mode.label.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(model.mode == .focus ? .orange : .green)
                    Spacer()
                    Text("\(model.completedSessions) done")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.5))
                }

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: model.progress)
                        .stroke(model.mode == .focus ? Color.orange : Color.green,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.3), value: model.progress)
                    Text(model.timeString)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                .frame(width: 120, height: 120)

                HStack(spacing: 12) {
                    pillButton(model.running ? "Pause" : "Start", filled: true) { model.toggle() }
                    pillButton("Reset") { model.reset() }
                    pillButton("Skip") { model.skip() }
                }
            }
        }
    }

    private func pillButton(_ title: String, filled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .fill(filled ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
                )
                .foregroundStyle(.white.opacity(0.9))
        }
        .buttonStyle(.plain)
    }
}
