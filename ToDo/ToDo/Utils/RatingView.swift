//
//  RatingView.swift
//  ReadList
//
//  Created by LQ on 2024/12/7.
//

import SwiftUI

public enum StarRounding: Int {
    case roundToHalfStar = 0
    case ceilToHalfStar = 1
    case floorToHalfStar = 2
    case roundToFullStar = 3
    case ceilToFullStar = 4
    case floorToFullStar = 5
}

struct StarView: View {
    let isFilled: Bool
    let color: Color
    
    private let fullStarImage: Image = Image(systemName: "star.fill")
    private let halfStarImage: Image = Image(systemName: "star.lefthalf.fill")
    private let emptyStarImage: Image = Image(systemName: "star")
    
    var body: some View {
        isFilled ? fullStarImage : emptyStarImage
    }
}

struct RatingView: View {
    let maxRating: Int
    let rating: Binding<Int>
    let starColor: Color
    let starRounding: StarRounding
    let size: CGFloat
    let spacing: CGFloat
    var onChange: ((Int)->())? = nil
    
    private let fullStarImage: Image = Image(systemName: "star.fill")
    private let halfStarImage: Image = Image(systemName: "star.lefthalf.fill")
    private let emptyStarImage: Image = Image(systemName: "star")
    
    @State private var selectedStar: Int?
    
    init(maxRating: Int, rating: Binding<Int>, starColor: Color = .blue, starRounding: StarRounding = .floorToFullStar, size: CGFloat = 20, spacing: CGFloat = 5, onChange: ((Int)->())? = nil) {
        self.maxRating = maxRating
        self.rating = rating
        self.starColor = starColor
        self.starRounding = starRounding
        self.size = size
        self.spacing = spacing
        self.onChange = onChange
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...maxRating, id: \.self) { index in
                starImageView(index: index)
                    .foregroundColor(starColor)
                    .onTapGesture {
                        self.onChange?(index)
                        rating.wrappedValue = index
                        withAnimation(.easeInOut(duration: 0.5)) {
                            selectedStar = index
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            selectedStar = nil
                        }
                    }
            }
        }
    }
    
    func starImageView(index: Int) -> some View {
        let iFloat = index
        let image: Image
        switch starRounding {
        case .roundToHalfStar:
            image = rating.wrappedValue >= iFloat ? fullStarImage : emptyStarImage
        case .ceilToHalfStar:
            image = rating.wrappedValue > iFloat ? fullStarImage : emptyStarImage
        case .floorToHalfStar:
            image = rating.wrappedValue >= iFloat ? fullStarImage :emptyStarImage
        case .roundToFullStar:
            image = rating.wrappedValue >= iFloat ? fullStarImage : emptyStarImage
        case .ceilToFullStar:
            image = rating.wrappedValue > iFloat ? fullStarImage : emptyStarImage
        case .floorToFullStar:
            image = rating.wrappedValue >= iFloat ? fullStarImage : emptyStarImage
        }
        return image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .overlay(
                selectedStar == index ? Circle()
                    .strokeBorder(starColor, lineWidth: 4)
                    .scaleEffect(1.5)
                    .opacity(0)
                    .animation(Animation.easeInOut(duration: 1)
                        .repeatForever(autoreverses: false), value: 1) : nil
            )
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RatingView(maxRating: 5, rating: .constant(3), size: 12, spacing: 2.5)
                .previewLayout(.sizeThatFits)
            
            RatingView(maxRating: 10, rating: .constant(8), starColor: .yellow, starRounding: .ceilToHalfStar, size: 30)
                .previewLayout(.sizeThatFits)
            
            RatingView(maxRating: 3, rating: .constant(2), starColor: .green, starRounding: .roundToFullStar, size: 50)
                .previewLayout(.sizeThatFits)
        }
    }
}


