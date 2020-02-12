import Foundation

print("Hello, world!")

let phi = PhiAccrualDetector(threshold: 3.0)

phi.heartbeat()
phi.heartbeat()
phi.heartbeat()

print("\(phi.isAvailable())")

sleep(2)

print("\(phi.isAvailable())")
