//
//  PaymentCardView.swift
//  CardFlow
//


import SwiftUI

struct PaymentCardView: View {

    let card: Card

    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(background)
            .frame(height: 220)
            .overlay {
                decoration
            }
            .overlay {
                cardContent
            }
            .clipShape(.rect(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        card.design == .pearl ? .black.opacity(0.08) : .white.opacity(0.16),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.16), radius: 10, y: 6)
            .contentShape(.rect)
    }

    private var background: AnyShapeStyle {
        switch card.design {
        case .apex:
            AnyShapeStyle(Color(red: 0.08, green: 0.08, blue: 0.09))
        case .vertex:
            AnyShapeStyle(Color(red: 0.06, green: 0.05, blue: 0.08))
        case .flux:
            AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.90, green: 0.00, blue: 0.55),
                        Color(red: 0.98, green: 0.20, blue: 0.67),
                        Color(red: 0.42, green: 0.36, blue: 0.95),
                        Color(red: 0.02, green: 0.31, blue: 0.94)
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            )
        case .pearl:
            AnyShapeStyle(
                LinearGradient(
                    colors: [.white, Color(white: 0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .split:
            AnyShapeStyle(
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.12, green: 0.03, blue: 0.17), location: 0),
                        .init(color: Color(red: 0.12, green: 0.03, blue: 0.17), location: 0.49),
                        .init(color: Color(red: 0.57, green: 0.44, blue: 0.94), location: 0.51),
                        .init(color: Color(red: 0.67, green: 0.54, blue: 0.98), location: 1)
                    ],
                    startPoint: UnitPoint(x: 0.42, y: 0),
                    endPoint: UnitPoint(x: 0.58, y: 1)
                )
            )
        case .nova:
            AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.01, green: 0.03, blue: 0.16),
                        Color(red: 0.04, green: 0.06, blue: 0.48),
                        Color(red: 0.12, green: 0.12, blue: 0.82)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }

    @ViewBuilder
    private var decoration: some View {
        switch card.design {
        case .apex:
            ZStack {
                ForEach(0..<16, id: \.self) { index in
                    Circle()
                        .stroke(.white.opacity(0.26), lineWidth: 1)
                        .frame(
                            width: CGFloat(42 + index * 22),
                            height: CGFloat(42 + index * 22)
                        )
                }
            }
            .offset(x: -155, y: -108)

        case .flux:
            RadialGradient(
                colors: [.white.opacity(0.30), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 150
            )
            .offset(x: -30, y: 40)

        case .pearl:
            LinearGradient(
                colors: [.white.opacity(0.8), .clear, .black.opacity(0.025)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .vertex:
            RoundedRectangle(cornerRadius: 70, style: .continuous)
                .fill(.black.opacity(0.78))
                .frame(width: 460, height: 130)
                .offset(x: 60, y: 100)

        case .split:
            LinearGradient(
                colors: [.white.opacity(0.06), .clear],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

        case .nova:
            Circle()
                .stroke(.black.opacity(0.38), lineWidth: 30)
                .frame(width: 260, height: 260)
                .offset(x: 150, y: 92)
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        switch card.design {
        case .apex:
            ZStack {
                HStack(spacing: 7) {
                    Text("apex")
                        .font(.title2.weight(.semibold))
                    Image(systemName: "triangle.fill")
                        .font(.headline)
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)

                HStack {
                    Spacer()
                    cardChip()
                }
            }
            .foregroundStyle(.white)
            .padding(20)

        case .flux:
            ZStack {
                HStack(alignment: .top) {
                    Text("Flux")
                        .font(.title.weight(.bold))
                    Spacer()
                    Text("CREDIT")
                        .font(.caption2.weight(.bold))
                        .tracking(0.6)
                }
                .frame(maxHeight: .infinity, alignment: .top)

                HStack {
                    Spacer()
                    cardChip()
                }
            }
            .foregroundStyle(.white)
            .padding(20)

        case .pearl:
            ZStack {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 30, weight: .medium))
                    Text("Pearl")
                        .font(.title2.weight(.semibold))
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)

                HStack {
                    Spacer()
                    cardChip(tint: Color(white: 0.86))
                }
            }
            .foregroundStyle(.black.opacity(0.55))
            .padding(20)

        case .vertex:
            ZStack {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "rectangle.2.swap")
                        .font(.title2.weight(.bold))
                    Text("Vertex")
                        .font(.title.weight(.semibold))
                }
                .frame(maxHeight: .infinity, alignment: .top)

                HStack {
                    cardChip(tint: Color(white: 0.46))
                    Spacer()
                }

                HStack {
                    Spacer()
                    networkMark
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .foregroundStyle(.white)
            .padding(20)

        case .split:
            ZStack {
                HStack {
                    Text("SPLIT")
                        .font(.largeTitle.weight(.black))
                        .italic()
                    Spacer()
                }
                .frame(maxHeight: .infinity, alignment: .top)

                HStack {
                    cardChip(tint: Color(white: 0.86))
                    Spacer()
                }

                HStack {
                    Spacer()
                    Text("FLOW")
                        .font(.title.weight(.black))
                        .italic()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .foregroundStyle(.white)
            .padding(20)

        case .nova:
            ZStack {
                HStack {
                    cardChip(tint: Color(white: 0.68))
                    Spacer()
                }

                HStack {
                    Spacer()
                    Text("nova")
                        .font(.title2.weight(.medium))
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .foregroundStyle(.white)
            .padding(20)
        }
    }

    private func cardChip(tint: Color = Color(white: 0.78)) -> some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [tint.opacity(0.72), tint, .white.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 50, height: 38)
            .overlay {
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(.black.opacity(0.22), lineWidth: 1)
            }
            .overlay {
                VStack(spacing: 6) {
                    Divider()
                    Divider()
                }
            }
    }

    private var networkMark: some View {
        ZStack {
            Circle()
                .fill(Color(white: 0.38))
                .offset(x: -9)
            Circle()
                .fill(Color(white: 0.78))
                .offset(x: 9)
        }
        .frame(width: 48, height: 30)
    }
}
