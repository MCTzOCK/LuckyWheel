//
//  FortuneWheelView.swift
//  LuckyWheel
//
//  Created by Ben Siebert on 28.03.26.
//

import SwiftUI

struct FortuneWheelView: View {
    @Binding var items: [String]
    let onResult: (String) -> Void
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedItem: String? = nil
    
    // Farben für die Segmente (zyklisch wiederholt)
    private let segmentColors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .mint, .teal, .indigo
    ]
    
    private var segmentAngle: Double {
        360.0 / Double(items.count)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            
            // MARK: Das Rad
            ZStack {
                // Die Segmente
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    WheelSegment(
                        index: index,
                        totalSegments: items.count,
                        text: item,
                        color: segmentColors[index % segmentColors.count]
                    )
                }
                
                // Mittelpunkt
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, Color(UIColor.systemGray5)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.2), radius: 5)
                
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .frame(width: 300, height: 300)
            .rotationEffect(.degrees(rotation))
            
            // MARK: Der Zeiger (oben)
            .overlay(alignment: .top) {
                Triangle()
                    .fill(Color.accentColor)
                    .frame(width: 30, height: 40)
                    .shadow(color: .black.opacity(0.3), radius: 3, y: 2)
                    .offset(y: -10)
            }
            
            // MARK: Ergebnis-Anzeige
            if let result = selectedItem {
                VStack(spacing: 8) {
                    Text("Selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(result)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.secondarySystemFill))
                        .cornerRadius(12)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // MARK: Spin Button
            Button {
                spin()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                        .font(.headline)
                    Text("Spin!")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    isSpinning
                    ? LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom)
                    : LinearGradient(colors: [.accentColor, .accentColor.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(30)
                .shadow(color: isSpinning ? .clear : .accentColor.opacity(0.4), radius: 10, y: 5)
            }
            .disabled(isSpinning || items.isEmpty)
            .scaleEffect(isSpinning ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isSpinning)
        }
        .padding()
    }
    
    // MARK: - Spin Logic
    private func spin() {
        guard !items.isEmpty else { return }
        
        isSpinning = true
        selectedItem = nil
        
        // 1. Zufälliges Segment auswählen
        let randomIndex = Int.random(in: 0..<items.count)
        
        // 2. Berechne, welcher Winkel das Segment unter den Zeiger (oben = 0°) bringt
        //    Segmente starten bei 0° (rechts) und laufen im Uhrzeigersinn.
        //    Da der Zeiger OBEN steht, muss die Mitte des Segments bei 270° (= -90°) landen.
        let segmentMidAngle = Double(randomIndex) * segmentAngle + (segmentAngle / 2.0)
        
        // 3. Normalisiere die aktuelle Rotation (damit wir nicht in riesigen Zahlen rechnen)
        let currentNormalized = rotation.truncatingRemainder(dividingBy: 360.0)
        
        // 4. Berechne, wie viel wir drehen müssen, damit segmentMidAngle oben (bei 0°) steht
        //    Das Rad dreht sich vorwärts (positive Richtung), also muss das Segment
        //    "rückwärts" zum Zeiger wandern: targetOffset = 360 - segmentMidAngle
        let targetOffset = 360.0 - segmentMidAngle
        
        // 5. Berechne die Differenz zur aktuellen Position
        var delta = targetOffset - currentNormalized
        if delta < 0 { delta += 360.0 }
        
        // 6. Füge volle Umdrehungen hinzu (mindestens 5 für den Show-Effekt)
        let fullSpins = Double(Int.random(in: 5...8)) * 360.0
        let totalRotation = fullSpins + delta
        
        // Haptisches Feedback
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        // 7. Animation starten
        withAnimation(
            .timingCurve(0.15, 0.85, 0.25, 1.0, duration: 4.0)
        ) {
            rotation += totalRotation
        }
        
        // 8. Nach der Animation: Ergebnis anzeigen
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            isSpinning = false
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                selectedItem = items[randomIndex]
            }
            
            onResult(items[randomIndex])
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        tickDuringRotation()
    }
    
    
    // MARK: - Tick-Haptik während des Drehens
    private func tickDuringRotation() {
        let tickGenerator = UIImpactFeedbackGenerator(style: .light)
        
        // Schnelle Ticks am Anfang, dann langsamer
        let tickIntervals: [Double] = [0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.7, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]
        
        for interval in tickIntervals {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                if isSpinning {
                    tickGenerator.impactOccurred()
                }
            }
        }
    }
}

// MARK: - Einzelnes Segment
struct WheelSegment: View {
    let index: Int
    let totalSegments: Int
    let text: String
    let color: Color
    
    private var startAngle: Double {
        Double(index) * (360.0 / Double(totalSegments))
    }
    
    private var endAngle: Double {
        startAngle + (360.0 / Double(totalSegments))
    }
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2
            
            ZStack {
                // Pie Segment
                Path { path in
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle - 90),
                        endAngle: .degrees(endAngle - 90),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .fill(color.gradient)
                
                // Segment-Rand
                Path { path in
                    path.move(to: center)
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle - 90),
                        endAngle: .degrees(endAngle - 90),
                        clockwise: false
                    )
                    path.closeSubpath()
                }
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                
                // Text im Segment
                let midAngle = (startAngle + endAngle) / 2 - 90
                let textRadius = radius * 0.65
                let textX = center.x + textRadius * cos(midAngle * .pi / 180)
                let textY = center.y + textRadius * sin(midAngle * .pi / 180)
                
                Text(text)
                    .font(.system(size: dynamicFontSize, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    .rotationEffect(.degrees(midAngle + 90))
                    .position(x: textX, y: textY)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
    
    private var dynamicFontSize: CGFloat {
        // Kleinere Schrift bei mehr Segmenten
        switch totalSegments {
        case 1...4: return 16
        case 5...6: return 14
        case 7...8: return 12
        default: return 10
        }
    }
}

// MARK: - Dreiecks-Form für den Zeiger
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
