import SwiftUI
import UIKit

// MARK: - Fireworks Background View
struct FireworksView: UIViewRepresentable {
	
	func makeUIView(context: Context) -> UIView {
		let host = FireworksHostView()
		host.backgroundColor = .clear
		return host
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {
		// Layout is handled in FireworksHostView.layoutSubviews
	}
}

// Custom UIView that handles its own emitter layer
class FireworksHostView: UIView {
	
	private var particlesLayer: CAEmitterLayer?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupEmitter()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupEmitter()
	}
	
	private func setupEmitter() {
		let emitterLayer = CAEmitterLayer()
		emitterLayer.emitterShape = .cuboid
		emitterLayer.emitterMode = .outline
		emitterLayer.renderMode = .additive
		emitterLayer.seed = UInt32(Date().timeIntervalSince1970)
		
		// Create spark image programmatically
		let sparkImage = createSparkImage()
		
		let cell1 = CAEmitterCell()
		cell1.name = "Parent"
		cell1.birthRate = 5.0
		cell1.lifetime = 2.5
		cell1.velocity = 300.0
		cell1.velocityRange = 100.0
		cell1.yAcceleration = -100.0
		cell1.emissionLongitude = -90.0 * (.pi / 180.0)
		cell1.emissionRange = 45.0 * (.pi / 180.0)
		cell1.scale = 0.0
		cell1.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
		cell1.redRange = 0.9
		cell1.greenRange = 0.9
		cell1.blueRange = 0.9
		
		let subcell1_1 = CAEmitterCell()
		subcell1_1.contents = sparkImage
		subcell1_1.name = "Trail"
		subcell1_1.birthRate = 45.0
		subcell1_1.lifetime = 0.5
		subcell1_1.beginTime = 0.01
		subcell1_1.duration = 1.7
		subcell1_1.velocity = 80.0
		subcell1_1.velocityRange = 100.0
		subcell1_1.xAcceleration = 100.0
		subcell1_1.yAcceleration = 350.0
		subcell1_1.emissionLongitude = -360.0 * (.pi / 180.0)
		subcell1_1.emissionRange = 22.5 * (.pi / 180.0)
		subcell1_1.scale = 0.5
		subcell1_1.scaleSpeed = 0.13
		subcell1_1.alphaSpeed = -0.7
		subcell1_1.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
		
		let subcell1_2 = CAEmitterCell()
		subcell1_2.contents = sparkImage
		subcell1_2.name = "Firework"
		subcell1_2.birthRate = 20000.0
		subcell1_2.lifetime = 15.0
		subcell1_2.beginTime = 1.6
		subcell1_2.duration = 0.1
		subcell1_2.velocity = 190.0
		subcell1_2.yAcceleration = 80.0
		subcell1_2.emissionRange = 360.0 * (.pi / 180.0)
		subcell1_2.spin = 114.6 * (.pi / 180.0)
		subcell1_2.scale = 0.1
		subcell1_2.scaleSpeed = 0.09
		subcell1_2.alphaSpeed = -0.7
		subcell1_2.color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).cgColor
		
		cell1.emitterCells = [subcell1_1, subcell1_2]
		emitterLayer.emitterCells = [cell1]
		
		layer.addSublayer(emitterLayer)
		self.particlesLayer = emitterLayer
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Update emitter frame and position when layout changes
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		particlesLayer?.frame = bounds
		particlesLayer?.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height - 50)
		particlesLayer?.emitterSize = CGSize(width: 0.0, height: 0.0)
		CATransaction.commit()
	}
	
	private func createSparkImage() -> CGImage? {
		let size: CGFloat = 32
		let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
		
		let image = renderer.image { context in
			let center = CGPoint(x: size / 2, y: size / 2)
			let colors = [
				UIColor.white.cgColor,
				UIColor.white.withAlphaComponent(0.8).cgColor,
				UIColor.white.withAlphaComponent(0.0).cgColor
			] as CFArray
			
			let locations: [CGFloat] = [0.0, 0.3, 1.0]
			
			if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations) {
				context.cgContext.drawRadialGradient(
					gradient,
					startCenter: center,
					startRadius: 0,
					endCenter: center,
					endRadius: size / 2,
					options: .drawsAfterEndLocation
				)
			}
		}
		
		return image.cgImage
	}
}
