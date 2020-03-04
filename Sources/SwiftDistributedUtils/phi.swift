import Foundation

public class PhiAccrualDetector {

    private let threshold: Double
    private let jitterMs: Double
    private let history: HeartbeatHistory
    private var lastTimestamp: Double = -1

    init(threshold: Double, jitterMs: Double = 200) {
        self.threshold = threshold
        self.jitterMs = jitterMs
        self.history = HeartbeatHistory()
    }

    func heartbeat() {
        let currentTimestamp = PhiAccrualDetector.timeNow()
        if lastTimestamp != -1 {
            let interval = currentTimestamp - lastTimestamp
            if isAvailable(currentTimestamp) {
                history.recordHeartbeat(interval)
            }
        }
        lastTimestamp = currentTimestamp
    }
    
    func isAvailable() -> Bool {
        return isAvailable(PhiAccrualDetector.timeNow())
    }
    
    func phi() -> Double {
        return phi(PhiAccrualDetector.timeNow())
    }

    private func isAvailable(_ currentTimestamp: Double) -> Bool {
        let phiValue = phi(currentTimestamp)
        if phiValue.isNaN {
            return true
        }
        return phiValue < threshold
    }

    private func phi(_ currentTimestamp: Double) -> Double {
        if lastTimestamp == -1 {
            return 0.0
        }
        
        let interval = currentTimestamp - lastTimestamp
        let meanIntervalMs = history.mean() + jitterMs
        let stdDeviationMs = max(history.stdDeviation(), 3.0)
        
        let y = (interval - meanIntervalMs) / stdDeviationMs
        let e = exp(-y * (1.5976 + 0.070566 * y * y))
        
        if interval > meanIntervalMs {
            return -log10(e / (1.0 + e))
        } else {
            return -log10(1.0 - 1.0 / (1.0 + e))
        }
    }

    private static func timeNow() -> Double {
        Date().timeIntervalSince1970 * 1000
    }

    fileprivate class HeartbeatHistory {

        let maxSampleSize: Int
        var intervals: [Double]
        var sum: Double = 0
        var intervalSum: Double = 0

        init() {
            self.maxSampleSize = 200
            self.intervals = Array()
        }

        func recordHeartbeat(_ interval: Double) {
            if intervals.count >= maxSampleSize {
                let dropped = intervals.dropFirst().first!
                sum -= dropped
            }
            intervals.append(interval)
            intervalSum += interval
        }

        func mean() -> Double {
            return sum / Double(intervals.count)
        }

        func variance() -> Double {
            return (pow(2, intervalSum) / Double(intervals.count)) - pow(2, mean())
        }

        func stdDeviation() -> Double {
            return variance().squareRoot()
        }
    }
}
