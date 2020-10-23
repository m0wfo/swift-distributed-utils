import Foundation

public final class PhiAccrualDetector {

    private let threshold: Double
    private let jitterMs: Double
    private let history: HeartbeatHistory
    private let timeSource: TimeSource
    private var lastTimestamp: Double = -1

    public init(threshold: Double, jitterMs: Double = 200, timeSource: TimeSource = SystemTimeSource.instance) {
        self.threshold = threshold
        self.jitterMs = jitterMs
        self.history = HeartbeatHistory()
        self.timeSource = timeSource
    }

    public func heartbeat() {
        let currentTimestamp = timeSource.unixTimeMillis
        if lastTimestamp != -1 {
            let interval = currentTimestamp - lastTimestamp
            if isAvailable(currentTimestamp) {
                history.recordHeartbeat(interval)
            }
        }
        lastTimestamp = currentTimestamp
    }

    public var isAvailable: Bool {
        get {
            return isAvailable(timeSource.unixTimeMillis)
        }
    }

    public var phi: Double {
        get {
            return phi(timeSource.unixTimeMillis)
        }
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
