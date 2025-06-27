//
//  EdgeProgressBar.swift
//  Pomodoro
//
//  Created by Keven Diaz on 6/27/25.
//

import SwiftUI

struct EdgeProgressShape: Shape {
    var progress: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let insetRect = rect.insetBy(dx: 10, dy: 10)
        let width = insetRect.width
        let height = insetRect.height

        let topLeft = CGPoint(x: insetRect.minX, y: insetRect.minY)
        let topRight = CGPoint(x: insetRect.maxX, y: insetRect.minY)
        let bottomRight = CGPoint(x: insetRect.maxX, y: insetRect.maxY)
        let bottomLeft = CGPoint(x: insetRect.minX, y: insetRect.maxY)
        let topCenter = CGPoint(x: insetRect.midX, y: insetRect.minY)

        let perimeter = 2 * (width + height)
        let targetLength = perimeter * progress

        var currentLength: CGFloat = 0

        path.move(to: topCenter)

        let topRightLength = width / 2
        if currentLength + topRightLength >= targetLength {
            path.addLine(to: CGPoint(x: topCenter.x + (targetLength - currentLength), y: insetRect.minY))
            return path
        }
        path.addLine(to: topRight)
        currentLength += topRightLength

        if currentLength + height >= targetLength {
            path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.minY + (targetLength - currentLength)))
            return path
        }
        path.addLine(to: bottomRight)
        currentLength += height

        if currentLength + width >= targetLength {
            path.addLine(to: CGPoint(x: insetRect.maxX - (targetLength - currentLength), y: insetRect.maxY))
            return path
        }
        path.addLine(to: bottomLeft)
        currentLength += width

        if currentLength + height >= targetLength {
            path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.maxY - (targetLength - currentLength)))
            return path
        }
        path.addLine(to: topLeft)
        currentLength += height

        let topLeftToCenterLength = width / 2
        if currentLength + topLeftToCenterLength >= targetLength {
            path.addLine(to: CGPoint(x: topLeft.x + (targetLength - currentLength), y: insetRect.minY))
            return path
        }
        path.addLine(to: topCenter)

        return path
    }

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
}
