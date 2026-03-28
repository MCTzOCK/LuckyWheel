//
//  PremiumWheelConfigView.swift
//  LuckyWheel
//
//  Created by Ben Siebert on 28.03.26.
//
import SwiftUI

struct PremiumWheelConfigView: View {
    @Binding var items: [String]
    @State private var newItemText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        // 1. Base List with hidden background
        List {
            // Top spacing so the first item doesn't hug the navigation bar
            Color.clear.frame(height: 8)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            ForEach(items.indices, id: \.self) { index in
                WheelItemCard(text: Binding(
                    get: { items.indices.contains(index) ? items[index] : "" },
                    set: { if items.indices.contains(index) { items[index] = $0 } }
                ), index: index)
                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // FIXED: Removed the blur. Softened the scale and opacity.
                // Keeps the 3D depth effect without making text unreadable.
                .scrollTransition(.interactive, axis: .vertical) { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1.0 : 0.92)
                        .opacity(phase.isIdentity ? 1.0 : 0.7)
                        .rotation3DEffect(
                            .degrees(phase.value * -10),
                            axis: (x: 1, y: 0, z: 0)
                        )
                }
            }
            .onDelete(perform: deleteItems)
            .onMove(perform: moveItems)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        
        // 2. Animated Background
        .background {
            LinearGradient(
                colors: [Color.purple.opacity(0.15), Color.blue.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
        
        // FIXED: Using safeAreaInset instead of a ZStack.
        // This pins the bar to the bottom, moves it UP automatically with the keyboard,
        // and adds padding to the bottom of the List so the last item is never covered.
        .safeAreaInset(edge: .bottom) {
            floatingInputBar
                .padding(.bottom, 8)
        }
        
        .navigationTitle("Wheel Segments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sensoryFeedback(.success, trigger: items.count)
    }
    
    // MARK: - Floating Input Bar
    private var floatingInputBar: some View {
        HStack(spacing: 12) {
            TextField("Add new segment...", text: $newItemText)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(addItem)
            
            Button(action: addItem) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white, .blue)
                    .rotationEffect(.degrees(newItemText.isEmpty ? -45 : 0))
                    .scaleEffect(newItemText.isEmpty ? 0.8 : 1.0)
                    .opacity(newItemText.isEmpty ? 0.5 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: newItemText.isEmpty)
            }
            .disabled(newItemText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        // Using a cleaner material background implementation
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Actions
    private func addItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            items.append(trimmed)
            newItemText = ""
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        withAnimation { items.remove(atOffsets: offsets) }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation { items.move(fromOffsets: source, toOffset: destination) }
    }
}

// MARK: - Item Card Component
struct WheelItemCard: View {
    @Binding var text: String
    let index: Int
    
    let colors: [Color] = [.pink, .purple, .blue, .teal, .green, .orange, .red]
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(colors[index % colors.count].gradient)
                .frame(width: 12, height: 12)
                .shadow(color: colors[index % colors.count].opacity(0.4), radius: 4)
            
            TextField("Segment", text: $text)
                .font(.system(.body, design: .rounded, weight: .medium))
            
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                )
        }
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
